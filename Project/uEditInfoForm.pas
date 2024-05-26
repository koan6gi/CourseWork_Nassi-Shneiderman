unit uEditInfoForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls, uTreeRoutine;

type
  TfrmEditInfo = class(TForm)
    LabeledEditMain: TLabeledEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

  procedure SetEditCaption(const S: TDataString);
  function GetEditCaption(): TDataString;

var
  frmEditInfo: TfrmEditInfo;

implementation

procedure SetEditCaption(const S: TDataString);
begin
  frmEditInfo.LabeledEditMain.Text := String(S);
end;

function GetEditCaption(): TDataString;
begin
  result := TDataString(frmEditInfo.LabeledEditMain.Text);
end;

{$R *.dfm}

procedure TfrmEditInfo.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmEditInfo.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

procedure TfrmEditInfo.FormShow(Sender: TObject);
begin
  LabeledEditMain.SetFocus;
end;

end.
