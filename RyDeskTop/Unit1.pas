unit Unit1;

{*******************************************************************************
  ������������ ���������� � ����� �������� ����� Windows.

  ������� ��������, 2005
  ���������� ��� ����������� Delphi http://www.delphikingdom.com

  ------------------------------------------------------------------------------

  ������ ����������������� ������� - 1.5 [������ ������� ����������
                                          � �����������]
  ������ �������������� ��������� ��. � RyComponents.pas

  �������� �� Delphi5.
  ������ ��������� ��������� � �������� � Win98 � � WinXP.

  ------------------------------------------------------------------------------

  ������������������ ������� �� ������ ��������, �� ���� ������
  ����������. ������� � �������� ���������������� ������� ��
  ����� ������ ����������� ���.

  ������, ����������� ������� ���� ��������� - ����������
  ������� ����.
*******************************************************************************}


{----- HISTORY -----------------------------------------------------------------
  [@] ��. ����� history � rycomponents.pas

  [*] ������������� ��������� ����������.
  [*] ��������������� ������������ ��������� �������/��������.
  [*] � Tag ��� ������� ���� � ������ �� TaskBar'� ������������ �� ���������
      �� ��������������� �����, � �� index ����� � ������ �������� ����
      (ChildForm[�����_����.Tag - 1]).
      ���� �������� ����� �������� ������, �� ��� ��� ���������.
      �������� ������� ������� � ����������� ��������� �� ����� - ���� ��
      ������� ��� ����������������.
  [*] ���������� form2.WMActivate (WA_ACTIVE, WA_CLICKACTIVE)
  [+] ������� ������������ ����� ��������� ������ �� Ctrl+Tab
  [!] ���� �� ��� ��������� ������� ����������.

-------------------------------------------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, ExtDlgs, Menus, StdCtrls, ImgList,
  RyComponents{�������������� ����������}, Unit3, Unit4, Unit5, Unit6;

type
  TForm1 = class(TForm)
    OpenDialog: TOpenPictureDialog;
    pmiNotepad: TMenuItem;
    pmiExcel: TMenuItem;
    pmiCal: TMenuItem;
    N4: TMenuItem;
    pmiExit: TMenuItem;
    ImageList1: TImageList;
    MainMenu: TMainMenu;
    mmiFile: TMenuItem;
    mmiWindows: TMenuItem;
    mmiOptions: TMenuItem;
    mmiNotepad: TMenuItem;
    mmiExcel: TMenuItem;
    mmiCal: TMenuItem;
    N13: TMenuItem;
    mmiExit: TMenuItem;
    mmiChangePicture: TMenuItem;
    mmiWindowsCascade: TMenuItem;
    N5: TMenuItem;
    pmiProgs: TMenuItem;
    pmiOptions: TMenuItem;
    pmiHelp: TMenuItem;
    N9: TMenuItem;
    MainPopupMenu: TPopupMenu;
    mmiWindowList: TMenuItem;
    mmiFullScreen: TMenuItem;
    pmiFullScreen: TMenuItem;
    DeskTop: TRyDeskTop;
    pbTip2: TPaintBox;
    pbTip1: TPaintBox;
    pbTip3: TPaintBox;
    btnNotepad: TRyDesktopButton;
    btnExcel: TRyDesktopButton;
    DeskTopImgList: TImageList;
    btnCalc: TRyDesktopButton;
    pbTip4: TPaintBox;
    TaskBar: TRyToolBar;
    mmiCloseAll: TMenuItem;
    mmiHideAll: TMenuItem;
    N1: TMenuItem;
    LinksPopupMenu: TPopupMenu;
    pmiOpenLink: TMenuItem;
    procedure NotepadClick(Sender: TObject);
    procedure ExcelClick(Sender: TObject);
    procedure ChangePicture(Sender: TObject);
    procedure CalcClick(Sender: TObject);
    procedure StartBtnClick(Sender: TObject);
    procedure PopupMenu_MeasureItem(Sender: TObject; ACanvas: TCanvas; var Width,
      Height: Integer);
    procedure ExitClick(Sender: TObject);
    procedure mmiWindowsCascadeClick(Sender: TObject);
    procedure Menu_MeasureItem(Sender: TObject; ACanvas: TCanvas;
      var Width, Height: Integer);
    procedure Menu_DrawItem(Sender: TObject;
      ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
    procedure mmiWindowListClick(Sender: TObject);
    procedure FullScreenClick(Sender: TObject);
    procedure pbTipsPaint(Sender: TObject);
    procedure mmiWindowsClick(Sender: TObject);
    procedure mmiHideAllClick(Sender: TObject);
    procedure mmiCloseAllClick(Sender: TObject);
    procedure OpenLinkClick(Sender: TObject);
  private
    FFullScreen: Boolean;
    {���� �����}
    Form4: TForm4;
    Form5: TForm5;

    FActiveForm: Integer;
    ChildForms: TList;

    function GetChildForm(Index: Integer): TForm;
    procedure ItemClick(Sender: TObject);
    procedure StartButtonPaint(Sender: TObject; ACanvas: TCanvas;
      const ARect: TRect);
    procedure ActivateForm(Index: Integer);
    procedure NextForm;
    procedure PrevForm;
    property ChildForm[Index: Integer]: TForm read GetChildForm;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    procedure AddWnd(const ACaption: String; AForm: TForm);
    procedure ActiveWnd(AForm: TForm);
    procedure DelWnd(AForm: TForm);
  public
    function IsShortCut(var Message: TWMKey): Boolean; override;
  end;

var
  Form1: TForm1;

implementation

uses ShellApi;

{$R *.DFM}

{ TForm1 }

constructor TForm1.Create(AOwner: TComponent);
var
  Rect: TRect;
  Button: TRyToolButton;
begin
  inherited;

  FFullScreen := False;
  FActiveForm := -1;         

  SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0); {����������� �
  windows'� ������ ������� �������}
  SetBounds(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);

  ChildForms := TList.Create;

  Button := TaskBar.AppendButton;
  Button.Caption := '����';
  Button.TextCenter := True; {�.�. � ��� ��� ����������, �� ����� �����������
  ���������� ��� �������� �������� � imagelist1}
  Button.OnPaint := StartButtonPaint; {������ ������������� ������}
  Button.OnClick := StartBtnClick;
  Button.OnExecute := StartBtnClick;
end;

destructor TForm1.Destroy;
begin
  ChildForms.Free;
  inherited;
end;

procedure TForm1.AddWnd(const ACaption: String; AForm: TForm); {����� ���������
����� �������� ����-����� ��� �������� �� ���� ����}
var
  I: Integer;
  Item: TMenuItem;
  Button: TRyToolButton;
begin
  I := ChildForms.Add(AForm) + 1; {��������� � ������ �������� ����. ��, �������,
  �������� �������� �� "+1" - ���� � ��� ��� ����� ������ ������� � ������ ����
  ����� ���������� ����� 0, � ���� �� �� ����� ��������� tag'� ������ ���� ���
  ������ � taskbar'�, �.�. ������ � ���� ��������� tag ����� �������� =0.}

  {��������� menuitem � ���� ����}
  Item := TMenuItem.Create(Self); {��� ���� �� ������� ���� ���� � ���� "����"}
  Item.Caption := ACaption;
  Item.OnClick := ItemClick;
  Item.OnMeasureItem := Menu_MeasureItem;
  Item.OnAdvancedDrawItem := Menu_DrawItem;
  Item.Tag := I; {���������� � tag'� ���������� ����� ����� � ������}
  mmiWindows.Add(Item);

  {��������� ������ � taskbar}
  Button := TaskBar.AppendButton;
  Button.Caption := ACaption;
  Button.Tag := I; {���������� � tag'� ���������� ����� ����� � ������}
  Button.ImageList := ImageList1;
  Button.ImageIndex := 0;
  Button.OnClick := ItemClick; {��� ����� �� ������ ������� �����}
  Button.OnExecute := ItemClick; {��� ����� �� ������ ���� enter'��}
end;

procedure TForm1.ActiveWnd(AForm: TForm); {����� �������� ���� ��������������
��� �������� �� ���� ����}
var
  I, Index: Integer;
begin
  Index := ChildForms.IndexOf(AForm); {������� ���������� ����� ����������������
  ����� � ������}

  if FActiveForm = Index then Exit; {���� ���������������� ���� ����� ���� ���
  � � ������� ���, �� ������ ������ �� ���������}

  for I := mmiWindows.Count - 1 downto 0 do {��������� �� ���� ������� ���� "����"}
    if (Index <> -1) and (mmiWindows.Items[I].Tag = Index + 1) then
      mmiWindows.Items[I].Checked := True {������ ������� �� ��� ������, �������
      ������������� �����}
    else
    if (FActiveForm <> -1) and (mmiWindows.Items[I].Tag = FActiveForm + 1) then
      mmiWindows.Items[I].Checked := False; {� ������� ������� � ����������� �����}

  for I := TaskBar.ButtonCount - 1 downto 0 do {���� ����� � � �������� � Taskbar'�}
    if (Index > -1) and (TaskBar.Buttons[I].Tag = Index + 1) then
      TRyToolButton(TaskBar.Buttons[I]).Checked := True
    else
    if (FActiveForm <> -1) and (TaskBar.Buttons[I].Tag = FActiveForm + 1) then
      TRyToolButton(TaskBar.Buttons[I]).Checked := False;

  FActiveForm := Index; {���������� ����� ���� ����������������}
end;

procedure TForm1.DelWnd(AForm: TForm); {����� ����� ������������ ��� ��������
�� ���� ����}
var
  I, Index: Integer;
begin
  Index := ChildForms.IndexOf(AForm);

  if Index = -1 then Exit;

  for I := mmiWindows.Count - 1 downto 0 do {����� �� ���� ������� � ���� "����"}
    if (mmiWindows.Items[I].Tag = Index + 1) then
    begin
      mmiWindows.Items[I].Free; {������� ��������������� ����� ����}
      Break;
    end;

  for I := TaskBar.ButtonCount - 1 downto 0 do {���� ����� � �������� � taskbar'�}
    if (TaskBar.Buttons[I].Tag = Index + 1) then
    begin
      TaskBar.Buttons[I].Free;
      Break;
    end;

  ChildForms.Delete(Index); {������� �� ������}

  if FActiveForm = Index then FActiveForm := -1;
end;

procedure TForm1.ActivateForm(Index: Integer);
begin
  if not IsWindowVisible(ChildForm[Index].Handle) then {���� ����� ������}
    ShowWindow(ChildForm[Index].Handle, SW_SHOW); {���������� ��}

  SetActiveWindow(ChildForm[Index].Handle) {������ ����� ��������}
end;

procedure TForm1.PrevForm;
var
  Index: Integer;
begin
  if ChildForms.Count = 0 then Exit;

  if FActiveForm = 0 then Index := ChildForms.Count - 1
  else Index := FActiveForm - 1;

  ActivateForm(Index);
end;

procedure TForm1.NextForm;
var
  Index: Integer;
begin
  if ChildForms.Count = 0 then Exit;

  if FActiveForm = ChildForms.Count - 1 then Index := 0
  else Index := FActiveForm + 1;

  ActivateForm(Index);
end;

function TForm1.IsShortCut(var Message: TWMKey): Boolean;
var
  SS: TShiftState;
begin
  case Message.CharCode of
    VK_F9:
    begin
      StartBtnClick(nil);
      Result := True;
      Exit;
    end;
    VK_TAB:
    begin
      SS := KeyDataToShiftState(Message.KeyData);
      if (ssCtrl in SS) then
      begin
        if (ssShift in SS) then
          PrevForm
        else
          NextForm;
        Result := True;
        Exit;
      end;
    end;
  end;

  Result := inherited IsShortCut(Message);
end;

function TForm1.GetChildForm(Index: Integer): TForm;
begin
  Result := TForm(ChildForms[Index])
end;

procedure TForm1.NotepadClick(Sender: TObject); {��� ������
�� ������ ������� � ���������� form3. form3 ����� �������
����� ����������}
var
  Form3: TForm3;
begin
  Form3 := TForm3.Create(Application);
  Form3.Show;
end;

procedure TForm1.ExcelClick(Sender: TObject); {��� ������
�� ������ ������� � ���������� form4. form4 ����� �������
������ ����}
begin
  if Form4 = nil then {���� ����� ��� �� �������, �� ������� form4}
  begin
    Form4 := TForm4.Create(Application);
    Form4.Show;
  end else
  begin
    if not IsWindowVisible(Form4.Handle) then ShowWindow(Form4.Handle, SW_SHOW); {
    ���� ����� ������, �� �����������}
    SetActiveWindow(Form4.Handle); {������������ �����}
  end;

  //if Form4.WindowState = wsMinimized then
  //  Form4.WindowState := wsNormal;
end;

procedure TForm1.CalcClick(Sender: TObject); {��� ������
�� ������ ������� � ���������� form5. form5 ����� �������
������ ����}
begin
  if Form5 = nil then {���� ����� ��� �� �������, �� ������� form5}
  begin
    Form5 := TForm5.Create(Application);
    Form5.Show;
  end else
  begin
    if not IsWindowVisible(Form5.Handle) then ShowWindow(Form5.Handle, SW_SHOW); {
    ���� ����� ������, �� �����������}
    SetActiveWindow(Form5.Handle); {������������ �����}
  end;
end;

procedure TForm1.ChangePicture(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    DeskTop.BackgroundState := bsScreen; {�.�. ������� ������ ���� �� ����
    �����, �� ���� ��������� ���� ��������}
    DeskTop.BmpName := OpenDialog.FileName;
  end
end;

procedure TForm1.StartBtnClick(Sender: TObject); {����� �� ������ "����"}
var
  P: TPoint;
begin
  P := Taskbar.ClientToScreen(Point(0, 0));
  Inc(P.X, 5);
  Dec(P.Y, 110); {115 = 3 ������ ���� �� 25���� + ������� 10����}
  MainPopupMenu.Popup(P.x, P.Y);                   {���������� ����}
end;

procedure TForm1.ItemClick(Sender: TObject); {����� ������������ �������
�� ������ � taskbar'e ��� �� ������ ���� �� ���� "����", �� �� ������ ��������
����� ��������������� ���}
var
  Index: Integer;
begin
  Index := TComponent(Sender).Tag;

  if Index > 0 then
  begin
    if (Sender is TRyToolButton)
      and (FActiveForm <> -1) and (FActiveForm = Index - 1)
      and IsWindowVisible(ChildForm[Index - 1].Handle) {���� ����� �����} then {
    ���� �������� �� ������ � taskbar'�, � ��� ����� ��� ���� �������, �� ������
    ����������� ��}
    begin
      ShowWindow(ChildForm[Index - 1].Handle, SW_HIDE); {�.�. �������� � ������}
      Exit; {� ������}
    end;

    ActivateForm(Index - 1) {������ ����� ��������}
  end
end;

procedure TForm1.ExitClick(Sender: TObject);
begin
  Close
end;

procedure TForm1.mmiWindowsCascadeClick(Sender: TObject);
var
  L, T: Integer;

  procedure ChangeFormPos(Form: TForm);
  var
    R, B: Integer;
  begin
    if (Form.BorderStyle in [bsSizeable, bsSizeToolWin]) then
    begin
      R := Round(Width / 1.5);
      B := Round(Height / 1.5);
    end else
    begin
      R := Form.Width;
      B := Form.Height;
    end;

    if (L + R > Width) or (T + B > Height - 35) then
    begin
      L := 25;
      T := 25;
    end;

    SetWindowPos(Form.Handle, HWND_TOP, L, T, R, B, SWP_NOACTIVATE);
  end;

var
  I: Integer;
begin
  L := 25;
  T := 25;
  for I := 0 to ChildForms.Count - 1 do
  begin
    if I = FActiveForm then Continue;
    if not IsWindowVisible(ChildForm[I].Handle) then Continue; {���� ����� ������}

    ChangeFormPos(ChildForm[I]);

    Inc(L, 25);
    Inc(T, 25);
  end;

  if FActiveForm <> -1 then
  begin
    ChangeFormPos(ChildForm[FActiveForm]);
    SetActiveWindow(ChildForm[FActiveForm].Handle); {������ ����� ��������}
  end;
end;

procedure TForm1.mmiWindowListClick(Sender: TObject);
var
  I: Integer;
begin
  if ChildForms.Count = 0 then Exit;

  with TForm6.Create(nil) do
  try
    ImageList := self.ImageList1;

    for I := 0 to ChildForms.Count - 1 do
      ListBox1.Items.Add(ChildForm[I].Caption);

    if ShowModal = idOk then
    begin
      if not IsWindowVisible(ChildForm[Listbox1.ItemIndex].Handle) then {���� ����� ������}
        ShowWindow(ChildForm[Listbox1.ItemIndex].Handle, SW_SHOW); {���������� ��}

      SetActiveWindow(ChildForm[Listbox1.ItemIndex].Handle) {������ ����� ��������}
    end
  finally
    Free
  end
end;

procedure TForm1.FullScreenClick(Sender: TObject);

  (* ����������� ������ ����
  procedure AutoHideTaskBar(aAutoHide: Boolean);
  const
    ABM_SETSTATE = $0000000a;
  var
    BarData: TAppBarData;
    dwState, dwNewState: DWord;
  begin
    FillChar(BarData, SizeOf(BarData), 0);
    BarData.cbSize := SizeOf(BarData);
    dwState := SHAppBarMessage(ABM_GETSTATE, BarData);
    if aAutoHide then
      dwNewState := dwState or ABS_AUTOHIDE
    else
      dwNewState := dwState and not ABS_AUTOHIDE;
    if dwState <> dwNewState then
    begin
      BarData.lParam := dwNewState;
      SHAppBarMessage(ABM_SETSTATE, BarData)
    end
  end;*)

var
  Rect: TRect;
begin
  FFullScreen := not FFullScreen;

  if FFullScreen then
    SetBounds(0, 0, GetSystemMetrics(SM_CXSCREEN), GetSystemMetrics(SM_CYSCREEN)) {
    ����������� � ������� ������� ������ � ������������ ���� �� ������}

    {���� ����������������� autohidetaskbar ��������� �� ��� setbounds, ��
     setbounds ��������� �����������}
  else begin
    SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0); {����������� �
    windows'� ������ ������� �������}
    SetBounds(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
  end;

  //AutoHideTaskBar(True);
  { ��� ��������� �������� windows'������ �������
    "������������� �������� ������ �����", �� �.�. ����� ����� �����������
    ��������� bug'���� � ��������� �� ���������������� [���� ���������� �����
    �� ������ �����, �� ������ ��������� ����������; � ���� ��������� �������
    �� ������� �������� �� ����� �������, �� �������� ���� ��������� ������
    ����.]
    �� ������ ���� � delphi5 ��� ���.}

  mmiFullScreen.Checked := FFullScreen;
  pmiFullScreen.Checked := FFullScreen;
end;

procedure TForm1.mmiWindowsClick(Sender: TObject);
begin
  mmiWindowList.Enabled := ChildForms.Count > 0;
  mmiWindowsCascade.Enabled := ChildForms.Count > 0;
  mmiCloseAll.Enabled := ChildForms.Count > 0;
  mmiHideAll.Enabled := ChildForms.Count > 0;
end;

procedure TForm1.mmiHideAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := ChildForms.Count - 1 downto 0 do
    ShowWindow(ChildForm[I].Handle, SW_HIDE)
end;

procedure TForm1.mmiCloseAllClick(Sender: TObject);
var
  I: Integer;
begin
  for I := ChildForms.Count - 1 downto 0 do
    ChildForm[I].Free;

  Form4 := nil;
  Form5 := nil;
  FActiveForm := -1;
end;

procedure TForm1.PopupMenu_MeasureItem(Sender: TObject;
  ACanvas: TCanvas; var Width, Height: Integer); {������������� ������� �������
  ����. ���� ��� ������ ���� ������ ���� ���������.}
begin
  if TMenuItem(Sender).IsLine then
    Height := 10  {������� ������������� ������� 10����}
  else
    Height := 25; {� ��������� ������ ���� �� 25����}

  with ACanvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
  end;

  Width := ACanvas.TextWidth(TMenuItem(Sender).Caption) + 40; {���������
  ������ ������� �� ������� ���� = ������ ������ + ������ ����� ������� [25����] +
  ������ �� ������� + ��������� ����� ������}
end;

procedure TForm1.Menu_MeasureItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
begin
  with ACanvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
  end;

  if TMenuItem(Sender).GetParentComponent is TMainMenu then {���� ��������
  ����� ���� ��� ���� �� ������� ��������� ���� [����, ���� ��� ������]}
    Width := ACanvas.TextWidth(Caption) + 5 {�� ������ = ������ ������ + 5����}
  else  {�����}
    Width := ACanvas.TextWidth(TMenuItem(Sender).Caption) + 40; {���������
  ������ ������� �� ������� ���� = ������ ������ + ������ ����� ������� [25����] +
  ������ �� ������� + ��������� ����� ������}

  if TMenuItem(Sender).IsLine then
    Height := 10
  else
    Height := Max(ACanvas.TextHeight('Wg'), ImageList1.Height) + 6;
end;

procedure TForm1.Menu_DrawItem(Sender: TObject;
  ACanvas: TCanvas; ARect: TRect; State: TOwnerDrawState);
begin
  with ACanvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
  end;

  with TMenuItem(Sender) do
    DrawItem(Sender, ACanvas, ARect, State, GetParentComponent is TMainMenu,
    IsLine, GetImageList, ImageIndex, Caption, ShortCutToText(ShortCut),
    25, clYellow, clSilver, clWhite, $0080FFFF);
end;

procedure TForm1.pbTipsPaint(Sender: TObject);
const
  CFlags : LongInt = DT_CENTER or DT_NOCLIP or DT_END_ELLIPSIS;
var
  Str: String;
  Flags: Longint;
  ARect: TRect;
  PB: TPaintBox;
begin
  if Sender = pbTip1 then Str := '��������� - ���� HotKey F9.'
  else
  if Sender = pbTip2 then Str := '��������� - ����� ������� ������� �������.'
  else
  if Sender = pbTip3 then Str := '����� ������� ����� ���-�� ����-���������.'
  else
  if Sender = pbTip4 then Str := '������ �� ������� ����� ����������� �� �������� ������.';

  PB := TPaintBox(Sender);

  with PB.Canvas do
  begin

    with Font do
    begin
      Name := 'MS Sans Serif';
      Size := 8;
    end;

    ARect := Rect(0, 0, PB.Width, PB.Height);

    Brush.Color := clAqua;
    Pen.Color := clBlack;

    Rectangle(ARect);
    Inc(ARect.Left, 5);
    Dec(ARect.Right, 5);

    Flags := CFlags or DT_SINGLELINE or DT_VCENTER;

    Brush.Style := bsClear;
    Font.Color := clBlack;
    Windows.DrawText(Handle, PChar(Str), Length(Str), ARect, Flags);
  end
end;

procedure TForm1.StartButtonPaint(Sender: TObject; ACanvas: TCanvas;
  const ARect: TRect);
var
  R: TRect;
begin
  Move(ARect, R, SizeOf(TRect));
  Windows.InflateRect(R, -1, -1); {������ ������� �� ����� �� 1����, �����
  ������ �� ���������}

  GradientFill(ACanvas, ARect, clBtnFace, clWhite, gdVertical); {��������
  ����������}

  ACanvas.Brush.Color := clBtnShadow;
  ACanvas.FrameRect(R); {������ ������� � ������}
  InflateRect(R, -1, -1);

  with ACanvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
    //Style := [fsBold]; //<- ���� ������ ��������
  end;
  ACanvas.Font.Color := clBtnText;
  ACanvas.Brush.Style := bsClear;
  Windows.DrawText(ACanvas.Handle, PChar(TRyToolButton(Sender).Caption),
    Length(TRyToolButton(Sender).Caption), R,
    DT_CENTER or DT_NOCLIP or DT_END_ELLIPSIS or DT_VCENTER or DT_SINGLELINE);
end;

procedure TForm1.OpenLinkClick(Sender: TObject);
begin
  if DeskTop.ButtonFocused = btnNotepad then NotepadClick(nil)
  else
  if DeskTop.ButtonFocused = btnExcel then ExcelClick(nil)
  else
  if DeskTop.ButtonFocused = btnCalc then CalcClick(nil)
end;

end.
