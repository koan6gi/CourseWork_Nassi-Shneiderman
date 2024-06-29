unit uFileRoutine;

interface

uses
  Winapi.Windows, Vcl.ExtCtrls, Vcl.Graphics;

Type
  TFilePath = String;
  TArrOfBlock = array of TImage;

var
  SavePath: TFilePath = '';
  OpenPath: TFilePath = '';

procedure SaveDiagram();
procedure SetSavePath(const NewSavePath: String);
procedure OpenDiagram();
procedure SetOpenPath(const NewOpenPath: String);
Procedure Qsort(Var Data: TArrOfBlock; L, R: Integer);

implementation

uses uMain, uTreeRoutine, Vcl.Imaging.pngimage;

Type
  TNodeFile = File of TData;

var
  NodeFile: TNodeFile;

procedure Swap(var A, B: TImage);
var
  temp: TImage;
begin
  temp := A;
  A := B;
  B := temp;
end;

Procedure Qsort(Var Data: TArrOfBlock; L, R: Integer);
  Procedure QuickSort(L, R: Integer);
  var
    I, J, X: Integer;
  begin
    I := L;
    J := R;
    X := Data[(L + R) div 2].Tag;
    Repeat
      While Data[I].Tag < X do
      begin
        Inc(I);
      end;
      While Data[J].Tag > X do
      begin
        Dec(J);
      end;
      If I <= J then
      begin
        Swap(Data[I], Data[J]);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    If J > L then
      QuickSort(L, J);
    If I < R then
      QuickSort(I, R);
  end;

begin
  QuickSort(L, R);
end;

procedure CalcLengthBranchs(Tree: PAdrOfNode);
var
  CountBlockOfBranch: ^Integer;
begin
  CountBlockOfBranch := @Tree.Data.maxID;
  CountBlockOfBranch^ := 0;
  while Tree <> nil do
  begin
    Inc(CountBlockOfBranch^);
    if (Tree.Data.nodeType = ntWhile) or (Tree.Data.nodeType = ntRepeat) then
    begin
      CalcLengthBranchs(Tree.subNode.cycleBlock.cycleBranch);
    end
    else if (Tree.Data.nodeType = ntIf) then
    begin
      CalcLengthBranchs(Tree.subNode.ifBlock.trueBranch);
      CalcLengthBranchs(Tree.subNode.ifBlock.falseBranch);
    end;
    Tree := Tree.next;
  end;

end;

procedure PrepareTreeToSave();
begin
  TreeDiagram.Data.ID := TreeDiagram.Data.maxID;
  TreeDiagram.Data.maxID := 0;
  CalcLengthBranchs(TreeDiagram);
end;

procedure ReturnRightTreeState();
begin
  TreeDiagram.Data.maxID := TreeDiagram.Data.ID;
  TreeDiagram.Data.ID := 0;
end;

procedure SaveTree(var NodeFile: TNodeFile; const SavePath: TFilePath);
  procedure WriteTree(Tree: PAdrOfNode);
  begin
    while Tree <> nil do
    begin
      write(NodeFile, Tree.Data);
      if (Tree.Data.nodeType = ntWhile) or (Tree.Data.nodeType = ntRepeat) then
      begin
        WriteTree(Tree.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree.Data.nodeType = ntIf) then
      begin
        WriteTree(Tree.subNode.ifBlock.trueBranch);
        WriteTree(Tree.subNode.ifBlock.falseBranch);
      end;
      Tree := Tree.next;
    end;
  end;

begin
  PrepareTreeToSave();
  AssignFile(NodeFile, SavePath + '.tree');
  Rewrite(NodeFile);
  WriteTree(TreeDiagram);
  CloseFile(NodeFile);
  ReturnRightTreeState();
end;

procedure SaveDiagramPicture();
var
  Bmp: TBitmap;
  I: Integer;
  A: TArrOfBlock;
  Block: TImage;
  Png: TPngImage;
begin
  Bmp := TBitmap.Create(GetDiagramWidth() + 2 * StdLeft,
    GetDiagramHeight() + 2 * StdTop);
  A := frmMain.Diagram;
  DrawDiagram();
  for I := Low(A) to High(A) do
  begin
    Bmp.Canvas.Draw(A[I].Left, A[I].Top, A[I].Picture.Bitmap);
  end;
  Png := TPngImage.Create;
  Png.Assign(Bmp);
  Png.SaveToFile(SavePath + '.png');
  Block := GetBlock(frmMain.CurrBlockID);
  AllocateBlock(Block);
  Bmp.Free;
end;

procedure SaveDiagram();
begin
  SaveTree(NodeFile, SavePath);
  SaveDiagramPicture();
end;

procedure ReadBranch(Tree: PAdrOfNode);
var
  I: Integer;
begin
  for I := 2 to Tree.Data.maxID do
  begin
    New(Tree.next);
    Tree := Tree.next;
    read(NodeFile, Tree.Data);
    Tree.next := nil;

    if (Tree.Data.nodeType = ntWhile) or (Tree.Data.nodeType = ntRepeat) then
    begin
      New(Tree.subNode.cycleBlock.cycleBranch);
      Tree.subNode.cycleBlock.cycleBranch.next := nil;
      read(NodeFile, Tree.subNode.cycleBlock.cycleBranch.Data);
      ReadBranch(Tree.subNode.cycleBlock.cycleBranch);
    end
    else if (Tree.Data.nodeType = ntIf) then
    begin
      New(Tree.subNode.ifBlock.trueBranch);
      Tree.subNode.ifBlock.trueBranch.next := nil;
      read(NodeFile, Tree.subNode.ifBlock.trueBranch.Data);
      ReadBranch(Tree.subNode.ifBlock.trueBranch);

      New(Tree.subNode.ifBlock.falseBranch);
      Tree.subNode.ifBlock.falseBranch.next := nil;
      read(NodeFile, Tree.subNode.ifBlock.falseBranch.Data);
      ReadBranch(Tree.subNode.ifBlock.falseBranch);
    end;

  end;
end;

procedure InsertBranch(Tree: PAdrOfNode; ParentID: Integer);
begin
  While Tree <> nil do
  begin
    InsertBlockInArray(ParentID, Tree.Data.ID, Tree.Data.nodeType);

    ChangeBlockInArray(Tree.Data.ID, Tree.Data.caption);
    with frmMain do
    begin
      case Tree.Data.nodeType of

        ntWhile, ntRepeat:
          begin
            InsertBranch(Tree.subNode.cycleBlock.cycleBranch.next,
              Tree.subNode.cycleBlock.cycleBranch.Data.ID);
          end;
        ntIf:
          begin
            InsertBranch(Tree.subNode.ifBlock.trueBranch.next,
              Tree.subNode.ifBlock.trueBranch.Data.ID);
            InsertBranch(Tree.subNode.ifBlock.falseBranch.next,
              Tree.subNode.ifBlock.falseBranch.Data.ID);
          end;
      end;
    end;
    ParentID := Tree.Data.ID;
    Tree := Tree.next;
  end;
end;

procedure InsertDiagram();
begin
  InsertBranch(TreeDiagram.next, 0);

end;

procedure ReadTree();

begin
  AssignFile(NodeFile, OpenPath);
  Reset(NodeFile);
  Read(NodeFile, TreeDiagram.Data);
  ReadBranch(TreeDiagram);
  CloseFile(NodeFile);
  TreeDiagram.Data.maxID := TreeDiagram.Data.ID;
  TreeDiagram.Data.ID := 0;

end;

procedure OpenDiagram();
begin
  ReadTree();
  InsertDiagram();
end;

procedure SetSavePath(const NewSavePath: String);
var
  I: Integer;
begin
  SavePath := NewSavePath;
  for I := High(SavePath) downto Low(SavePath) do
  begin
    if NewSavePath[I] = '.' then
    begin
      SetLength(SavePath, I - 1);
      break;
    end;
  end;
end;

procedure SetOpenPath(const NewOpenPath: String);
begin
  OpenPath := NewOpenPath;
end;

end.
