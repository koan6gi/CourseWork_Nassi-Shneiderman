program CourseWork;

uses
  Vcl.Forms,
  uTreeRoutine in 'uTreeRoutine.pas',
  uMain in 'uMain.pas' {frmMain} ,
  uEditInfoForm in 'uEditInfoForm.pas' {frmEditInfo};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmEditInfo, frmEditInfo);
  Application.Run;

end.
