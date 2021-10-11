unit Unit1;

{*******************************************************************************
  Демонстрация интерфейса в стиле рабочего стола Windows.

  Алексей Румянцев, 2005
  Специально для Королевства Delphi http://www.delphikingdom.com

  ------------------------------------------------------------------------------

  Версия демонстрационного примера - 1.5 [просто счетчик обновлений
                                          в королевстве]
  Версия дополнительных компонент см. в RyComponents.pas

  Написано на Delphi5.
  Должно одинакого выглядеть и работать в Win98 и в WinXP.

  ------------------------------------------------------------------------------

  Усовершенствование примера не просто возможно, но даже скорей
  необходимо. Впрочем в качестве демонтрационного примера он
  имеет вполне законченный вид.

  Модуль, реализующий главное окно программы - собственно
  рабочий стол.
*******************************************************************************}


{----- HISTORY -----------------------------------------------------------------
  [@] см. также history в rycomponents.pas

  [*] Переименованы некоторые переменные.
  [*] Отредактированы внутренности некоторых функций/процедур.
  [*] В Tag для пунктов меню и кнопок на TaskBar'е запоминаются не указатели
      на соответствующие формы, а на index формы в списке дочерних форм
      (ChildForm[пункт_меню.Tag - 1]).
      Если придумаю более красивый способ, то еще раз переделаю.
      Возможно вернусь обратно к запоминанию указателя на форму - пока не
      угодать что предпочтительней.
  [*] исправлена form2.WMActivate (WA_ACTIVE, WA_CLICKACTIVE)
  [+] Сделать переключение между дочерними окнами по Ctrl+Tab
  [!] Пока не все известные помарки исправлены.

-------------------------------------------------------------------------------}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ExtCtrls, ExtDlgs, Menus, StdCtrls, ImgList,
  RyComponents{дополнительные компоненты}, Unit3, Unit4, Unit5, Unit6;

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
    {наши формы}
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

  SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0); {запрашиваем у
  windows'а размер рабочей облости}
  SetBounds(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);

  ChildForms := TList.Create;

  Button := TaskBar.AppendButton;
  Button.Caption := 'Пуск';
  Button.TextCenter := True; {т.к. у нее нет картиночки, то текст располагаем
  посередине или добавьте картинку в imagelist1}
  Button.OnPaint := StartButtonPaint; {пример отрисовывания кнопки}
  Button.OnClick := StartBtnClick;
  Button.OnExecute := StartBtnClick;
end;

destructor TForm1.Destroy;
begin
  ChildForms.Free;
  inherited;
end;

procedure TForm1.AddWnd(const ACaption: String; AForm: TForm); {когда создается
новое дочернее окно-форма оно сообщает об этом сюда}
var
  I: Integer;
  Item: TMenuItem;
  Button: TRyToolButton;
begin
  I := ChildForms.Add(AForm) + 1; {добавляем в список дочерних форм. Вы, наверно,
  обратите внимание на "+1" - дело в том что самый первый элемент в списке форм
  имеет порядковый номер 0, а ноль мы не можем присвоить tag'у пункту меню или
  кнопке в taskbar'е, т.к. вообще у всех компонент tag имеет значение =0.}

  {добавляем menuitem в меню окна}
  Item := TMenuItem.Create(Self); {для него мы создаем пукт меню в меню "окна"}
  Item.Caption := ACaption;
  Item.OnClick := ItemClick;
  Item.OnMeasureItem := Menu_MeasureItem;
  Item.OnAdvancedDrawItem := Menu_DrawItem;
  Item.Tag := I; {запоминаем в tag'е порядковый номер формы в списке}
  mmiWindows.Add(Item);

  {добавляем кнопку в taskbar}
  Button := TaskBar.AppendButton;
  Button.Caption := ACaption;
  Button.Tag := I; {запоминаем в tag'е порядковый номер формы в списке}
  Button.ImageList := ImageList1;
  Button.ImageIndex := 0;
  Button.OnClick := ItemClick; {это когда по кнопке щелкают мышью}
  Button.OnExecute := ItemClick; {это когда по кнопке бъют enter'ом}
end;

procedure TForm1.ActiveWnd(AForm: TForm); {когда дочернее окно активизируется
оно сообщает об этом сюда}
var
  I, Index: Integer;
begin
  Index := ChildForms.IndexOf(AForm); {находим порядковый номер аквизировавшуюся
  форму в списке}

  if FActiveForm = Index then Exit; {если активизировалось тоже самое окно что
  и в прошлый раз, то просто уходим из процедуры}

  for I := mmiWindows.Count - 1 downto 0 do {пробегаем по всем пунктам меню "окна"}
    if (Index <> -1) and (mmiWindows.Items[I].Tag = Index + 1) then
      mmiWindows.Items[I].Checked := True {ставим галочку на том пункте, которое
      соответствует форме}
    else
    if (FActiveForm <> -1) and (mmiWindows.Items[I].Tag = FActiveForm + 1) then
      mmiWindows.Items[I].Checked := False; {и снимаем галочку с потерявшего фокус}

  for I := TaskBar.ButtonCount - 1 downto 0 do {тоже самое и с кнопками в Taskbar'е}
    if (Index > -1) and (TaskBar.Buttons[I].Tag = Index + 1) then
      TRyToolButton(TaskBar.Buttons[I]).Checked := True
    else
    if (FActiveForm <> -1) and (TaskBar.Buttons[I].Tag = FActiveForm + 1) then
      TRyToolButton(TaskBar.Buttons[I]).Checked := False;

  FActiveForm := Index; {запоминаем какое окно активизировалось}
end;

procedure TForm1.DelWnd(AForm: TForm); {когда форма уничтожается она сообщает
об этом сюда}
var
  I, Index: Integer;
begin
  Index := ChildForms.IndexOf(AForm);

  if Index = -1 then Exit;

  for I := mmiWindows.Count - 1 downto 0 do {бежим по всем пунктам в меню "окна"}
    if (mmiWindows.Items[I].Tag = Index + 1) then
    begin
      mmiWindows.Items[I].Free; {удаляем соответствующий пункт меню}
      Break;
    end;

  for I := TaskBar.ButtonCount - 1 downto 0 do {тоже самое с кнопками в taskbar'е}
    if (TaskBar.Buttons[I].Tag = Index + 1) then
    begin
      TaskBar.Buttons[I].Free;
      Break;
    end;

  ChildForms.Delete(Index); {удаляем из списка}

  if FActiveForm = Index then FActiveForm := -1;
end;

procedure TForm1.ActivateForm(Index: Integer);
begin
  if not IsWindowVisible(ChildForm[Index].Handle) then {если форма скрыта}
    ShowWindow(ChildForm[Index].Handle, SW_SHOW); {показываем ее}

  SetActiveWindow(ChildForm[Index].Handle) {делаем форму активной}
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

procedure TForm1.NotepadClick(Sender: TObject); {при щелчке
на кнопку создаем и показываем form3. form3 можно создать
любое количество}
var
  Form3: TForm3;
begin
  Form3 := TForm3.Create(Application);
  Form3.Show;
end;

procedure TForm1.ExcelClick(Sender: TObject); {при щелчке
на кнопку создаем и показываем form4. form4 можно создать
только одну}
begin
  if Form4 = nil then {если форма еще не создана, то создаем form4}
  begin
    Form4 := TForm4.Create(Application);
    Form4.Show;
  end else
  begin
    if not IsWindowVisible(Form4.Handle) then ShowWindow(Form4.Handle, SW_SHOW); {
    если форма скрыта, то споказываем}
    SetActiveWindow(Form4.Handle); {активизируем форму}
  end;

  //if Form4.WindowState = wsMinimized then
  //  Form4.WindowState := wsNormal;
end;

procedure TForm1.CalcClick(Sender: TObject); {при щелчке
на кнопку создаем и показываем form5. form5 можно создать
только одну}
begin
  if Form5 = nil then {если форма еще не создана, то создаем form5}
  begin
    Form5 := TForm5.Create(Application);
    Form5.Show;
  end else
  begin
    if not IsWindowVisible(Form5.Handle) then ShowWindow(Form5.Handle, SW_SHOW); {
    если форма скрыта, то споказываем}
    SetActiveWindow(Form5.Handle); {активизируем форму}
  end;
end;

procedure TForm1.ChangePicture(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    DeskTop.BackgroundState := bsScreen; {т.к. рисунок должен быть во весь
    экран, то надо выставить этот параметр}
    DeskTop.BmpName := OpenDialog.FileName;
  end
end;

procedure TForm1.StartBtnClick(Sender: TObject); {нажав на кнопку "пуск"}
var
  P: TPoint;
begin
  P := Taskbar.ClientToScreen(Point(0, 0));
  Inc(P.X, 5);
  Dec(P.Y, 110); {115 = 3 пункта меню по 25писк + полоска 10пикс}
  MainPopupMenu.Popup(P.x, P.Y);                   {показываем меню}
end;

procedure TForm1.ItemClick(Sender: TObject); {когда пользователь щелкнул
по кнопке в taskbar'e или по пункту меню из меню "окна", то мы должны показать
форму соответствующую ему}
var
  Index: Integer;
begin
  Index := TComponent(Sender).Tag;

  if Index > 0 then
  begin
    if (Sender is TRyToolButton)
      and (FActiveForm <> -1) and (FActiveForm = Index - 1)
      and IsWindowVisible(ChildForm[Index - 1].Handle) {если форма видна} then {
    если щелкнули по кнопке в taskbar'е, а эта форма уже была активна, то значит
    сворачиваем ее}
    begin
      ShowWindow(ChildForm[Index - 1].Handle, SW_HIDE); {т.е. скрываем с экрана}
      Exit; {и уходим}
    end;

    ActivateForm(Index - 1) {делаем форму активной}
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
    if not IsWindowVisible(ChildForm[I].Handle) then Continue; {если форма скрыта}

    ChangeFormPos(ChildForm[I]);

    Inc(L, 25);
    Inc(T, 25);
  end;

  if FActiveForm <> -1 then
  begin
    ChangeFormPos(ChildForm[FActiveForm]);
    SetActiveWindow(ChildForm[FActiveForm].Handle); {делаем форму активной}
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
      if not IsWindowVisible(ChildForm[Listbox1.ItemIndex].Handle) then {если форма скрыта}
        ShowWindow(ChildForm[Listbox1.ItemIndex].Handle, SW_SHOW); {показываем ее}

      SetActiveWindow(ChildForm[Listbox1.ItemIndex].Handle) {делаем форму активной}
    end
  finally
    Free
  end
end;

procedure TForm1.FullScreenClick(Sender: TObject);

  (* комментарий смотри ниже
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
    запрашиваем у виндуса размеры экрана и развертываем окно на полную}

    {если раскомментировать autohidetaskbar поставить ее над setbounds, то
     setbounds перестает срабатывать}
  else begin
    SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0); {запрашиваем у
    windows'а размер рабочей облости}
    SetBounds(Rect.Left, Rect.Top, Rect.Right, Rect.Bottom);
  end;

  //AutoHideTaskBar(True);
  { Эта процедура включает windows'овскую галочку
    "Автоматически скрывать панель задач", но т.к. после этого наблюдаются
    некоторые bug'зики я предпочел ее закомментировать [если развернуть форму
    на полный экран, то панель перестает появляться; а если отступить пиксель
    то щелкнув случайно по этому пикселю, на передний план выползает другое
    окно.]
    По крайне мере в delphi5 это так.}

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
  ACanvas: TCanvas; var Width, Height: Integer); {устанавливаем размеры пунктов
  меню. меню для кнопки пуск должно быть массивным.}
begin
  if TMenuItem(Sender).IsLine then
    Height := 10  {сделаем отчеркивающую полоску 10пикс}
  else
    Height := 25; {а астальные пункты меню по 25пикс}

  with ACanvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
  end;

  Width := ACanvas.TextWidth(TMenuItem(Sender).Caption) + 40; {вычисляем
  ширину каждого из пунктов меню = ширина текста + ширина серой полоски [25пикс] +
  отступ от полоски + маленький запас справа}
end;

procedure TForm1.Menu_MeasureItem(Sender: TObject; ACanvas: TCanvas;
  var Width, Height: Integer);
begin
  with ACanvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
  end;

  if TMenuItem(Sender).GetParentComponent is TMainMenu then {если текуйщий
  пункт меню это один из пунктов основного меню [файл, окна или сервис]}
    Width := ACanvas.TextWidth(Caption) + 5 {то ширина = ширина текста + 5пикс}
  else  {иначе}
    Width := ACanvas.TextWidth(TMenuItem(Sender).Caption) + 40; {вычисляем
  ширину каждого из пунктов меню = ширина текста + ширина серой полоски [25пикс] +
  отступ от полоски + маленький запас справа}

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
  if Sender = pbTip1 then Str := 'Подсказка - есть HotKey F9.'
  else
  if Sender = pbTip2 then Str := 'Подсказка - можно сменить фоновый рисунок.'
  else
  if Sender = pbTip3 then Str := 'Можно создать любое кол-во форм-Блокнотов.'
  else
  if Sender = pbTip4 then Str := 'Ярлыки на рабочем столе открываются по двойному щелчку.';

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
  Windows.InflateRect(R, -1, -1); {делаем отступы от краев на 1пикс, чтобы
  кнопки не сливались}

  GradientFill(ACanvas, ARect, clBtnFace, clWhite, gdVertical); {заливаем
  градиентом}

  ACanvas.Brush.Color := clBtnShadow;
  ACanvas.FrameRect(R); {рисуем рамочку у кнопки}
  InflateRect(R, -1, -1);

  with ACanvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
    //Style := [fsBold]; //<- если хотите выделить
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
