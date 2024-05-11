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
    menuAdd: TMenuItem;
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
    Image1: TImage;
    procedure BlockDblClick(Sender: TObject);
    procedure BlockClick(Sender: TObject);
    procedure actDiagramAddProcessExecute(Sender: TObject);
    procedure actDiagramAddIFExecute(Sender: TObject);
    procedure actDiagramAddWhileExecute(Sender: TObject);
    procedure actDiagramAddRepeatExecute(Sender: TObject);
    procedure frmMainCreate(Sender: TObject);
    procedure ActionListMainChange(Sender: TObject);
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
  StdHeight: Integer = 100;
  StdTop: Integer = 10;
  CurrBlockID: Integer = 0;
  // CurrClick: TPoint;

Type
  TPaintBlock = procedure(var Block: TImage);

procedure PaintProcessBlock(var Block: TImage);
begin
  with Block do
  begin
    Canvas.Pen.Color := clBlack;
    Block.Canvas.Rectangle(0, 0, Width, Height);
  end;
end;

procedure PaintIFBlock(var Block: TImage);
var
  y: Integer;
  Tr: Array [1 .. 3] of TPoint;
begin
  with Block do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
    y := Height div 2;
    Canvas.MoveTo(0, y);
    Canvas.LineTo(Width, y);
    Tr[1].Create(0, 0);
    Tr[2].Create(Width, 0);
    Tr[3].Create(Width div 2, Height div 2);
    Canvas.Polygon(Tr);
    Canvas.MoveTo(Width div 2, Height div 2);
    Canvas.LineTo(Width div 2, Height);
  end;
end;

procedure PaintWhileBlock(var Block: TImage);
begin
  with Block do
  begin
    Block.Canvas.Rectangle(0, 0, Block.Width, Height);
    Block.Canvas.Rectangle(Width div 5, Height div 3, Width, Height);
  end;
end;

procedure PaintRepeatBlock(var Block: TImage);
begin
  with Block do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
    Block.Canvas.Rectangle(Width div 5, 2 * Height div 3, Width, 0);
  end;
end;

Procedure PaintHead(Var Block: TImage);
begin
  Block.Height := 0;
end;

const
  PaintBlock: array [TNodeType] of TPaintBlock = (PaintHead, PaintProcessBlock,
    PaintIFBlock, PaintWhileBlock, PaintRepeatBlock);

procedure CreateBlock(var Block: TImage; NT: TNodeType);
begin
  Block := TImage.Create(frmMain.ScrollBoxMain);
  with Block do
  begin
    Parent := frmMain.ScrollBoxMain;

    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Color := clWhite;

    SetBounds(StdLeft, StdTop, StdWidth, StdHeight);

    //AutoSize := true;

    Block.Picture.Bitmap.Height := StdHeight;
    Block.Picture.Bitmap.Width := StdWidth;

    Tag := Diagrams.data.ID;
    OnDblClick := frmMain.BlockDblClick;
    OnClick := frmMain.BlockClick;

    Visible := True;
    Show;
  end;

end;

procedure InsertBlockInArray(ID: Integer; NT: TNodeType; Info: TDataString);
var
  i, k: Integer;
  temp: TImage;
  IHeight: Integer;
begin
  IHeight := 0;
  k := 0;
  for i := Low(frmMain.Diagram) to High(frmMain.Diagram) do
    if ID = frmMain.Diagram[i].Tag then
    begin
      StdTop := frmMain.Diagram[i].Top + frmMain.Diagram[i].Height;
      CreateBlock(temp, NT);
      Insert(temp, frmMain.Diagram, i + 1);
      IHeight := temp.Height;
      k := i + 2;
      Break;
    end;
  PaintBlock[GetNodeType(frmMain.Diagram[k - 1].Tag)](frmMain.Diagram[k - 2]);
  frmMain.BlockClick(temp);

  for i := k to High(frmMain.Diagram) do
    frmMain.Diagram[i].Top := frmMain.Diagram[i].Top + IHeight;
  // PaintBlock[NT](temp);

  with frmMain.Diagram[High(frmMain.Diagram)] do
    StdTop := Top + Height;

end;

procedure ChangeBlockInArray(ID: Integer; Info: TDataString);
// var
// i: Integer;
begin

end;

procedure MakeWhite();
var
  i: Integer;
begin
  with frmMain do
    for i := Low(Diagram) to High(Diagram) do
    begin
      Diagram[i].Canvas.Brush.Color := clWhite;
      PaintBlock[GetNodeType(Diagram[i].Tag)](Diagram[i]);
    end;
end;

{ TfrmMain }

procedure PaintDiagram();
var
  i: Integer;
begin
  for i := Low(frmMain.Diagram) to High(frmMain.Diagram) do
    PaintBlock[GetNodeType(frmMain.Diagram[i].Tag)](frmMain.Diagram[i]);
end;

procedure TfrmMain.BlockDblClick(Sender: TObject);
begin
  frmEditInfo.LabeledEditMain.Text := '';
  if frmEditInfo.ShowModal <> mrOK then
    Exit;

end;

procedure TfrmMain.frmMainCreate(Sender: TObject);
begin
  SetLength(frmMain.Diagram, 1);
  CreateBlock(frmMain.Diagram[0], ntHead);
  frmMain.Diagram[0].Height := 0;
end;

procedure TfrmMain.actDiagramAddIFExecute(Sender: TObject);
begin
  InsertBlockInTree(CurrBlockID, ntIF,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  InsertBlockInArray(CurrBlockID, ntIF,
    TDataString(frmEditInfo.LabeledEditMain.Text));
end;

procedure TfrmMain.actDiagramAddProcessExecute(Sender: TObject);
begin
  InsertBlockInTree(CurrBlockID, ntProcess,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  InsertBlockInArray(CurrBlockID, ntProcess,
    TDataString(frmEditInfo.LabeledEditMain.Text));
end;

procedure TfrmMain.actDiagramAddRepeatExecute(Sender: TObject);
begin
  InsertBlockInTree(CurrBlockID, ntRepeat,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  InsertBlockInArray(CurrBlockID, ntRepeat,
    TDataString(frmEditInfo.LabeledEditMain.Text));
end;

procedure TfrmMain.actDiagramAddWhileExecute(Sender: TObject);
begin
  InsertBlockInTree(CurrBlockID, ntWhile,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  InsertBlockInArray(CurrBlockID, ntWhile,
    TDataString(frmEditInfo.LabeledEditMain.Text));
end;

procedure TfrmMain.ActionListMainChange(Sender: TObject);
begin
  PaintDiagram();
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
