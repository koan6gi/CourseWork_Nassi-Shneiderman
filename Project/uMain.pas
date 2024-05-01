unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, System.Actions, Vcl.ActnList,
  Vcl.ToolWin, Vcl.ComCtrls, Vcl.Menus;

type
  TfrmMain = class(TForm)
    ActionListMain: TActionList;
    MainMenu: TMainMenu;
    tbMain: TToolBar;
    actFileNew: TAction;
    actFileOpen: TAction;
    actFileSave: TAction;
    actFileSaveAs: TAction;
    actEditUnDo: TAction;
    actEditReDo: TAction;
    actEditCut: TAction;
    actEditCopy: TAction;
    actEditPaste: TAction;
  private

  public

  end;

var
  frmMain: TfrmMain;

implementation

{$R *.dfm}

end.
