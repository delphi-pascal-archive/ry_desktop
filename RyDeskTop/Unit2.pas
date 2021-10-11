unit Unit2;

{***********************************************************
  Демонстрация интерфейса в стиле рабочего стола Windows

  Алексей Румянцев, 2005
  Специально для Королевства Delphi
  http://www.delphikingdom.com

  Модуль, реализующий дочернее окно - основная заготовка для
  всех дочерних форм, относительно рабочего стола. Все
  дочерние формы должны наследоваться от нее.
 ***********************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs;

type
  TForm2 = class(TForm) {обратите внимание
  все дочерние формы должны наследоваться от TForm2,
  т.е. File -> New -> Project1 -> Form2 -> inherited -> Ok}
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

uses Unit1; {вообще-то, желательно не привязываться, а всё взаимодействие вести
через соответствующие property (при необходимости добавить свои), но боюсь
запутать начинающих.

может в следующих версиях так и сделаю, а пока пусть останется так как есть.}

{$R *.DFM}

{ TForm2 }

constructor TForm2.Create(AOwner: TComponent);
begin
  inherited;
  CreateForm;
  Form1.AddWnd(Caption, Self); {сообщаем главной форме о создании этой формы}
end;

procedure TForm2.CreateForm; {зачем эта функция нужна см. unit3}
begin
end;

procedure TForm2.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
  begin
    WndParent := Form1.Handle; {при создании формы делаем ее дочерней относительно
    главной формы. ОБРАТИТЕ ВНИМАНИЕ: ЭТО НЕ ТОЖЕ САМОЕ ЧТО И Form.Parent := OtherForm}
  end
end;

destructor TForm2.Destroy;
begin
  Form1.DelWnd(Self); {сообщаем главной форме об уничтожении этой формы}
  inherited;
end;

procedure TForm2.DoClose(var Action: TCloseAction);
begin              
  if Action = caHide then ShowWindow(Handle, SW_HIDE); {закрытие формы приводит лишь
  к скрытию ее с экрана, это лишь как демонстрация управления событиями формы.
  например в form3 эта процедура перекрыта и там закрытая форма
  уничтожается.}
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
    Message.WindowPos.cy := Form1.Height - 35; {т.к. в низу у нас
    находится кнопка "пуск", то она должна быть видна}
    //Message.WindowPos.flags := SWP_NOMOVE;//NOREPOSITION;
  end;
end;

procedure TForm2.WMActivate(var Message: TWMActivate);
begin
  inherited;
  case Message.Active of
    WA_ACTIVE, WA_CLICKACTIVE: Form1.ActiveWnd(Self); {сообщаем главной форме о
    том что эта форма получила фокус}
  end;
end;

procedure TForm2.WMSysCommand(var Message: TMessage);
begin
  if (Message.WParam = SC_MINIMIZE) then {при минимизации формы игнорируем это
  событие и скрываем форму}
  begin
    ShowWindow(Handle, SW_HIDE);
    if not (IsWindowVisible(GetWindow(Handle, GW_HWNDNEXT)) or IsWindowVisible(GetWindow(Handle, GW_HWNDPREV))) then
      Windows.SetFocus(GetWindow(Handle, GW_OWNER)); {Это надо. иначе, иногда,
      при скрытии последнего из открытых дочерних окон, главная форма
      теряет фокус.}
  end else
    inherited {иначе оставляем реакцию на событие "как было бы если бы
    мы не вмешивались" :o) }
end;

end.
