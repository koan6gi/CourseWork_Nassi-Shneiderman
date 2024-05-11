unit uEditInfoForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.Mask, Vcl.ExtCtrls;

type
  TfrmEditInfo = class(TForm)
    LabeledEditMain: TLabeledEdit;
    btnOK: TButton;
    btnCancel: TButton;
    procedure btnOKClick(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmEditInfo: TfrmEditInfo;

implementation

{$R *.dfm}

procedure TfrmEditInfo.btnCancelClick(Sender: TObject);
begin
  ModalResult := mrCancel;
end;

procedure TfrmEditInfo.btnOKClick(Sender: TObject);
begin
  ModalResult := mrOK;
end;

end.
