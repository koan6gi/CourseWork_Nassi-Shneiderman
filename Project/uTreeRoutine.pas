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

var
  Diagram: PAdrOfNode;

procedure InsertBlockInTree(ID: Integer; NT: TNodeType; Info: TDataString);

function GetNodeType(const ID: Integer): TNodeType;

function GetCaption(const ID: Integer): TDataString;

function GetNodeMaxID(): Integer;

procedure IncNodeMaxID();

implementation

function GetNode(const ID: Integer): PAdrOfNode;
  function gn(Tree: PAdrOfNode; ID: Integer): PAdrOfNode;
  begin
    result := nil;

    with Tree^ do
      while (Tree <> nil) do
      begin
        if (data.nodeType = ntWhile) or (data.nodeType = ntRepeat) then
        begin
          result := gn(subNode.cycleBlock.cycleBranch, ID);
        end
        else if (data.nodeType = ntIF) then
        begin
          result := gn(subNode.ifBlock.trueBranch, ID);
          if result = nil then
            result := gn(subNode.ifBlock.falseBranch, ID);
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
    result := Diagram
  else
    result := gn(Diagram^.next, ID);
end;

function GetNodeMaxID(): Integer;
begin
  result := Diagram^.data.maxID;
end;

procedure IncNodeMaxID();
begin
  Inc(Diagram^.data.maxID);
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

procedure InsertIfBlockHeads(Branch: PAdrOfNode);
begin
  CreateHead(Branch^.subNode.ifBlock.trueBranch);
  IncNodeMaxID();
  Branch^.subNode.ifBlock.trueBranch.data.ID := GetNodeMaxID();
  CreateHead(Branch^.subNode.ifBlock.falseBranch);
  IncNodeMaxID();
  Branch^.subNode.ifBlock.falseBranch.data.ID := GetNodeMaxID();
end;

procedure InsertCycleBlockHead(Branch: PAdrOfNode);
begin
  CreateHead(Branch^.subNode.cycleBlock.cycleBranch);
  IncNodeMaxID();
  Branch^.subNode.cycleBlock.cycleBranch.data.ID := GetNodeMaxID();
end;

type
  TCreateBlockHead = procedure(Branch: PAdrOfNode);

const
  CreateBlockHead: array [TNodeType] of TCreateBlockHead = (nil, nil,
    InsertIfBlockHeads, InsertCycleBlockHead, InsertCycleBlockHead);

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

    if Assigned(CreateBlockHead[NT]) then
      CreateBlockHead[NT](tempNode);

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

CreateHead(Diagram);

finalization

FreeDiagram(Diagram);

end.
