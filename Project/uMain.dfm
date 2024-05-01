object frmMain: TfrmMain
  Left = 0
  Top = 0
  Caption = 'Nassi-Shneiderman diagram'
  ClientHeight = 519
  ClientWidth = 882
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Menu = MainMenu
  TextHeight = 15
  object tbMain: TToolBar
    Left = 0
    Top = 0
    Width = 882
    Height = 33
    TabOrder = 0
  end
  object ActionListMain: TActionList
    Left = 676
    Top = 4
    object actFileNew: TAction
      Category = 'File'
      Caption = #1057#1086#1079#1076#1072#1090#1100
      ShortCut = 16462
    end
    object actFileOpen: TAction
      Category = 'File'
      Caption = #1054#1090#1082#1088#1099#1090#1100'...'
      ShortCut = 16463
    end
    object actFileSave: TAction
      Category = 'File'
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100
      ShortCut = 16467
    end
    object actFileSaveAs: TAction
      Category = 'File'
      Caption = #1057#1086#1093#1088#1072#1085#1080#1090#1100' '#1082#1072#1082'...'
      ShortCut = 49235
    end
    object actEditUnDo: TAction
      Category = 'Edit'
      Caption = #1054#1090#1084#1077#1085#1080#1090#1100
      ShortCut = 16474
    end
    object actEditReDo: TAction
      Category = 'Edit'
      Caption = #1055#1086#1074#1090#1086#1088#1080#1090#1100
      ShortCut = 49242
    end
    object actEditCut: TAction
      Category = 'Edit'
      Caption = #1042#1099#1088#1077#1079#1072#1090#1100
      ShortCut = 16472
    end
    object actEditCopy: TAction
      Category = 'Edit'
      Caption = #1050#1086#1087#1080#1088#1086#1074#1072#1090#1100
      ShortCut = 16451
    end
    object actEditPaste: TAction
      Category = 'Edit'
      Caption = #1042#1089#1090#1072#1074#1080#1090#1100
      ShortCut = 16470
    end
  end
  object MainMenu: TMainMenu
    Left = 792
  end
end
