unit uTreeRoutine;

interface

Type
  TNodeType = (ntHead, ntProcess, ntIF, ntWhile, ntRepeat);

  PAdrOfNode = ^TNode;

  TDataString = String[200];

  TData = record
    ID: Integer;
    nodeType: TNodeType;
    caption: TDataString;
    case TNodeType of
      ntHead:
        (maxID: Integer);
      ntProcess, ntWhile, ntRepeat, ntIF:
        (PotentialDiagramWidth: Integer);
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

  TLength = Integer;

  TLen_ID = record
    Length, ParentID: Integer;
    IDs: TArrOfInd;
  end;

  TArrOfLen_ID = array of TLen_ID;

  TArrOfArrInd = array of TArrOfInd;

var
  TreeDiagram: PAdrOfNode;

procedure DeleteNode(const ID: Integer);

function GetPotentialDiagramWidth(const ID, BlockWidth: Integer): Integer;

procedure InsertNode(const ID: Integer; const NT: TNodeType;
  const Info: TDataString);

function GetNodeType(const ID: Integer): TNodeType;

function GetNodeLastID(): Integer;

function GetNodeCaption(const ID: Integer): TDataString;

function GetNodeMaxID(): Integer;

procedure IncNodeMaxID();

function GetNodeParentID(const ID: Integer): Integer;

function IsNodeHaveKid(const ID: Integer): Boolean;

function GetNodeKidID(const ID: Integer): Integer;

function GetArrOfLen_ID(const ID: Integer): TArrOfLen_ID;

procedure CorrectDiagramWidth(const ID, NewBlockWidth: Integer);

procedure SetNodeCaption(const ID: Integer; const caption: TDataString);

procedure SetNodePotentialDiagramWidth(const ID, BlockWidth: Integer);

function GetNodePotentialDiagramWidth(const ID: Integer): Integer;

function GetMaxPotentialDiagramWidth(): Integer;

function GetArrOfNodeKids(const ID: Integer): TArrOfInd;

function GetPrevNodeID(const ID: Integer): Integer;

function GetNodeHead(const ID: Integer): PAdrOfNode;

implementation

uses uMain;

{ **************************************************************************** }
{ *                    Procedures to get info from modal                     * }
{ **************************************************************************** }

function GetNode(const ID: Integer): PAdrOfNode;
  function gn(Tree: PAdrOfNode): PAdrOfNode;
  begin
    result := nil;

    while (Tree <> nil) do
    begin
      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        result := gn(Tree^.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        result := gn(Tree^.subNode.ifBlock.trueBranch);
        if result = nil then
          result := gn(Tree^.subNode.ifBlock.falseBranch);
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
    result := gn(TreeDiagram);
end;

function GetMaxPotentialDiagramWidth(): Integer;

  procedure gmp(Tree: PAdrOfNode);
  begin
    while (Tree <> nil) do
    begin
      if (Tree.data.nodeType <> ntHead) and
        (Tree.data.PotentialDiagramWidth > result) then
        result := Tree.data.PotentialDiagramWidth;

      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        gmp(Tree^.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        gmp(Tree^.subNode.ifBlock.trueBranch);
        gmp(Tree^.subNode.ifBlock.falseBranch);
      end;
      Tree := Tree^.next;
    end;
  end;

begin
  result := StdWidth;
  gmp(TreeDiagram);
end;

function GetNodePotentialDiagramWidth(const ID: Integer): Integer;
var
  Node: PAdrOfNode;
begin
  Node := GetNode(ID);
  result := 0;
  if Node <> nil then
    result := Node.data.PotentialDiagramWidth;
end;

procedure SetNodePotentialDiagramWidth(const ID, BlockWidth: Integer);
begin
  GetNode(ID).data.PotentialDiagramWidth := GetPotentialDiagramWidth(ID,
    BlockWidth);
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

function GetNodeParentID(const ID: Integer): Integer;
begin
  result := GetNodeParent(ID).data.ID;
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

function IsNodeHaveKid(const ID: Integer): Boolean;
begin
  result := GetNode(ID).next <> nil;
end;

function GetNodeKidID(const ID: Integer): Integer;
var
  kid: PAdrOfNode;
begin
  result := -1;
  kid := GetNode(ID);
  if kid <> nil then
    result := kid.next.data.ID;
end;

function GetNodeCaption(const ID: Integer): TDataString;
begin
  result := GetNodeInfo(ID).caption;
end;

function GetNodeLastID(): Integer;
var
  temp: PAdrOfNode;
begin
  temp := TreeDiagram;
  while temp.next <> nil do
    temp := temp.next;
  result := temp.data.ID;
end;

procedure SetNodeCaption(const ID: Integer; const caption: TDataString);
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

procedure Add10El(var Arr: TArrOfInd); overload;
var
  I: Integer;

begin
  SetLength(Arr, Length(Arr) + 10);
  for I := High(Arr) - 9 to High(Arr) do
    Arr[I] := 0;
end;

function GetBranchLength(Tree: PAdrOfNode): Integer;
var
  MaxLength, CurrLength: Integer;

  procedure gbl(Tree: PAdrOfNode);
  var
    LengthTrueBranch, LengthFalseBranch: Integer;
  begin
    while (Tree <> nil) do
    begin
      Inc(CurrLength, GetBlockHeight(Tree.data.ID));

      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        gbl(Tree^.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        LengthFalseBranch := CurrLength;
        gbl(Tree^.subNode.ifBlock.trueBranch);
        LengthTrueBranch := CurrLength;
        CurrLength := LengthFalseBranch;
        gbl(Tree^.subNode.ifBlock.falseBranch);
        if CurrLength < LengthTrueBranch then
          CurrLength := LengthTrueBranch;
      end;

      Tree := Tree^.next;
    end;
    if MaxLength < CurrLength then
      MaxLength := CurrLength;
  end;

begin
  MaxLength := 0;
  CurrLength := 0;
  gbl(Tree);
  result := MaxLength;
end;

function GetMaxLength(): Integer;
begin
  result := GetBranchLength(TreeDiagram);
end;

procedure MakeArr(Tree: PAdrOfNode; var Arr: TArrOfInd; var I: Integer);
begin
  while Tree <> nil do
  begin
    if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat) then
    begin
      MakeArr(Tree^.subNode.cycleBlock.cycleBranch, Arr, I);
    end
    else if (Tree^.data.nodeType = ntIF) then
    begin
      MakeArr(Tree^.subNode.ifBlock.trueBranch, Arr, I);
      MakeArr(Tree^.subNode.ifBlock.falseBranch, Arr, I);
    end;

    if I > High(Arr) then
      Add10El(Arr);
    Arr[I] := Tree^.data.ID;
    Inc(I);

    Tree := Tree^.next;
  end;
end;

function GetArrOfNextElementsID(const ID: Integer): TArrOfInd;
var
  Arr: TArrOfInd;
  I: Integer;
  Node: PAdrOfNode;

begin
  I := 0;
  SetLength(Arr, 0);
  Node := GetNode(ID);
  if Node <> nil then
    MakeArr(Node^.next, Arr, I);

  result := Copy(Arr, 0, Length(Arr));

  for I := Low(result) + 1 to High(result) do
    if result[I] = 0 then
    begin
      SetLength(result, I);
      break;
    end;
end;

function GetArrOfNodeKids(const ID: Integer): TArrOfInd;
var
  Node: PAdrOfNode;
  I: Integer;
begin
  I := 0;
  Node := GetNode(ID);
  if (Node.data.nodeType = ntWhile) or (Node.data.nodeType = ntRepeat) then
  begin
    MakeArr(Node.subNode.cycleBlock.cycleBranch, result, I);
  end
  else if (Node.data.nodeType = ntIF) then
  begin
    MakeArr(Node.subNode.ifBlock.trueBranch, result, I);
    MakeArr(Node.subNode.ifBlock.falseBranch, result, I);
  end;
  for I := Low(result) to High(result) do
    if result[I] = 0 then
    begin
      SetLength(result, I);
      break;
    end;
end;

procedure Add10El(var Arr: TArrOfLen_ID); overload;
var
  I: Integer;

begin
  SetLength(Arr, Length(Arr) + 10);
  for I := High(Arr) - 9 to High(Arr) do
  begin
    Arr[I].Length := 0;
    Arr[I].IDs := nil;
  end;
end;

function GetArrOfLen_ID(const ID: Integer): TArrOfLen_ID;
var
  Node, Head: PAdrOfNode;
  Flag: Boolean;
  I: Integer;
begin
  I := 0;
  Flag := True;
  Node := GetNode(ID);
  Head := GetNodeHead(ID);
  while Flag do
  begin
    if I > High(result) - 1 then
      Add10El(result);
    result[I].Length := GetBranchLength(Head);
    result[I].IDs := GetArrOfNextElementsID(Node.data.ID);
    result[I].ParentID := -1;
    if Head.data.ID = 0 then
      Flag := False;
    Node := GetNodeParent(Head.data.ID);
    result[I].ParentID := Node.data.ID;
    Head := GetNodeHead(Node.data.ID);
    Inc(I);
  end;

end;

type
  TInsertBlockHeadInTree = procedure(var Branch: PAdrOfNode);

const
  InsertBlockHeadInTree: array [TNodeType] of TInsertBlockHeadInTree = (nil,
    nil, InsertIfBlockHeadsInTree, InsertCycleBlockHeadInTree,
    InsertCycleBlockHeadInTree);

procedure InsertNode(const ID: Integer; const NT: TNodeType;
  const Info: TDataString);
var
  tempNode, temp: PAdrOfNode;
begin
  tempNode := GetNode(ID);
  temp := tempNode^.next;
  New(tempNode^.next);
  tempNode := tempNode^.next;
  with tempNode^, data do
  begin
    next := temp;
    caption := Info;
    IncNodeMaxID();
    data.ID := GetNodeMaxID();
    nodeType := NT;
    PotentialDiagramWidth := GetPotentialDiagramWidth(ID, StdWidth);
    if Assigned(InsertBlockHeadInTree[NT]) then
      InsertBlockHeadInTree[NT](tempNode);
  end;
end;

procedure FreeDiagram(var Diagram: PAdrOfNode); forward;

procedure DeleteNode(const ID: Integer);
var
  PrevNode, CurrNode, NextNode: PAdrOfNode;
  NT: TNodeType;
  Flag: Boolean;
  function FindNode(Tree: PAdrOfNode): PAdrOfNode;
  begin
    result := nil;

    while (Tree.next <> nil) do
    begin

      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        result := FindNode(Tree^.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        result := FindNode(Tree^.subNode.ifBlock.trueBranch);
        if result = nil then
          result := FindNode(Tree^.subNode.ifBlock.falseBranch);
      end;

      if Tree.next.data.ID = ID then
        result := Tree;
      if (result <> nil) then
        Exit;

      Tree := Tree.next;
    end;
    if (result = nil) then
    begin
      if (Tree^.data.nodeType = ntWhile) or (Tree^.data.nodeType = ntRepeat)
      then
      begin
        result := FindNode(Tree^.subNode.cycleBlock.cycleBranch);
      end
      else if (Tree^.data.nodeType = ntIF) then
      begin
        result := FindNode(Tree^.subNode.ifBlock.trueBranch);
        if result = nil then
          result := FindNode(Tree^.subNode.ifBlock.falseBranch);
      end;
    end;
  end;

begin
  NT := ntHead;
  Flag := False;
  PrevNode := FindNode(TreeDiagram);
  CurrNode := PrevNode.next;
  NextNode := CurrNode.next;
  PrevNode.next := NextNode;
  if (CurrNode.data.nodeType = ntWhile) or (CurrNode.data.nodeType = ntRepeat)
  then
  begin
    FreeDiagram(CurrNode.subNode.cycleBlock.cycleBranch);
  end
  else if CurrNode.data.nodeType = ntIF then
  begin
    FreeDiagram(CurrNode.subNode.ifBlock.trueBranch);
    FreeDiagram(CurrNode.subNode.ifBlock.falseBranch);
  end;
  Dispose(CurrNode);
end;

function GetPotentialDiagramWidth(const ID, BlockWidth: Integer): Integer;
var
  CurrID: Integer;
  Parent: PAdrOfNode;
begin
  CurrID := ID;
  result := BlockWidth;
  while CurrID <> 0 do
  begin
    Parent := GetNodeParent(CurrID);
    case Parent.data.nodeType of
      ntIF:
        begin
          result := result * 2;
        end;
      ntWhile, ntRepeat:
        begin
          result := result + StdWidthCycleBoard;
        end;
    end;
    CurrID := Parent.data.ID;
  end;
end;

procedure CorrectDiagramWidth(const ID, NewBlockWidth: Integer);
  procedure cdw(Tree: PAdrOfNode; const NewWidth, NewLeft: Integer);
  var
    tempNode: PAdrOfNode;
  begin
    while Tree <> nil do
    begin
      SetBlockWidth(Tree.data.ID, NewWidth);
      if NewLeft <> 0 then
      begin
        SetBlockLeft(Tree.data.ID, NewLeft);
      end;

      case Tree.data.nodeType of
        ntIF:
          begin
            cdw(Tree.subNode.ifBlock.trueBranch, NewWidth div 2,
              GetBlockLeft(Tree.data.ID));
            tempNode := Tree.subNode.ifBlock.trueBranch;
            cdw(Tree.subNode.ifBlock.falseBranch, NewWidth div 2,
              GetBlockLeft(tempNode.data.ID) + GetBlockWidth(tempNode.data.ID));
          end;
        ntWhile, ntRepeat:
          begin
            cdw(Tree.subNode.cycleBlock.cycleBranch,
              NewWidth - StdWidthCycleBoard, GetBlockLeft(Tree.data.ID) +
              StdWidthCycleBoard);
          end;
      end;

      Tree := Tree.next;
    end;

  end;

begin
  cdw(TreeDiagram, GetPotentialDiagramWidth(ID, NewBlockWidth), 0);
end;

function GetPrevNodeID(const ID: Integer): Integer;
var
  HeadNode: PAdrOfNode;
begin
  HeadNode := GetNodeHead(ID);
  result := -1;
  while HeadNode.next <> nil do
  begin
    if HeadNode.next.data.ID = ID then
    begin
      result := HeadNode.data.ID;
      break;
    end;
  end;
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
