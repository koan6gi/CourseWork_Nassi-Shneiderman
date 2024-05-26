object frmEditInfo: TfrmEditInfo
  Left = 0
  Top = 0
  BorderIcons = [biSystemMenu]
  BorderStyle = bsSingle
  Caption = 'frmEditInfo'
  ClientHeight = 230
  ClientWidth = 476
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poDesktopCenter
  OnShow = FormShow
  TextHeight = 15
  object LabeledEditMain: TLabeledEdit
    Left = 40
    Top = 56
    Width = 409
    Height = 23
    EditLabel.Width = 131
    EditLabel.Height = 15
    EditLabel.Caption = #1042#1074#1077#1076#1080#1090#1077' '#1080#1085#1092#1086#1088#1084#1072#1094#1080#1102'...'
    TabOrder = 0
    Text = ''
  end
  object btnOK: TButton
    Left = 72
    Top = 136
    Width = 113
    Height = 41
    Caption = #1054#1050
    Default = True
    TabOrder = 1
    OnClick = btnOKClick
  end
  object btnCancel: TButton
    Left = 296
    Top = 136
    Width = 113
    Height = 41
    Cancel = True
    Caption = #1054#1090#1084#1077#1085#1072
    TabOrder = 2
    OnClick = btnCancelClick
  end
end
