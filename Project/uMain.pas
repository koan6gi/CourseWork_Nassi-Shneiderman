unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.Menus, System.ImageList, Vcl.ImgList,
  uTreeRoutine, uEditInfoForm, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TfrmMain = class(TForm)
    ActionListMain: TActionList;
    MainMenu: TMainMenu;
    ToolBarMain: TToolBar;
    actFileNew: TAction;
    actFileOpen: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
    actEditUnDo: TAction;
    actEditReDo: TAction;
    actEditCut: TAction;
    actEditCopy: TAction;
    actEditPaste: TAction;
    actDiagramAddProcess: TAction;
    actDiagramAddIF: TAction;
    actDiagramAddWhile: TAction;
    actDiagramAddRepeat: TAction;
    actDiagramDeleteBlock: TAction;
    menuFile: TMenuItem;
    menuFileNew: TMenuItem;
    menuFileOpen: TMenuItem;
    menuFileSave: TMenuItem;
    menuFileSaveAs: TMenuItem;
    menuEdit: TMenuItem;
    menuEditUnDo: TMenuItem;
    menuEditReDo: TMenuItem;
    menuSeparator1: TMenuItem;
    menuEditCut: TMenuItem;
    menuEditCopy: TMenuItem;
    menuEditPaste: TMenuItem;
    menuDiagram: TMenuItem;
    menuDiagramAdd: TMenuItem;
    menuDiagramAddProcess: TMenuItem;
    menuDiagramAddIF: TMenuItem;
    menuDiagramAddWhile: TMenuItem;
    menuDiagramAddRepeat: TMenuItem;
    menuSeparator2: TMenuItem;
    menuDiagramDeleteBlock: TMenuItem;
    ImageListMain: TImageList;
    tbAddProcess: TToolButton;
    tbAddIF: TToolButton;
    tbAddWhile: TToolButton;
    tbDiagramAddRepeat: TToolButton;
    ScrollBoxMain: TScrollBox;
    actDiagramEditBlockCaption: TAction;
    menuDiagramEditBlockCaption: TMenuItem;
    procedure BlockDblClick(Sender: TObject);
    procedure BlockClick(Sender: TObject);
    procedure actDiagramAddProcessExecute(Sender: TObject);
    procedure actDiagramAddIFExecute(Sender: TObject);
    procedure actDiagramAddWhileExecute(Sender: TObject);
    procedure actDiagramAddRepeatExecute(Sender: TObject);
    procedure frmMainCreate(Sender: TObject);
    procedure actDiagramEditBlockCaptionExecute(Sender: TObject);
    procedure ActionListMainUpdate(Action: TBasicAction; var Handled: Boolean);
    procedure ScrollBoxMainMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure ScrollBoxMainMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
  private

  public
    Diagram: array of TImage;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

const
  EditInfoMessages: array [TNodeType] of String = ('', 'Введите текст',
    'Введите условие', 'Введите условие входа в цикл',
    'Введите условие выхода из цикла');

const
  StdWidthCycleBoard: Integer = 25;
  StdHeightCycleCaption: Integer = 50;
  StdWidth: Integer = 100;
  StdHeight: Integer = 50;

var
  StdLeft: Integer = 100;
  StdTop: Integer = 10;
  CurrBlockID: Integer = 0;

Type
  TPaintBlock = procedure(var Block: TImage);

function GetCycleBlockCaptionHeight(const ID: Integer): Integer;
begin
  if GetNodeCaption(ID) = '' then
    result := StdHeightCycleCaption
  else
    result := StdHeightCycleCaption;
end;

procedure PaintProcessBlock(var Block: TImage);
begin
  with Block, Picture.Bitmap do
  begin
    Canvas.Pen.Color := clBlack;
    Block.Canvas.Rectangle(0, 0, Width, Height);
  end;
end;

procedure PaintIFBlock(var Block: TImage);
var
  Tr: Array [1 .. 3] of TPoint;
begin
  with Block, Picture.Bitmap do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
    Tr[1].Create(0, 0);
    Tr[2].Create(Width, 0);
    Tr[3].Create(Width div 2, Height);
    Canvas.Polygon(Tr);
  end;
end;

procedure PaintWhileBlock(var Block: TImage);
begin
  with Block, Picture.Bitmap do
  begin
    Block.Canvas.Rectangle(0, 0, Block.Width, Height);
    Block.Canvas.Rectangle(StdWidthCycleBoard,
      GetCycleBlockCaptionHeight(Block.Tag), Width, Height);
  end;
end;

procedure PaintRepeatBlock(var Block: TImage);
begin
  with Block, Picture.Bitmap do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
    Block.Canvas.Rectangle(StdWidthCycleBoard,
      Height - GetCycleBlockCaptionHeight(Block.Tag), Width, 0);
  end;
end;

Procedure PaintHead(Var Block: TImage);
begin
  with Block, Picture.Bitmap do
  begin
    Canvas.Pen.Color := clBlack;
    Block.Canvas.Rectangle(0, 0, Width, Height);
    Block.Canvas.TextOut((Width - Canvas.TextWidth('X')) div 2,
      (Height - Canvas.TextHeight('X')) div 2, 'X');

  end;
end;

const
  PaintBlock: array [TNodeType] of TPaintBlock = (PaintHead, PaintProcessBlock,
    PaintIFBlock, PaintWhileBlock, PaintRepeatBlock);

function GetBlock(const ID: Integer): TImage;
var
  I: Integer;
begin
  result := nil;
  for I := Low(frmMain.Diagram) to High(frmMain.Diagram) do
    if frmMain.Diagram[I].Tag = ID then
    begin
      result := frmMain.Diagram[I];
      break;
    end;
end;

function GetBlockInd(const ID: Integer): Integer;
var
  I: Integer;
begin
  result := 0;
  for I := Low(frmMain.Diagram) to High(frmMain.Diagram) do
    if frmMain.Diagram[I].Tag = ID then
    begin
      result := I;
      break;
    end;
end;

procedure SetTextSettings(Block: TImage);
begin
  with Block, Canvas, Font do
  begin
    Font.Name := 'Times New Roman';
    Font.Size := 12;
  end;
end;

procedure CreateBlock(var Block: TImage; const NT: TNodeType;
  Owner: TWinControl);
var
  CountOfBranch: Integer;
begin
  Block := TImage.Create(Owner);
  Block.Parent := Owner;
  SetTextSettings(Block);
  with Block do
  begin
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := clWhite;

    SetBounds(StdLeft, StdTop, StdWidth, StdHeight);

    Block.Picture.Bitmap.Height := StdHeight;
    Block.Picture.Bitmap.Width := StdWidth;

    case NT of
      ntIF:
        CountOfBranch := 2;
      ntWhile:
        CountOfBranch := 1;
      ntRepeat:
        CountOfBranch := 1;
    else
      CountOfBranch := 0;
    end;

    Tag := GetNodeMaxID - CountOfBranch;
    if NT <> ntHead then
      OnDblClick := frmMain.BlockDblClick;
    OnClick := frmMain.BlockClick;

    Visible := True;
    Show;
    PaintBlock[NT](Block);
  end;

end;

function GetArrOfAllNextElementsInd(const ID: Integer): TArrOfInd;
var
  Arr: TArrOfInd;
  I: Integer;
begin
  Arr := GetArrOfAllNextElementsID(ID);
  for I := Low(Arr) to High(Arr) do
    Arr[I] := GetBlockInd(Arr[I]);
  result := Copy(Arr, 0, Length(Arr));
end;

function GetArrOfNextElementsInd(const ID: Integer): TArrOfInd;
var
  Arr: TArrOfInd;
  I: Integer;
begin
  Arr := GetArrOfNextElementsID(ID);
  for I := Low(Arr) to High(Arr) do
    Arr[I] := GetBlockInd(Arr[I]);
  result := Copy(Arr, 0, Length(Arr));
end;

function GetBlockHeight(const ID: Integer): Integer;
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  result := 0;
  if Block <> nil then
  begin
    if (GetNodeType(ID) = ntWhile) or (GetNodeType(ID) = ntRepeat) then
      result := GetCycleBlockCaptionHeight(ID)
    else if not((GetNodeType(ID) = ntHead) and
      (IsNodeHaveKid(ID) and (GetBlock(GetNodeKidID(ID)) <> nil))) then
      result := Block.Picture.Bitmap.Height
  end;

end;

function GetLengthOfBranch(const A: TArrOfInd): Integer;
var
  I: Integer;
begin
  result := 0;
  for I := Low(A) to High(A) do
    Inc(result, GetBlockHeight(A[I]));
end;

function GetMaxLengthOfBranch(const ID: Integer): Integer;
var
  A: TArrOfArrInd;
  I, len: Integer;
begin
  result := 0;

  A := GetArrOfBranches( { ID } );

  for I := Low(A) to High(A) do
  begin
    len := GetLengthOfBranch(A[I]);
    if len > result then
      result := len
  end;
end;

procedure InsertBlockInArray(ID: Integer; NT: TNodeType; Info: TDataString);
var
  I: Integer;
  temp, Block, DiagramBlock: TImage;
  IHeight, IWidth, IDOfNewBlock, NodeParentID, MaxLen: Integer;
  CurrNodeType, NodeParentType: TNodeType;
  Arr: TArrOfInd;
  ConditionForShift: Boolean;
  Parent: TImage;
begin
  CurrNodeType := GetNodeType(CurrBlockID);
  DiagramBlock := GetBlock(ID);

  MaxLen := GetMaxLengthOfBranch(ID);

  StdTop := DiagramBlock.Top;
  if CurrNodeType <> ntHead then
    StdTop := DiagramBlock.Top + DiagramBlock.Height;
  CreateBlock(temp, NT, frmMain.ScrollBoxMain);

  if NT = ntIF then
  begin
    temp.Width := 2 * StdWidth;
    temp.Picture.Bitmap.Width := 2 * StdWidth;
  end
  else
  begin
    temp.Width := DiagramBlock.Width;
    temp.Picture.Bitmap.Width := DiagramBlock.Picture.Bitmap.Width;
  end;

  IDOfNewBlock := temp.Tag;
  temp.Left := DiagramBlock.Left;
  Insert(temp, frmMain.Diagram, 0);

  IHeight := temp.Height;

  case NT of
    ntIF:
      begin
        CreateBlock(Block, ntHead, frmMain.ScrollBoxMain);
        Block.Tag := Block.Tag - 1;
        Block.Top := Block.Top + temp.Height;
        Block.Left := temp.Left;
        Insert(Block, frmMain.Diagram, 0);
        IWidth := Block.Width;

        CreateBlock(Block, ntHead, frmMain.ScrollBoxMain);
        Block.Left := temp.Left + IWidth;
        Block.Top := Block.Top + temp.Height;
        Insert(Block, frmMain.Diagram, 0);

        temp.Height := temp.Height + IHeight;

        Inc(IHeight, Block.Height);
        if (CurrNodeType = ntHead) then
          Dec(IHeight, StdHeight);
      end;
    ntWhile:
      begin
        CreateBlock(Block, ntHead, frmMain.ScrollBoxMain);
        Block.Top := temp.Top + StdHeightCycleCaption;
        Block.Left := temp.Left + StdWidthCycleBoard;

        if temp.Width < StdWidth then
          Block.Width := StdWidth
        else
          Block.Width := temp.Width - StdWidthCycleBoard;
        Block.Picture.Bitmap.Width := Block.Width;

        Insert(Block, frmMain.Diagram, 0);

        temp.Width := Block.Width + StdWidthCycleBoard;
        temp.Picture.Bitmap.Width := temp.Width;

        temp.Height := StdHeight + StdHeightCycleCaption;
        temp.Picture.Bitmap.Height := temp.Height;

        if CurrNodeType = ntHead then
          IHeight := StdHeightCycleCaption
        else
          IHeight := temp.Height;
      end;
    ntRepeat:
      begin
        CreateBlock(Block, ntHead, frmMain.ScrollBoxMain);
        Block.Top := temp.Top;
        Block.Left := temp.Left + StdWidthCycleBoard;

        if temp.Width < StdWidth then
          Block.Width := StdWidth
        else
          Block.Width := temp.Width - StdWidthCycleBoard;
        Block.Picture.Bitmap.Width := Block.Width;

        Insert(Block, frmMain.Diagram, 0);

        temp.Width := Block.Width + StdWidthCycleBoard;
        temp.Picture.Bitmap.Width := temp.Width;

        temp.Height := StdHeight + StdHeightCycleCaption;
        temp.Picture.Bitmap.Height := temp.Height;

        if CurrNodeType = ntHead then
          IHeight := StdHeightCycleCaption
        else
          IHeight := temp.Height;
      end;
  end;

  // Все для сдвига вниз
  ConditionForShift := (MaxLen < GetMaxLengthOfBranch(ID));

  NodeParentType := GetNodeType(GetNodeParentID(IDOfNewBlock));
  NodeParentID := GetNodeParentID(IDOfNewBlock);

  if ConditionForShift then
  begin
    IHeight := GetMaxLengthOfBranch(ID) - MaxLen;
    NodeParentID := IDOfNewBlock;
    while NodeParentID <> 0 do
    begin
      NodeParentID := GetNodeParentID(NodeParentID);
      Parent := GetBlock(NodeParentID);
      Parent.Height := Parent.Height + IHeight;
      if (GetNodeType(NodeParentID) = ntWhile) or
        (GetNodeType(NodeParentID) = ntRepeat) then
        Parent.Picture.Bitmap.Height := Parent.Height;
    end;
    Arr := GetArrOfAllNextElementsInd(IDOfNewBlock);
    for I := Low(Arr) to High(Arr) do
      frmMain.Diagram[Arr[I]].Top := frmMain.Diagram[Arr[I]].Top + IHeight;
  end
  else if ((NodeParentType = ntWhile) or (NodeParentType = ntRepeat)) and
    ((CurrNodeType <> ntHead) or ((NT = ntWhile) or (NT = ntRepeat))) then
  begin
    repeat
      Parent := GetBlock(NodeParentID);
      Parent.Height := Parent.Height + IHeight;
      Parent.Picture.Bitmap.Height := Parent.Height;
      Arr := GetArrOfNextElementsInd(NodeParentID);
        for I := Low(Arr) to High(Arr) do
      frmMain.Diagram[Arr[I]].Top := frmMain.Diagram[Arr[I]].Top + IHeight;

      NodeParentID := GetNodeParentID(NodeParentID);
      NodeParentType := GetNodeType(NodeParentID);
    until (NodeParentType <> ntWhile) and (NodeParentType <> ntRepeat);
  end
  else if NodeParentType = ntIf then
  begin
    NodeParentID := IDOfNewBlock;
    repeat
      Arr := GetArrOfNextElementsInd(NodeParentID);
      for I := Low(Arr) to High(Arr) do
        frmMain.Diagram[Arr[I]].Top := frmMain.Diagram[Arr[I]].Top + IHeight;
      NodeParentID := GetNodeParentID(NodeParentID);
      NodeParentType := GetNodeType(NodeParentID);
    until (NodeParentType <> ntIf) or (NodeParentID = 0);
  end;

end;

procedure ChangeBlockInArray(ID: Integer; Info: TDataString);
// var
// i: Integer;
begin

end;

procedure ClearAllocation();
var
  I: Integer;
begin
  with frmMain do
    for I := Low(Diagram) to High(Diagram) do
    begin
      Diagram[I].Canvas.Brush.Color := clWhite;
      PaintBlock[GetNodeType(Diagram[I].Tag)](Diagram[I]);
    end;
end;

procedure InsertBlockInDiagram(const NT: TNodeType);
begin
  InsertBlockInTree(CurrBlockID, NT,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  InsertBlockInArray(CurrBlockID, NT,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  // frmMain.BlockClick(GetBlock(CurrBlockID));
  frmMain.BlockClick(GetBlock(GetNodeMaxID()));
end;

procedure AllocateBlock(var Block: TImage);
begin
  ClearAllocation();
  CurrBlockID := Block.Tag;
  with Block do
  begin
    Canvas.Brush.Color := clYellow;
    PaintBlock[GetNodeType(Block.Tag)](Block);
    Canvas.Brush.Color := clWhite;
  end;
end;

{ TfrmMain }

procedure TfrmMain.frmMainCreate(Sender: TObject);
begin
  SetLength(frmMain.Diagram, 1);
  CreateBlock(frmMain.Diagram[0], ntHead, frmMain.ScrollBoxMain);
  frmMain.Diagram[0].Height := 0;
end;

procedure TfrmMain.ScrollBoxMainMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssShift in Shift then
    ScrollBoxMain.HorzScrollBar.Position :=
      ScrollBoxMain.HorzScrollBar.Position + 20
  else
    ScrollBoxMain.VertScrollBar.Position :=
      ScrollBoxMain.VertScrollBar.Position + 20;
end;

procedure TfrmMain.ScrollBoxMainMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  if ssShift in Shift then
    ScrollBoxMain.HorzScrollBar.Position :=
      ScrollBoxMain.HorzScrollBar.Position - 20
  else
    ScrollBoxMain.VertScrollBar.Position :=
      ScrollBoxMain.VertScrollBar.Position - 20;
end;

procedure TfrmMain.BlockDblClick(Sender: TObject);
var
  Block: TImage;
begin
  Block := GetBlock(CurrBlockID);
  if Block <> nil then
    frmMain.actDiagramEditBlockCaptionExecute(Block);
end;

procedure TfrmMain.actDiagramAddProcessExecute(Sender: TObject);
begin
  InsertBlockInDiagram(ntProcess);
end;

procedure TfrmMain.actDiagramAddIFExecute(Sender: TObject);
begin
  InsertBlockInDiagram(ntIF);
end;

procedure TfrmMain.actDiagramAddRepeatExecute(Sender: TObject);
begin
  InsertBlockInDiagram(ntRepeat);
end;

procedure TfrmMain.actDiagramAddWhileExecute(Sender: TObject);
begin
  InsertBlockInDiagram(ntWhile);
end;

procedure TfrmMain.actDiagramEditBlockCaptionExecute(Sender: TObject);
begin
  frmEditInfo.LabeledEditMain.Text := '';
  if frmEditInfo.ShowModal <> mrOK then
    Exit;
end;

procedure TfrmMain.ActionListMainUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin
  actDiagramDeleteBlock.Enabled := (GetNodeType(CurrBlockID) <> ntHead);
  actDiagramEditBlockCaption.Enabled := actDiagramDeleteBlock.Enabled;

  actDiagramAddProcess.Enabled :=
    not((Length(Diagram) = 2) and (GetNodeType(CurrBlockID) = ntHead));
  actDiagramAddIF.Enabled := actDiagramAddProcess.Enabled;
  actDiagramAddWhile.Enabled := actDiagramAddProcess.Enabled;
  actDiagramAddRepeat.Enabled := actDiagramAddProcess.Enabled;

end;

procedure TfrmMain.BlockClick(Sender: TObject);
var
  Block: TImage;
begin
  Block := Sender as TImage;
  AllocateBlock(Block);
end;

end.
