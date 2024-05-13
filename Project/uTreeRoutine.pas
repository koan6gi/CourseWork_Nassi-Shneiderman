unit uTreeRoutine;

interface

Type
  TNodeType = (ntHead, ntProcess, ntIF, ntWhile, ntRepeat);

  PAdrOfNode = ^TNode;

  TDataString = String[200];

  TData = record
    ID: Integer;
    nodeType: TNodeType;
    case TNodeType of
      ntHead:
        (maxID: Integer);
      ntProcess:
        (caption: TDataString);
  end;

  TIfBlock = record
    trueBranch, falseBranch: PAdrOfNode;
  end;

  TCycleBlock = record
    cycleBranch: PAdrOfNode;
  end;

  TSubNode = record
    case TNodeType of
      ntIF:
        (ifBlock: TIfBlock);
      ntWhile:
        (cycleBlock: TCycleBlock);
  end;

  TNode = record
    next: PAdrOfNode;
    data: TData;
    subNode: TSubNode;
  end;

  TArrOfInd = array of Integer;

var
  TreeDiagram: PAdrOfNode;

procedure InsertBlockInTree(ID: Integer; NT: TNodeType; Info: TDataString);

function GetNodeType(const ID: Integer): TNodeType;

function GetCaption(const ID: Integer): TDataString;

function GetNodeMaxID(): Integer;

procedure IncNodeMaxID();

function GetArrOfNextElementsID(const ID: Integer): TArrOfInd;

implementation

function GetNode(const ID: Integer): PAdrOfNode;
  function gn(Tree: PAdrOfNode; ID: Integer): PAdrOfNode;
  begin
    result := nil;

    while (Tree <> nil) do
    begin
      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        result := gn(Tree^.subNode.cycleBlock.cycleBranch, ID);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        result := gn(Tree^.subNode.ifBlock.trueBranch, ID);
        if result = nil then
          result := gn(Tree^.subNode.ifBlock.falseBranch, ID);
      end;

      if (Tree^.data.ID = ID) then
        result := Tree;

      if result <> nil then
        Exit;

      Tree := Tree^.next;
    end;
  end;

begin
  if ID = 0 then
    result := TreeDiagram
  else
    result := gn(TreeDiagram, ID);
end;

function GetNodeHead(const ID: Integer): PAdrOfNode;
  function gnh(Tree: PAdrOfNode; ID: Integer): PAdrOfNode;
  var
    Parent: PAdrOfNode;
  begin
    result := nil;
    Parent := Tree;

    while (Tree <> nil) do
    begin
      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        result := gnh(Tree^.subNode.cycleBlock.cycleBranch, ID);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        result := gnh(Tree^.subNode.ifBlock.trueBranch, ID);
        if result = nil then
          result := gnh(Tree^.subNode.ifBlock.falseBranch, ID);
      end;

      if (Tree^.data.ID = ID) then
        result := Parent;

      if result <> nil then
        Exit;

      Tree := Tree^.next;
    end;
  end;

begin
  if ID = 0 then
    result := TreeDiagram
  else
    result := gnh(TreeDiagram, ID);
end;

function GetNodeParent(const ID: Integer): PAdrOfNode;
var
  IsAlreadySearched: Boolean;
  function gnp(Tree: PAdrOfNode; ID: Integer): PAdrOfNode;
  var
    Parent: PAdrOfNode;
  begin
    result := nil;
    Parent := Tree;

    while (Tree <> nil) do
    begin
      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        result := gnp(Tree^.subNode.cycleBlock.cycleBranch, ID);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        result := gnp(Tree^.subNode.ifBlock.trueBranch, ID);
        if result = nil then
        begin
          result := gnp(Tree^.subNode.ifBlock.falseBranch, ID);
        end;
      end;
      if (result <> nil) and not(IsAlreadySearched) then
      begin
        result := Tree;
        IsAlreadySearched := True;
        Exit;
      end;

      if (Tree^.data.ID = ID) then
        result := Parent;

      if result <> nil then
      begin
        Exit;
      end;

      Tree := Tree^.next;
    end;
  end;

begin
  IsAlreadySearched := False;
  if ID = 0 then
    result := TreeDiagram
  else
    result := gnp(TreeDiagram, ID);
end;

function GetNodeMaxID(): Integer;
begin
  result := TreeDiagram^.data.maxID;
end;

procedure IncNodeMaxID();
begin
  Inc(TreeDiagram^.data.maxID);
end;

function GetNodeInfo(const ID: Integer): TData;
begin
  result := GetNode(ID)^.data;
end;

function GetNodeType(const ID: Integer): TNodeType;
begin
  result := GetNodeInfo(ID).nodeType;
end;

function GetCaption(const ID: Integer): TDataString;
begin
  result := GetNodeInfo(ID).caption;
end;

procedure SetCaption(const ID: Integer; const caption: TDataString);
begin
  GetNode(ID)^.data.caption := caption;
end;

procedure CreateHead(var Tree: PAdrOfNode); forward;

procedure InsertIfBlockHeadsInTree(var Branch: PAdrOfNode);
begin
  CreateHead(Branch^.subNode.ifBlock.trueBranch);
  IncNodeMaxID();
  Branch^.subNode.ifBlock.trueBranch.data.ID := GetNodeMaxID();
  CreateHead(Branch^.subNode.ifBlock.falseBranch);
  IncNodeMaxID();
  Branch^.subNode.ifBlock.falseBranch.data.ID := GetNodeMaxID();
end;

procedure InsertCycleBlockHeadInTree(var Branch: PAdrOfNode);
begin
  CreateHead(Branch^.subNode.cycleBlock.cycleBranch);
  IncNodeMaxID();
  Branch^.subNode.cycleBlock.cycleBranch.data.ID := GetNodeMaxID();
end;

procedure Add10El(var Arr: TArrOfInd);
var
  I: Integer;

begin
  SetLength(Arr, Length(Arr) + 10);
  for I := High(Arr) - 9 to High(Arr) do
    Arr[I] := 0;
end;

function GetArrOfNextElementsID(const ID: Integer): TArrOfInd;
var
  Arr: TArrOfInd;
  I: Integer;
  Node, NodeParent: PAdrOfNode;
  procedure MakeArr(Tree: PAdrOfNode);
  begin
    while Tree <> nil do
    begin
      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        MakeArr(Tree^.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        MakeArr(Tree^.subNode.ifBlock.trueBranch);
        MakeArr(Tree^.subNode.ifBlock.falseBranch);
      end;

      if I > High(Arr) then
        Add10El(Arr);
      Arr[I] := Tree^.data.ID;
      Inc(I);

      Tree := Tree^.next;
    end;
  end;

begin
  I := 0;
  SetLength(Arr, 0);
  Node := GetNodeParent(ID);
  Node := GetNode(ID);
  if Node <> nil then
    MakeArr(Node^.next);

  NodeParent := GetNodeParent(ID);
  if (NodeParent <> nil) and (NodeParent.data.ID <> 0) then
    MakeArr(NodeParent^.next);

    result := Copy(Arr, 0, Length(Arr));

  for I := Low(result) + 1 to High(result) do
    if result[I] = 0 then
    begin
      SetLength(result, I + 1);
      break;
    end;
end;

function GetArrOfBranchElementsID(const ID: Integer): TArrOfInd;
var
  Arr: TArrOfInd;
  I: Integer;
  Node: PAdrOfNode;
  procedure MakeArr(Tree: PAdrOfNode);
  begin
    while Tree <> nil do
    begin
      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        MakeArr(Tree^.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        MakeArr(Tree^.subNode.ifBlock.trueBranch);
        MakeArr(Tree^.subNode.ifBlock.falseBranch);
      end;

      if I > High(Arr) then
        Add10El(Arr);
      Arr[I] := Tree^.data.ID;
      Inc(I);

      Tree := Tree^.next;
    end;
  end;

begin
  I := 0;
  SetLength(Arr, 0);
  Node := GetNodeParent(ID);
  Node := GetNode(ID);
  if Node <> nil then
    MakeArr(Node^.next);

  result := Copy(Arr, 0, Length(Arr));

  for I := Low(result) + 1 to High(result) do
    if result[I] = 0 then
    begin
      SetLength(result, I + 1);
      break;
    end;
end;

type
  TInsertBlockHeadInTree = procedure(var Branch: PAdrOfNode);

const
  InsertBlockHeadInTree: array [TNodeType] of TInsertBlockHeadInTree = (nil,
    nil, InsertIfBlockHeadsInTree, InsertCycleBlockHeadInTree,
    InsertCycleBlockHeadInTree);

procedure InsertBlockInTree(ID: Integer; NT: TNodeType; Info: TDataString);
var
  tempNode, temp: PAdrOfNode;
begin
  tempNode := GetNode(ID);
  temp := tempNode^.next;
  New(tempNode^.next);
  tempNode := tempNode^.next;
  with tempNode^, data do
  begin
    caption := Info;
    IncNodeMaxID();
    data.ID := GetNodeMaxID();
    nodeType := NT;

    if Assigned(InsertBlockHeadInTree[NT]) then
      InsertBlockHeadInTree[NT](tempNode);

    next := temp;
  end;
end;

procedure ChangeBlockCaption(const ID: Integer; const Info: TDataString);
begin
  SetCaption(ID, Info);
end;

procedure CreateHead(var Tree: PAdrOfNode);
begin
  New(Tree);
  with Tree^, data do
  begin
    next := nil;
    caption := '';
    nodeType := ntHead;
    maxID := 0;
    ID := 0;
  end;

end;

procedure FreeDiagram(var Diagram: PAdrOfNode);
var
  temp: PAdrOfNode;
begin
  while Diagram <> nil do
  begin
    temp := Diagram;
    Diagram := Diagram.next;
    if ((temp.data.nodeType = ntWhile) or (temp.data.nodeType = ntRepeat)) then
      FreeDiagram(temp.subNode.cycleBlock.cycleBranch)
    else if (temp.data.nodeType = ntIF) then
    begin
      FreeDiagram(temp.subNode.ifBlock.trueBranch);
      FreeDiagram(temp.subNode.ifBlock.falseBranch);
    end;

    Dispose(temp);
  end;
end;

initialization

CreateHead(TreeDiagram);

finalization

FreeDiagram(TreeDiagram);

end.