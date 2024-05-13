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
  private

  public
    Diagram: array of TImage;
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

const
  EditInfoMessages: array [TNodeType] of String = ('', '¬ведите текст',
    '¬ведите условие', '¬ведите условие входа в цикл',
    '¬ведите условие выхода из цикла');

var
  StdLeft: Integer = 150;
  StdWidth: Integer = 150;
  StdHeight: Integer = 50;
  StdTop: Integer = 10;
  CurrBlockID: Integer = 0;

Type
  TPaintBlock = procedure(var Block: TImage);

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
    Block.Canvas.Rectangle(Width div 5, Height div 3, Width, Height);
  end;
end;

procedure PaintRepeatBlock(var Block: TImage);
begin
  with Block, Picture.Bitmap do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
    Block.Canvas.Rectangle(Width div 5, 2 * Height div 3, Width, 0);
  end;
end;

Procedure PaintHead(Var Block: TImage);
begin
  with Block, Picture.Bitmap do
  begin
    Canvas.Pen.Color := clBlack;
    Block.Canvas.Rectangle(0, 0, Width, Height);
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

procedure CreateBlock(var Block: TImage; const NT: TNodeType;
  Owner: TWinControl);
var
  CountOfBranch: Integer;
begin
  Block := TImage.Create(Owner);
  Block.Parent := Owner;
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
    OnDblClick := frmMain.BlockDblClick;
    OnClick := frmMain.BlockClick;

    Visible := True;
    Show;
    PaintBlock[NT](Block);
  end;

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

procedure InsertBlockInArray(ID: Integer; NT: TNodeType; Info: TDataString);
var
  I, k: Integer;
  temp, Block: TImage;
  IHeight, IWidth, IDOfNewBlock: Integer;
  CurrNodeType: TNodeType;
  Arr: TArrOfInd;
begin
  IHeight := 0;
  k := 0;
  IDOfNewBlock := 0;
  CurrNodeType := GetNodeType(CurrBlockID);
  for I := Low(frmMain.Diagram) to High(frmMain.Diagram) do
    if ID = frmMain.Diagram[I].Tag then
    begin
      StdTop := frmMain.Diagram[I].Top;
      if CurrNodeType <> ntHead then
        StdTop := frmMain.Diagram[I].Top + frmMain.Diagram[I].Height;
      CreateBlock(temp, NT, frmMain.ScrollBoxMain);
      IDOfNewBlock := temp.Tag;
      temp.Left := frmMain.Diagram[I].Left;
      Insert(temp, frmMain.Diagram, I + 1);

      IHeight := temp.Height;

      case NT of
        ntIF:
          begin
            Inc(k, 2);
            CreateBlock(Block, ntHead, frmMain.ScrollBoxMain);
            Block.Tag := Block.Tag - 1;
            Block.Top := Block.Top + temp.Height;
            Block.Left := temp.Left;
            Insert(Block, frmMain.Diagram, I + 2);
            IWidth := Block.Width;

            CreateBlock(Block, ntHead, frmMain.ScrollBoxMain);
            Block.Left := temp.Left + IWidth;
            Block.Top := Block.Top + temp.Height;
            Insert(Block, frmMain.Diagram, I + 3);

            temp.Height := temp.Height + IHeight;

            Inc(IHeight, Block.Height);
          end;
        ntWhile:
          begin

          end;
        ntRepeat:
          begin

          end;
      end;

      Inc(k, I + 2);
      break;
    end;

  PaintBlock[GetNodeType(frmMain.Diagram[k - 1].Tag)](frmMain.Diagram[k - 1]);

  if CurrNodeType <> ntHead then
  begin
    Arr := GetArrOfNextElementsInd(IDOfNewBlock);
    for I := Low(Arr) to High(Arr) do
      frmMain.Diagram[Arr[I]].Top := frmMain.Diagram[Arr[I]].Top + IHeight;
  end;

end;

procedure ChangeBlockInArray(ID: Integer; Info: TDataString);
// var
// i: Integer;
begin

end;

procedure MakeWhite();
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

{ TfrmMain }

procedure TfrmMain.BlockDblClick(Sender: TObject);
var
  Block: TImage;
begin
  Block := GetBlock(CurrBlockID);
  if Block <> nil then
    frmMain.actDiagramEditBlockCaptionExecute(Block);
end;

procedure TfrmMain.frmMainCreate(Sender: TObject);
begin
  SetLength(frmMain.Diagram, 1);
  StdHeight := 0;
  CreateBlock(frmMain.Diagram[0], ntHead, frmMain.ScrollBoxMain);
  StdHeight := 50;
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
begin
  MakeWhite();
  CurrBlockID := (Sender as TImage).Tag;
  with (Sender as TImage) do
  begin
    Canvas.Brush.Color := clYellow;
    PaintBlock[GetNodeType(TImage(Sender).Tag)](TImage(Sender));
    Canvas.Brush.Color := clWhite;
  end;

end;

end.
