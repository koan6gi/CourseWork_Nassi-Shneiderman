unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, System.UITypes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.Menus, System.ImageList, Vcl.ImgList,
  uTreeRoutine, uEditInfoForm, Vcl.ExtCtrls, Vcl.StdCtrls, uFileRoutine;

type
  TfrmMain = class(TForm)
    ActionListMain: TActionList;
    MainMenu: TMainMenu;
    ToolBarMain: TToolBar;
    actFileNew: TAction;
    actFileOpen: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
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
    OpenDialogMain: TOpenDialog;
    SaveDialogMain: TSaveDialog;
    ToolButton1: TToolButton;
    tbDiagramEditBlock: TToolButton;
    tbSeparator2: TToolButton;
    tbDiagramDeleteBlock: TToolButton;
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
    procedure actFileSaveExecute(Sender: TObject);
    procedure actFileOpenExecute(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure actFileSaveAsExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure actFileNewExecute(Sender: TObject);
  private
    IsDiagramHaveChanged: Boolean;
  public
    Diagram: TArrOfBlock;
    CurrBlockID: Integer;
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
function GetDiagramWidth(): Integer;
function GetDiagramHeight(): Integer;
procedure DrawDiagram();
procedure AllocateBlock(var Block: TImage);
function GetBlock(const ID: Integer): TImage;
procedure InsertBlockInArray(const ParentID, ID: Integer; const NT: TNodeType);
procedure ChangeBlockInArray(ID: Integer; Info: TDataString);

implementation

uses FileCtrl;

{$R *.dfm}

const
  EditInfoMessages: array [TNodeType] of String = ('', 'Введите текст',
    'Введите условие', 'Введите условие входа в цикл',
    'Введите условие выхода из цикла');
  MaxWidthSize = 4500;

Type
  TPaintBlock = procedure(var Block: TImage);

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
  result := frmMain.Diagram[0].Canvas.TextWidth(String(Caption));
  if NT = ntHead then
  begin
    result := StdWidth;
    Exit;
  end
  else if NT = ntIF then
    result := round(result * 1.5);
  result := result + 2 * StdTextIndent;
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
  Caption: TDataString;
begin
  Caption := GetNodeCaption(Block.Tag);
  with Block, Picture.Bitmap do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
    Tr[1].Create(0, 0);
    Tr[2].Create(Width, 0);
    Tr[3].Create(Width div 2, Height);
    Canvas.Polygon(Tr);

    Block.Canvas.TextOut((Width - Canvas.TextWidth(String(Caption))) div 2,
      (Height - Canvas.TextHeight(String(Caption))) div 2 - StdHeight div 2,
      String(Caption));

    Block.Canvas.TextOut((Width div 2 - Canvas.TextWidth('1')) div 2,
      StdHeight + (Height div 2 - Canvas.TextHeight(String(Caption)))
      div 2, '1');

    Block.Canvas.TextOut((3 * Width div 2 - Canvas.TextWidth('0')) div 2,
      StdHeight + (Height div 2 - Canvas.TextHeight(String(Caption)))
      div 2, '0');
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

procedure PaintHead(Var Block: TImage);
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

procedure CreateBlock(var Block: TImage; const ID: Integer;
  const NT: TNodeType);
begin
  Block := TImage.Create(frmMain.ScrollBoxMain);
  Block.Parent := frmMain.ScrollBoxMain;
  SetTextSettings(Block);
  with Block do
  begin
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := clWhite;

    Tag := ID;
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
  const ParentID, ID: Integer);
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

  CreateBlock(Block, ID, NT);
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
        Block.Picture.Bitmap.Width := Block.Width;
        Block.Height := Block.Height + 2 * StdHeight;
        Block.Picture.Bitmap.Height := 2 * StdHeight;

        // Создание подветвей
        KidWidth := Block.Width div 2;
        CreateBlock(tempHead, ID + 1, ntHead);
        tempHead.Top := Block.Top + 2 * StdHeight;
        tempHead.left := ParentLeft;
        tempHead.Height := StdHeight;
        tempHead.Picture.Bitmap.Height := tempHead.Height;
        tempHead.Width := KidWidth;
        tempHead.Picture.Bitmap.Width := KidWidth;
        Insert(tempHead, frmMain.Diagram, Length(frmMain.Diagram));

        CreateBlock(tempHead, ID + 2, ntHead);
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
        Block.Picture.Bitmap.Width := Block.Width;
        Block.Height := Block.Height + StdHeight;
        Block.Picture.Bitmap.Height := Block.Height;

        // Создание подветвей
        KidWidth := Block.Width - StdWidthCycleBoard;
        CreateBlock(tempHead, ID + 1, ntHead);
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

        Block.Picture.Bitmap.Width := Block.Width;
        Block.Height := Block.Height + StdHeight;
        Block.Picture.Bitmap.Height := Block.Height;

        // Создание подветвей
        KidWidth := Block.Width - StdWidthCycleBoard;
        CreateBlock(tempHead, ID + 1, ntHead);
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

procedure InsertBlockInArray(const ParentID, ID: Integer; const NT: TNodeType);
var
  ArrToShift: TArrOfLen_ID;
  Block: TImage;
begin
  PrepareArrToShift(ParentID, ArrToShift);
  CorrectBlock(Block, NT, ParentID, ID);
  with frmMain do
    Qsort(Diagram, Low(Diagram), High(Diagram));
  CorrectDiagramWidth(ID, GetBlockWidth(ID));
  ShiftBlocks(ID, ArrToShift);
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
  DrawDiagram();
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
var
  IDOfNewBlock: Integer;
begin
  if GetDiagramWidth() >= MaxWidthSize then
  begin
    if (NT = ntIF) or (NT = ntWhile) or (NT = ntRepeat) then
    begin
      ShowMessage
        ('Схема слишком широкая. Вставка ветвлений и циклов приостановлена. Подумайте над оптимизацией алгоритма.');
      Exit;
    end;
  end;
  InsertNode(frmMain.CurrBlockID, NT,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  IDOfNewBlock := GetNodeMaxID();
  if NT = ntIF then
    Dec(IDOfNewBlock, 2)
  else if (NT = ntWhile) or (NT = ntRepeat) then
    Dec(IDOfNewBlock);

  InsertBlockInArray(frmMain.CurrBlockID, IDOfNewBlock, NT);

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

function ShowSaveQuestion(): TmodalResult;
begin
  result := MessageDlg('Сохранить изменения?', TMsgDlgType.mtConfirmation,
    mbYesNoCancel, 0);
end;

{ TfrmMain }

procedure TfrmMain.frmMainCreate(Sender: TObject);
begin
  IsDiagramHaveChanged := false;
  CreateHead(TreeDiagram);
  CurrBlockID := 0;
  SetLength(frmMain.Diagram, 1);
  CreateBlock(frmMain.Diagram[0], 0, ntHead);
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

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
var
  I: Integer;
begin
  for I := Low(Diagram) to High(Diagram) do
  begin
    Diagram[I].Free;
  end;
  SetLength(Diagram, 0);
  FreeDiagram(TreeDiagram);
end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  buttonSelected: Integer;
begin
  CanClose := true;
  if IsDiagramHaveChanged then
  begin
    buttonSelected := ShowSaveQuestion();
    if buttonSelected = mrYes then
    begin
      actFileSaveExecute(actFileSave);
    end
    else if buttonSelected = mrCancel then
    begin
      CanClose := false;
    end;
  end;

end;

procedure TfrmMain.actDiagramAddProcessExecute(Sender: TObject);
begin
  IsDiagramHaveChanged := true;
  InsertBlockInDiagram(ntProcess);
end;

procedure TfrmMain.actDiagramAddIFExecute(Sender: TObject);
begin
  IsDiagramHaveChanged := true;
  InsertBlockInDiagram(ntIF);
end;

procedure TfrmMain.actDiagramAddRepeatExecute(Sender: TObject);
begin
  IsDiagramHaveChanged := true;
  InsertBlockInDiagram(ntRepeat);
end;

procedure TfrmMain.actDiagramAddWhileExecute(Sender: TObject);
begin
  IsDiagramHaveChanged := true;
  InsertBlockInDiagram(ntWhile);
end;

procedure TfrmMain.actDiagramDeleteBlockExecute(Sender: TObject);
begin
  IsDiagramHaveChanged := true;
  ScrollBoxMain.HorzScrollBar.Position := 0;
  DeleteBlock(CurrBlockID);
end;

procedure TfrmMain.actDiagramEditBlockCaptionExecute(Sender: TObject);
var
  Caption: TDataString;
  bExit: Boolean;
begin
  SetEditLable(EditInfoMessages[GetNodeType(CurrBlockID)]);
  SetEditCaption(GetNodeCaption(CurrBlockID));
  bExit := frmEditInfo.ShowModal <> mrOk;
  Caption := GetEditCaption();
  SetEditCaption('');
  if bExit then
    Exit;
  ScrollBoxMain.HorzScrollBar.Position := 0;
  ChangeBlockInArray(CurrBlockID, Caption);
  IsDiagramHaveChanged := true;
end;

procedure TfrmMain.actFileNewExecute(Sender: TObject);
var
  IsSave: Integer;
  Act: TCloseAction;
begin
  if IsDiagramHaveChanged then
  begin
    IsSave := ShowSaveQuestion();
    if IsSave = mrCancel then
      Exit;
    if IsSave = mrYes then
      actFileSaveExecute(actFileSave);
  end;

  FormClose(Sender, Act);
  frmMainCreate(Sender);
end;

procedure TfrmMain.actFileOpenExecute(Sender: TObject);
var
  IsOpenEnable: Boolean;
  IsSave: Integer;
  Act: TCloseAction;
begin
  if ((SavePath <> '') or (Length(Diagram) > 1)) and IsDiagramHaveChanged then
  begin
    IsSave := ShowSaveQuestion();
    if IsSave = mrCancel then
      Exit;
    if IsSave = mrYes then
      actFileSaveExecute(actFileSave);
  end;

  IsOpenEnable := OpenDialogMain.Execute;

  if IsOpenEnable then
  begin
    IsDiagramHaveChanged := false;
    FormClose(Sender, Act);
    frmMainCreate(Sender);
    SetOpenPath(OpenDialogMain.FileName);
    OpenDiagram();
    DrawDiagram();
    SetSavePath(OpenDialogMain.FileName);
    SaveDialogMain.FileName := OpenDialogMain.FileName;
  end;

end;

procedure TfrmMain.actFileSaveAsExecute(Sender: TObject);
begin
  SetSavePath('');
  actFileSaveExecute(actFileSave);
end;

procedure TfrmMain.actFileSaveExecute(Sender: TObject);
var
  IsSaveEnable: Boolean;
begin
  if SavePath = '' then
  begin
    IsSaveEnable := SaveDialogMain.Execute;
  end
  else
  begin
    IsSaveEnable := true;
  end;

  if IsSaveEnable then
  begin
    SetSavePath(SaveDialogMain.FileName);
    with ScrollBoxMain do
    begin
      VertScrollBar.Position := 0;
      HorzScrollBar.Position := 0;
    end;

    SaveDiagram();
    ShowMessage('Изменения сохранены.');
    IsDiagramHaveChanged := false;
  end;

end;

procedure TfrmMain.ActionListMainUpdate(Action: TBasicAction;
  var Handled: Boolean);
begin

  actDiagramEditBlockCaption.Enabled := (GetNodeType(CurrBlockID) <> ntHead);
  actDiagramDeleteBlock.Enabled := (actDiagramEditBlockCaption.Enabled) and
    (GetCountNodeInBranch(CurrBlockID) > 2);

  actDiagramAddProcess.Enabled :=
    not((Length(Diagram) = 2) and (GetNodeType(CurrBlockID) = ntHead));
  actDiagramAddIF.Enabled := actDiagramAddProcess.Enabled;
  actDiagramAddWhile.Enabled := actDiagramAddProcess.Enabled;
  actDiagramAddRepeat.Enabled := actDiagramAddProcess.Enabled;

  actFileSave.Enabled := Length(Diagram) > 1;
  actFileSaveAs.Enabled := actFileSave.Enabled and (SavePath <> '');
end;

procedure TfrmMain.BlockClick(Sender: TObject);
var
  Block: TImage;
begin
  Block := Sender as TImage;
  AllocateBlock(Block);
end;

end.
