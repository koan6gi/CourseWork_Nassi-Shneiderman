unit uFileRoutine;

interface

Type
  TFilePath = String;

var
  SavePath: TFilePath = '';
  OpenPath: TFilePath = '';

implementation

uses uMain, uTreeRoutine;

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
  AssignFile(NodeFile, SavePath);
  Rewrite(NodeFile);
  WriteTree(TreeDiagram);
  CloseFile(NodeFile);
  ReturnRightTreeState();
end;

procedure SaveDiagram();
begin
  SaveTree(NodeFile, SavePath);
end;

end.
