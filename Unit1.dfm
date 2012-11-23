object Form1: TForm1
  Left = 192
  Top = 124
  Width = 1142
  Height = 656
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Panel1: TPanel
    Left = 0
    Top = 0
    Width = 1126
    Height = 81
    Align = alTop
    BorderWidth = 10
    TabOrder = 0
    object lblEstimatedTime: TLabel
      Left = 128
      Top = 19
      Width = 10
      Height = 19
      Font.Charset = ANSI_CHARSET
      Font.Color = clBlack
      Font.Height = -16
      Font.Name = 'Letter Gothic Std'
      Font.Style = []
      ParentFont = False
    end
    object btnStart: TButton
      Left = 16
      Top = 16
      Width = 97
      Height = 25
      Caption = 'Start simulation'
      TabOrder = 0
      OnClick = btnStartClick
    end
    object ProgressBar1: TProgressBar
      Left = 11
      Top = 53
      Width = 1104
      Height = 17
      Align = alBottom
      Smooth = True
      TabOrder = 1
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 81
    Width = 1126
    Height = 537
    Align = alClient
    BorderWidth = 10
    TabOrder = 1
    object memo: TRichEdit
      Left = 11
      Top = 11
      Width = 1104
      Height = 515
      Align = alClient
      Font.Charset = RUSSIAN_CHARSET
      Font.Color = clWindowText
      Font.Height = -11
      Font.Name = 'Myriad Pro Cond'
      Font.Style = []
      ParentFont = False
      TabOrder = 0
    end
  end
  object tmrEstimator: TTimer
    Enabled = False
    OnTimer = tmrEstimatorTimer
    Left = 24
    Top = 104
  end
end
