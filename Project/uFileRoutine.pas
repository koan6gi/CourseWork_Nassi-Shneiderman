unit uFileRoutine;

interface

Type
  TFilePath = String;

var
  SavePath: TFilePath = '.';
  OpenPath: TFilePath = '';

procedure SaveDiagram();

implementation

uses uMain, uTreeRoutine, Winapi.Windows, Vcl.Graphics, Vcl.Imaging.pngimage,
  Vcl.ExtCtrls;

Type
  TNodeFile = File of TData;

var
  NodeFile: TNodeFile;

procedure CalcLengthBranchs(Tree: PAdrOfNode);
var
  CountBlockOfBranch: ^Integer;
begin
  CountBlockOfBranch := @Tree.data.maxID;
  CountBlockOfBranch^ := 0;
  while Tree <> nil do
  begin
    Inc(CountBlockOfBranch^);
    if (Tree.data.nodeType = ntWhile) or (Tree.data.nodeType = ntRepeat) then
    begin
      CalcLengthBranchs(Tree.subNode.cycleBlock.cycleBranch);
    end
    else if (Tree.data.nodeType = ntIf) then
    begin
      CalcLengthBranchs(Tree.subNode.ifBlock.trueBranch);
      CalcLengthBranchs(Tree.subNode.ifBlock.falseBranch);
    end;
    Tree := Tree.next;
  end;

end;

procedure PrepareTreeToSave();
begin
  TreeDiagram.data.ID := TreeDiagram.data.maxID;
  TreeDiagram.data.maxID := 0;
  CalcLengthBranchs(TreeDiagram);
end;

procedure ReturnRightTreeState();
begin
  TreeDiagram.data.maxID := TreeDiagram.data.ID;
  TreeDiagram.data.ID := 0;
end;

procedure SaveTree(var NodeFile: TNodeFile; const SavePath: TFilePath);
  procedure WriteTree(Tree: PAdrOfNode);
  begin
    while Tree <> nil do
    begin
      write(NodeFile, Tree.data);
      if (Tree.data.nodeType = ntWhile) or (Tree.data.nodeType = ntRepeat) then
      begin
        WriteTree(Tree.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree.data.nodeType = ntIf) then
      begin
        WriteTree(Tree.subNode.ifBlock.trueBranch);
        WriteTree(Tree.subNode.ifBlock.falseBranch);
      end;
      Tree := Tree.next;
    end;
  end;

begin
  PrepareTreeToSave();
  AssignFile(NodeFile, SavePath + '\Diagram.tree');
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
  Png.SaveToFile(SavePath + '\Diagram.png');
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
  for I := 2 to Tree.data.maxID do
  begin
    New(Tree.next);
    Tree := Tree.next;
    read(NodeFile, Tree.data);
    Tree.next := nil;

    if (Tree.data.nodeType = ntWhile) or (Tree.data.nodeType = ntRepeat) then
    begin
      New(Tree.subNode.cycleBlock.cycleBranch);
      read(NodeFile, Tree.subNode.cycleBlock.cycleBranch.data);
      ReadBranch(Tree.subNode.cycleBlock.cycleBranch);
    end
    else if (Tree.data.nodeType = ntIf) then
    begin
      New(Tree.subNode.ifBlock.trueBranch);
      read(NodeFile, Tree.subNode.ifBlock.trueBranch.data);
      ReadBranch(Tree.subNode.ifBlock.trueBranch);

      New(Tree.subNode.ifBlock.falseBranch);
      read(NodeFile, Tree.subNode.ifBlock.falseBranch.data);
      ReadBranch(Tree.subNode.ifBlock.falseBranch);
    end;

  end;
end;

procedure ReadTree();

begin
  Assign(NodeFile, OpenPath + '\Diagram.tree');
  Reset(NodeFile);
  Read(NodeFile, TreeDiagram.data);
  ReadBranch(TreeDiagram);
  CloseFile(NodeFile);
end;

end.
