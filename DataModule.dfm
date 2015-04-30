object DM: TDM
  OldCreateOrder = False
  Height = 320
  Width = 478
  object indyServer: TIdHTTPServer
    Bindings = <>
    OnCommandGet = indyServerCommandGet
    Left = 56
    Top = 64
  end
end
