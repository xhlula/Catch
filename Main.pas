unit Main;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes,
  Vcl.Graphics, Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  IdHTTPServer, IdContext, IdCustomHTTPServer, IdBaseComponent, IdComponent, IdCustomTCPServer,
  inifiles, DateUtils, Vcl.ImgList, Vcl.ComCtrls, Vcl.ToolWin;

type
  TMainForm = class(TForm)
    Panel2: TPanel;
    indyServer: TIdHTTPServer;
    dialogBox: TFileOpenDialog;
    display: TMemo;
    Panel3: TPanel;
    edtPath: TButtonedEdit;
    Label1: TLabel;
    edtPass: TEdit;
    CheckBox1: TCheckBox;
    Label2: TLabel;
    ImageList1: TImageList;
    ToolBar1: TToolBar;
    btnStart: TToolButton;
    btnStop: TToolButton;
    btnSave: TToolButton;
    ilLarge: TImageList;
    TrayIcon1: TTrayIcon;
    procedure indyServerCommandGet(AContext: TIdContext;
      ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
    procedure FormCreate(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure edtPathRightButtonClick(Sender: TObject);
    procedure btnStartClick(Sender: TObject);
    procedure btnSaveClick(Sender: TObject);
    procedure btnStopClick(Sender: TObject);
    procedure TrayIcon1DblClick(Sender: TObject);
  {$ENDREGION}
  private
    function GetConfigIni: TIniFile;

    procedure StringToFile(const AString, AFile: string);
    procedure Log(const AMessage: string);

    function GetConfig(const AIdent: string; ADefault: string = ''): string;
    procedure SetConfig(const AIdent, AValue: string);

    procedure SaveRequestMessage(const RequestMessage: string);
  public
  end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
  if (Sender as TCheckBox).Checked then
    edtPass.PasswordChar := #0
  else
    edtPass.PasswordChar := '*';
end;

procedure TMainForm.edtPathRightButtonClick(Sender: TObject);
begin
  if not dialogBox.Execute then
    Exit;

  edtPath.Text := dialogBox.FileName;
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  WindowState := wsMinimized;
  Hide;

  edtPath.Text := GetConfig('Path');
  edtPass.Text := GetConfig('Password');

  btnStart.Click;
end;

procedure TMainForm.indyServerCommandGet(AContext: TIdContext;
  ARequestInfo: TIdHTTPRequestInfo; AResponseInfo: TIdHTTPResponseInfo);
begin
  if ARequestInfo.CommandType <> hcPOST then
    Exit;

  Log('Incoming request from ' + ARequestInfo.Host);

  try
    if ARequestInfo.Params.Values['password'] <> GetConfig('Password') then
    begin
      Log('Invalid password');
      Exit;
    end;
  except
    Log('Invalid password');
  end;  

  Log('Message: ' + ARequestInfo.Params.Values['data']);
  SaveRequestMessage(ARequestInfo.Params.Values['data']);
end;

procedure TMainForm.Log(const AMessage: string);
begin
  display.Lines.Add(Format('%s - %s', [
    FormatDateTime('dd/mm/yyyy hh:mm:ss', Now),
    AMessage
  ]));
end;

procedure TMainForm.SaveRequestMessage(const RequestMessage: string);
var
  TargetFileName: string;
begin
  TargetFileName := Format('%s\%d.txt', [
    ExcludeTrailingPathDelimiter(GetConfig('Path')),
    DateTimeToUnix(Now)
  ]);

  StringToFile(RequestMessage, TargetFileName);
end;

procedure TMainForm.SetConfig(const AIdent, AValue: string);
begin
  with GetConfigIni do
  try
    WriteString('Info', AIdent, AValue);
  finally
    Free;
  end;
end;

procedure TMainForm.StringToFile(const AString, AFile: string);
begin
  with TStringList.Create do
  try
    Text := AString;

    SaveToFile(AFile);
  finally
    Free;
  end;  
end;

procedure TMainForm.TrayIcon1DblClick(Sender: TObject);
begin
  Show;
  Application.Restore;
end;

procedure TMainForm.btnStartClick(Sender: TObject);
begin
  try
    indyServer.Active := True;

    Log('Server started');

    btnStart.Enabled := False;
    btnStop.Enabled := True;
  except on E: Exception do
    begin
      MessageDlg('Error while starting server', mtError, [mbOK], 0);
      Log(E.Message);
    end;
  end;
end;

procedure TMainForm.btnStopClick(Sender: TObject);
begin
  try
    indyServer.Active := False;

    Log('Server stopped');

    btnStart.Enabled := True;
    btnStop.Enabled := False;
  except on E: Exception do
    begin
      MessageDlg('Error while stoping server', mtError, [mbOK], 0);

      Log(E.Message);
    end;
  end;
end;

procedure TMainForm.btnSaveClick(Sender: TObject);
begin
  SetConfig('Password', edtPass.Text);
  SetConfig('Path', edtPath.Text);
end;

function TMainForm.GetConfig(const AIdent: string; ADefault: string = ''): string;
begin
  with GetConfigIni do
  try
    Result := ReadString('Info', AIdent, ADefault);
  finally
    Free;
  end;
end;

function TMainForm.GetConfigIni: TIniFile;
begin
  Result := TIniFile.Create(IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'app.ini');
end;

end.
