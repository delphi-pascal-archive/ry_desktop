unit Unit2;

{***********************************************************
  ������������ ���������� � ����� �������� ����� Windows

  ������� ��������, 2005
  ���������� ��� ����������� Delphi
  http://www.delphikingdom.com

  ������, ����������� �������� ���� - �������� ��������� ���
  ���� �������� ����, ������������ �������� �����. ���
  �������� ����� ������ ������������� �� ���.
 ***********************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TForm2 = class(TForm) {�������� ��������
  ��� �������� ����� ������ ������������� �� TForm2,
  �.�. File -> New -> Project1 -> Form2 -> inherited -> Ok}
  private
    procedure WMActivate(var Message: TWMActivate); message WM_ACTIVATE;
    procedure WMSysCommand(var Message: TMessage); message WM_SYSCOMMAND;
    procedure TWMWindowPosMsg(var Message: TWMWindowPosMsg); message WM_WINDOWPOSCHANGING;
  protected
    procedure CreateForm; virtual;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure DoClose(var Action: TCloseAction); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;

implementation

uses Unit1; {������-��, ���������� �� �������������, � �� �������������� �����
����� ��������������� property (��� ������������� �������� ����), �� �����
�������� ����������.

����� � ��������� ������� ��� � ������, � ���� ����� ��������� ��� ��� ����.}

{$R *.DFM}

{ TForm2 }

constructor TForm2.Create(AOwner: TComponent);
begin
  inherited;
  CreateForm;
  Form1.AddWnd(Caption, Self); {�������� ������� ����� � �������� ���� �����}
end;

procedure TForm2.CreateForm; {����� ��� ������� ����� ��. unit3}
begin
end;

procedure TForm2.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    WndParent := Form1.Handle; {��� �������� ����� ������ �� �������� ������������
    ������� �����. �������� ��������: ��� �� ���� ����� ��� � Form.Parent := OtherForm}
  end
end;

destructor TForm2.Destroy;
begin
  Form1.DelWnd(Self); {�������� ������� ����� �� ����������� ���� �����}
  inherited;
end;

procedure TForm2.DoClose(var Action: TCloseAction);
begin              
  if Action = caHide then ShowWindow(Handle, SW_HIDE); {�������� ����� �������� ����
  � ������� �� � ������, ��� ���� ��� ������������ ���������� ��������� �����.
  �������� � form3 ��� ��������� ��������� � ��� �������� �����
  ������������.}
end;

procedure TForm2.TWMWindowPosMsg(var Message: TWMWindowPosMsg);
//var
  //Rect: TRect;
begin
  inherited;
  if (GetWindowLong(Handle, GWL_STYLE) and WS_MAXIMIZE <> 0) then
  begin
    //SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0);
    Message.WindowPos.x := Form1.Left;
    Message.WindowPos.y := Form1.Top;
    Message.WindowPos.cx := Form1.Width;
    Message.WindowPos.cy := Form1.Height - 35; {�.�. � ���� � ���
    ��������� ������ "����", �� ��� ������ ���� �����}
    //Message.WindowPos.flags := SWP_NOMOVE;//NOREPOSITION;
  end;
end;

procedure TForm2.WMActivate(var Message: TWMActivate);
begin
  inherited;
  case Message.Active of
    WA_ACTIVE, WA_CLICKACTIVE: Form1.ActiveWnd(Self); {�������� ������� ����� �
    ��� ��� ��� ����� �������� �����}
  end;
end;

procedure TForm2.WMSysCommand(var Message: TMessage);
begin
  if (Message.WParam = SC_MINIMIZE) then {��� ����������� ����� ���������� ���
  ������� � �������� �����}
  begin
    ShowWindow(Handle, SW_HIDE);
    if not (IsWindowVisible(GetWindow(Handle, GW_HWNDNEXT)) or IsWindowVisible(GetWindow(Handle, GW_HWNDPREV))) then
      Windows.SetFocus(GetWindow(Handle, GW_OWNER)); {��� ����. �����, ������,
      ��� ������� ���������� �� �������� �������� ����, ������� �����
      ������ �����.}
  end else
    inherited {����� ��������� ������� �� ������� "��� ���� �� ���� ��
    �� �� �����������" :o) }
end;

end.
