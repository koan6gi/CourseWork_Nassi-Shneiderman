program CourseWork;

uses
  Vcl.Forms,
  uTreeRoutine in 'uTreeRoutine.pas',
  uMain in 'uMain.pas' {frmMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;

end.
