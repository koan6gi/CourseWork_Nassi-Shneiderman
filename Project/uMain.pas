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
    procedure BlockDblClick(Sender: TObject);
  private

  public
    Diagram: array of TPaintBox;
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
  StdLeft: Integer = 50;
  StdWidth: Integer = 150;
  StdHeight: Integer = 50;
  StdTop: Integer = 10;

Type
  TPaintBlock = procedure(var Block: TPaintBox);

procedure PaintProcessBlock(var Block: TPaintBox);
begin
  with Block do
  begin
    Height := Height div 2;
    Block.Canvas.Rectangle(0, 0, Width, Height);
  end;
end;

procedure PaintIFBlock(var Block: TPaintBox);
begin
  with Block do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
  end;
end;

procedure PaintWhileBlock(var Block: TPaintBox);
begin
  with Block do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
  end;
end;

procedure PaintRepeatBlock(var Block: TPaintBox);
begin
  with Block do
  begin
    Block.Canvas.Rectangle(0, 0, Width, Height);
  end;
end;

const
  PaintBlock: array [TNodeType] of TPaintBlock = (nil, PaintProcessBlock,
    PaintIFBlock, PaintWhileBlock, PaintRepeatBlock);

procedure CreateBlock(var Block: TPaintBox; NT: TNodeType);
begin
  Block := TPaintBox.Create(frmMain.ScrollBoxMain);
  with Block do
  begin
    Top := StdTop;
    Left := StdLeft;
    Height := 2 * StdHeight;
    Width := StdWidth;
  end;

  PaintBlock[NT](Block);

  with Block do
  begin
    StdTop := Top + Height;
  end;
end;

procedure InsertBlockInArray(ID: Integer; NT: TNodeType; Info: TDataString);
var
  i: Integer;
  temp: TPaintBox;
begin
  CreateBlock(temp, NT);
  for i := Low(frmMain.Diagram) to High(frmMain.Diagram) do
    if ID = frmMain.Diagram[i].Tag then
    begin
      Insert(temp, frmMain.Diagram, i + 1)
    end;

end;

{ TfrmMain }

procedure TfrmMain.BlockDblClick(Sender: TObject);
begin
  if frmEditInfo.ShowModal <> mrOK then
    Exit;
  InsertBlockInTree((Sender as TPaintBox).Tag, ntProcess,
    TDataString(frmEditInfo.LabeledEditMain.Text));

  InsertBlockInArray((Sender as TPaintBox).Tag, ntProcess,
    TDataString(frmEditInfo.LabeledEditMain.Text));

end;

end.
