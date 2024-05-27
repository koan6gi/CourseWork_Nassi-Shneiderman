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
    procedure actDiagramDeleteBlockExecute(Sender: TObject);
  private
    Diagram: array of TImage;
    CurrBlockID: Integer;
  public

  end;

const
  StdTextIndent = 10;
  StdWidthCycleBoard = 25;
  StdHeightCycleCaption = 50;
  StdWidth: Integer = 100;
  StdIfWidth = 200; // StdWidth * 2
  StdHeight = 50;

  StdLeft = 100;
  StdTop = 10;

var
  frmMain: TfrmMain;

function GetBlockHeight(const ID: Integer): Integer;
procedure SetBlockWidth(const ID, NewWidth: Integer);
procedure SetBlockLeft(const ID, NewLeft: Integer);
function GetBlockLeft(const ID: Integer): Integer;
function GetBlockWidth(const ID: Integer): Integer;

implementation

{$R *.dfm}

const
  EditInfoMessages: array [TNodeType] of String = ('', 'Введите текст',
    'Введите условие', 'Введите условие входа в цикл',
    'Введите условие выхода из цикла');

Type
  TPaintBlock = procedure(var Block: TImage);

function GetBlock(const ID: Integer): TImage; forward;

function GetDiagramWidth(): Integer;
begin
  result := GetBlockWidth(0);
end;

function GetDiagramHeight(): Integer;
var
  ID: Integer;
  Block: TImage;
begin
  ID := GetNodeLastID;
  Block := GetBlock(ID);
  result := Block.Top + Block.Height;
end;

function GetCaptionWidth(const Caption: TDataString;
  const NT: TNodeType): Integer;
begin
  result := frmMain.Diagram[0].Canvas.TextWidth(String(Caption)) + 2 *
    StdTextIndent;
  if NT = ntHead then
    result := StdWidth
  else if NT = ntIF then
    // result := ;

end;

function GetCycleBlockCaptionHeight(const ID: Integer): Integer;
begin
  if GetNodeCaption(ID) = '' then
    result := StdHeightCycleCaption
  else
    result := StdHeightCycleCaption;
end;

procedure PaintProcessBlock(var Block: TImage);
var
  Caption: TDataString;
begin
  Caption := GetNodeCaption(Block.Tag);
  with Block, Picture.Bitmap do
  begin
    Canvas.Pen.Color := clBlack;
    Block.Canvas.Rectangle(0, 0, Width, Height);

    Block.Canvas.TextOut((Width - Canvas.TextWidth(String(Caption))) div 2,
      (Height - Canvas.TextHeight(String(Caption))) div 2, String(Caption));
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
var
  Caption: TDataString;
begin
  Caption := GetNodeCaption(Block.Tag);
  with Block, Picture.Bitmap do
  begin
    Block.Canvas.Rectangle(0, 0, Block.Width, Height);
    Block.Canvas.Rectangle(StdWidthCycleBoard,
      GetCycleBlockCaptionHeight(Block.Tag), Width, Height);

    Block.Canvas.TextOut((Width - Canvas.TextWidth(String(Caption))) div 2,
      (StdHeightCycleCaption - Canvas.TextHeight(String(Caption))) div 2,
      String(Caption));
  end;
end;

procedure PaintRepeatBlock(var Block: TImage);
var
  Caption: TDataString;
begin
  Caption := GetNodeCaption(Block.Tag);
  with Block, Picture.Bitmap do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
    Block.Canvas.Rectangle(StdWidthCycleBoard,
      Height - GetCycleBlockCaptionHeight(Block.Tag), Width, 0);

    Block.Canvas.TextOut((Width - Canvas.TextWidth(String(Caption))) div 2,
      Height - StdHeightCycleCaption + (StdHeightCycleCaption -
      Canvas.TextHeight(String(Caption))) div 2, String(Caption));
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
  left, right, mid: Integer;
  flag: Boolean;
begin
  result := nil;
  flag := true;
  left := low(frmMain.Diagram);
  right := high(frmMain.Diagram);

  while (left <= right) and (flag) do
  begin
    mid := (left + right) div 2;
    if ID = frmMain.Diagram[mid].Tag then
    begin
      result := frmMain.Diagram[mid];
      flag := false;
    end
    else if ID < frmMain.Diagram[mid].Tag then
      right := mid - 1
    else
      left := mid + 1;
  end;
end;

function GetBlockInd(const ID: Integer): Integer;
var
  left, right, mid: Integer;
  flag: Boolean;
begin
  result := 0;
  flag := true;
  left := low(frmMain.Diagram);
  right := high(frmMain.Diagram);

  while (left <= right) and (flag) do
  begin
    mid := (left + right) div 2;
    if ID = frmMain.Diagram[mid].Tag then
    begin
      result := mid;
      flag := false;
    end
    else if ID < frmMain.Diagram[mid].Tag then
      right := mid - 1
    else
      left := mid + 1;
  end;
end;

procedure AddBlockTop(const ID, SH: Integer);
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  if Block <> nil then
    Block.Top := Block.Top + SH;
end;

procedure AddBlockHeight(const ID, SH: Integer);
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  if Block <> nil then
  begin
    Block.Height := Block.Height + SH;
    if GetNodeType(ID) <> ntIF then
      Block.Picture.Bitmap.Height := Block.Height;
  end;
end;

procedure SetBlockWidth(const ID, NewWidth: Integer);
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  if Block <> nil then
  begin
    Block.Width := NewWidth;
    Block.Picture.Bitmap.Width := NewWidth;
  end;
end;

function GetBlockWidth(const ID: Integer): Integer;
var
  Block: TImage;
begin
  result := 0;
  Block := GetBlock(ID);
  if Block <> nil then
  begin
    result := Block.Width;
  end;
end;

procedure SetBlockLeft(const ID, NewLeft: Integer);
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  if Block <> nil then
  begin
    Block.left := NewLeft;
  end;
end;

function GetBlockLeft(const ID: Integer): Integer;
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  result := 0;
  if Block <> nil then
  begin
    result := Block.left;
  end;
end;

procedure SetTextSettings(Block: TImage);
begin
  with Block, Canvas, Font do
  begin
    Font.Name := 'Times New Roman';
    Font.Size := 11;
  end;
end;

procedure CreateBlock(var Block: TImage; const NT: TNodeType);
var
  CountOfBranch: Integer;
begin
  Block := TImage.Create(frmMain.ScrollBoxMain);
  Block.Parent := frmMain.ScrollBoxMain;
  SetTextSettings(Block);
  with Block do
  begin
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := clWhite;

    // SetBounds(StdLeft, StdTop, StdWidth, StdHeight);

    // Block.Picture.Bitmap.Height := StdHeight;
    // Block.Picture.Bitmap.Width := StdWidth;

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

    Visible := true;
    Show;
    PaintBlock[NT](Block);
  end;

end;

function GetBlockHeight(const ID: Integer): Integer;
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  result := 0;
  if (Block <> nil) and (Block.Height <> 0) then
  begin
    if (GetNodeType(ID) = ntWhile) or (GetNodeType(ID) = ntRepeat) then
      result := GetCycleBlockCaptionHeight(ID)
    else if not((GetNodeType(ID) = ntHead) and
      (IsNodeHaveKid(ID) and (GetBlock(GetNodeKidID(ID)) <> nil))) then
      result := Block.Picture.Bitmap.Height
  end;
end;

procedure SetBlockHeight(const ID, NewHeight: Integer);
var
  Block: TImage;
begin
  Block := GetBlock(ID);
  Block.Height := NewHeight;
  Block.Picture.Bitmap.Height := NewHeight;
end;

procedure CorrectBlock(var Block: TImage; const NT: TNodeType;
  const ParentID: Integer);
var
  ParentWidth, ParentHeight, ParentLeft, ParentTop, KidWidth: Integer;
  Parent, tempHead: TImage;
  ParentType: TNodeType;
begin
  Parent := GetBlock(ParentID);
  ParentWidth := Parent.Width;
  ParentHeight := Parent.Height;
  ParentLeft := Parent.left;
  ParentTop := Parent.Top;
  ParentType := GetNodeType(ParentID);

  CreateBlock(Block, NT);
  Block.left := ParentLeft;
  if ParentType = ntHead then
    Block.Top := ParentTop
  else
    Block.Top := ParentTop + ParentHeight;
  Block.Height := StdHeight;
  Block.Picture.Bitmap.Height := Block.Height;
  if ParentWidth >= StdWidth then
    Block.Width := ParentWidth
  else
    Block.Width := StdWidth;
  Block.Picture.Bitmap.Width := Block.Width;

  Insert(Block, frmMain.Diagram, Length(frmMain.Diagram));
  case NT of
    ntIF:
      begin
        // Настройка размеров
        if ParentWidth < StdIfWidth then
        begin
          Block.Width := StdIfWidth;
        end
        else
        begin
          Block.Width := ParentWidth;
        end;
        Block.Picture.Bitmap.Width := Block.Width;
        Block.Height := Block.Height + 2 * StdHeight;
        Block.Picture.Bitmap.Height := 2 * StdHeight;

        // Создание подветвей
        KidWidth := Block.Width div 3;
        CreateBlock(tempHead, ntHead);
        tempHead.Tag := Block.Tag + 1;
        tempHead.Top := Block.Top + 2 * StdHeight;
        tempHead.left := ParentLeft;
        tempHead.Height := StdHeight;
        tempHead.Picture.Bitmap.Height := tempHead.Height;
        tempHead.Width := KidWidth;
        tempHead.Picture.Bitmap.Width := KidWidth;
        Insert(tempHead, frmMain.Diagram, Length(frmMain.Diagram));

        CreateBlock(tempHead, ntHead);
        tempHead.Tag := Block.Tag + 2;
        tempHead.Top := Block.Top + 2 * StdHeight;
        tempHead.left := ParentLeft + KidWidth;
        tempHead.Height := StdHeight;
        tempHead.Picture.Bitmap.Height := tempHead.Height;
        tempHead.Width := KidWidth;
        tempHead.Picture.Bitmap.Width := KidWidth;
        Insert(tempHead, frmMain.Diagram, Length(frmMain.Diagram));
      end;
    ntWhile:
      begin
        // Настройка размеров
        if ParentWidth < StdWidth then
        begin
          Block.Width := StdWidth;
        end
        else
        begin
          Block.Width := ParentWidth;
        end;
        Block.Picture.Bitmap.Width := Block.Width;
        Block.Height := Block.Height + StdHeight;
        Block.Picture.Bitmap.Height := Block.Height;

        // Создание подветвей
        KidWidth := Block.Width - StdWidthCycleBoard;
        CreateBlock(tempHead, ntHead);
        tempHead.Tag := Block.Tag + 1;
        tempHead.Top := Block.Top + StdHeight;
        tempHead.left := ParentLeft + StdWidthCycleBoard;
        tempHead.Height := StdHeight;
        tempHead.Picture.Bitmap.Height := StdHeight;
        tempHead.Width := KidWidth;
        tempHead.Picture.Bitmap.Width := KidWidth;
        Insert(tempHead, frmMain.Diagram, Length(frmMain.Diagram));
      end;
    ntRepeat:
      begin
        // Настройка размеров
        if ParentWidth < StdWidth then
        begin
          Block.Width := StdWidth;
        end
        else
        begin
          Block.Width := ParentWidth;
        end;
        Block.Picture.Bitmap.Width := Block.Width;
        Block.Height := Block.Height + StdHeight;
        Block.Picture.Bitmap.Height := Block.Height;

        // Создание подветвей
        KidWidth := Block.Width - StdWidthCycleBoard;
        CreateBlock(tempHead, ntHead);
        tempHead.Tag := Block.Tag + 1;
        tempHead.Top := Block.Top;
        tempHead.left := ParentLeft + StdWidthCycleBoard;
        tempHead.Height := StdHeight;
        tempHead.Picture.Bitmap.Height := StdHeight;
        tempHead.Width := KidWidth;
        tempHead.Picture.Bitmap.Width := KidWidth;
        Insert(tempHead, frmMain.Diagram, Length(frmMain.Diagram));
      end;
  end;
end;

procedure PrepareArrToShift(const PrevBlockID: Integer; var Arr: TArrOfLen_ID);
begin
  Arr := GetArrOfLen_ID(PrevBlockID);
end;

function GetArrToShift(const ID: Integer; var OldArr: TArrOfLen_ID)
  : TArrOfLen_ID;
var
  I: Integer;
begin
  result := GetArrOfLen_ID(ID);
  for I := Low(result) to High(result) do
  begin
    result[I].Length := result[I].Length - OldArr[I].Length;
  end;
end;

procedure ShiftBlocks(const ID: Integer; var OldArr: TArrOfLen_ID);
var
  ArrToShift: TArrOfLen_ID;
  I, j, ShiftLen: Integer;

begin
  ArrToShift := GetArrToShift(ID, OldArr);

  for I := Low(ArrToShift) to High(ArrToShift) do
  begin
    ShiftLen := ArrToShift[I].Length;
    if ShiftLen <> 0 then
    begin
      for j := Low(ArrToShift[I].IDs) to High(ArrToShift[I].IDs) do
      begin
        AddBlockTop(ArrToShift[I].IDs[j], ShiftLen);
      end;
      if (ArrToShift[I].ParentID <> 0) and (ArrToShift[I + 1].Length <> 0) then
        AddBlockHeight(ArrToShift[I].ParentID, ArrToShift[I + 1].Length);
    end;
  end;
end;

procedure InsertBlockInArray(const ID: Integer; const NT: TNodeType);
var
  ArrToShift: TArrOfLen_ID;
  Block: TImage;
  ParentID, IDOfNewBlock: Integer;
begin
  ParentID := ID;
  PrepareArrToShift(ParentID, ArrToShift);
  CorrectBlock(Block, NT, ParentID);
  IDOfNewBlock := Block.Tag;
  CorrectDiagramWidth(IDOfNewBlock, GetBlockWidth(IDOfNewBlock));
  ShiftBlocks(IDOfNewBlock, ArrToShift);
end;

procedure DeleteBlockInArray(const ID: Integer);
var
  I: Integer;
begin
  I := GetBlockInd(ID);
  frmMain.Diagram[I].Free;
  Delete(frmMain.Diagram, I, 1);
end;

procedure DeleteBlockKids(const ID: Integer);
var
  I: Integer;
  A: TArrOfInd;
begin
  A := GetArrOfNodeKids(ID);
  for I := Low(A) to High(A) do
  begin
    DeleteBlockInArray(A[I]);
  end;
end;

procedure SetBlockKidsHeight0(const ID: Integer);
var
  I: Integer;
  A: TArrOfInd;
begin
  A := GetArrOfNodeKids(ID);
  for I := Low(A) to High(A) do
  begin
    SetBlockHeight(A[I], 0);
  end;
end;

procedure ChangeBlockInArray(ID: Integer; Info: TDataString); forward;

procedure DrawDiagram(); forward;

procedure DeleteBlock(const ID: Integer);
var
  ArrToShift: TArrOfLen_ID;
begin
  PrepareArrToShift(ID, ArrToShift);

  SetBlockHeight(ID, 0);
  SetBlockKidsHeight0(ID);
  ChangeBlockInArray(ID, '');
  ShiftBlocks(ID, ArrToShift);

  DeleteBlockKids(ID);
  DeleteBlockInArray(ID);
  DeleteNode(ID);

  frmMain.CurrBlockID := 0;
  DrawDiagram();
end;

procedure AllocateBlock(var Block: TImage); forward;

procedure ChangeBlockInArray(ID: Integer; Info: TDataString);
var
  NewWidth, BlockWidth: Integer;
  Block: TImage;
begin
  SetNodeCaption(ID, Info);
  NewWidth := GetCaptionWidth(Info, GetNodeType(ID));
  if NewWidth < StdWidth then
    NewWidth := StdWidth;
  SetNodePotentialDiagramWidth(ID, NewWidth);
  BlockWidth := GetBlockWidth(ID);
  if NewWidth > BlockWidth then
  begin
    CorrectDiagramWidth(ID, NewWidth);
  end
  else if NewWidth < BlockWidth then
  begin
    CorrectDiagramWidth(0, GetMaxPotentialDiagramWidth());
  end;
  SetNodePotentialDiagramWidth(ID, NewWidth);
  Block := GetBlock(ID);
  AllocateBlock(Block);
end;

procedure DrawDiagram();
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
  InsertNode(frmMain.CurrBlockID, NT,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  InsertBlockInArray(frmMain.CurrBlockID, NT);

  frmMain.BlockClick(GetBlock(GetNodeMaxID()));
end;

procedure AllocateBlock(var Block: TImage);
begin
  DrawDiagram();
  frmMain.CurrBlockID := Block.Tag;
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
  CurrBlockID := 0;
  SetLength(frmMain.Diagram, 1);
  CreateBlock(frmMain.Diagram[0], ntHead);
  with frmMain.Diagram[0] do
  begin
    left := StdLeft;
    Top := StdTop;
    Height := StdHeight;
    Width := StdWidth;
    Picture.Bitmap.Height := StdHeight;
    Picture.Bitmap.Width := StdWidth;
  end;
  frmMain.Diagram[0].Height := 0;
end;

procedure TfrmMain.ScrollBoxMainMouseWheelDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  ScrollBox: TScrollBox;
begin
  ScrollBox := Sender as TScrollBox;
  if ssShift in Shift then
    ScrollBox.HorzScrollBar.Position := ScrollBox.HorzScrollBar.Position + 20
  else
    ScrollBox.VertScrollBar.Position := ScrollBox.VertScrollBar.Position + 20;
end;

procedure TfrmMain.ScrollBoxMainMouseWheelUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
var
  ScrollBox: TScrollBox;
begin
  ScrollBox := Sender as TScrollBox;
  if ssShift in Shift then
    ScrollBox.HorzScrollBar.Position := ScrollBox.HorzScrollBar.Position - 20
  else
    ScrollBox.VertScrollBar.Position := ScrollBox.VertScrollBar.Position - 20;
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

procedure TfrmMain.actDiagramDeleteBlockExecute(Sender: TObject);
begin
  DeleteBlock(CurrBlockID);
end;

procedure TfrmMain.actDiagramEditBlockCaptionExecute(Sender: TObject);
var
  Caption: TDataString;
  bExit: Boolean;
begin
  SetEditCaption(GetNodeCaption(CurrBlockID));
  bExit := frmEditInfo.ShowModal <> mrOK;
  Caption := GetEditCaption();
  SetEditCaption('');
  if bExit then
    Exit;
  ChangeBlockInArray(CurrBlockID, Caption);
end;

procedure TfrmMain.ActionListMainUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin

  actDiagramEditBlockCaption.Enabled := (GetNodeType(CurrBlockID) <> ntHead);
  actDiagramDeleteBlock.Enabled := (actDiagramEditBlockCaption.Enabled) { and
    (GetNodeHead(CurrBlockID).next.data.ID <> CurrBlockID) };

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
