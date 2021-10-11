unit RyComponents;

{*******************************************************************************
  Демонстрация интерфейса в стиле рабочего стола Windows

  Алексей Румянцев, 2005
  Специально для Королевства Delphi http://www.delphikingdom.com

  Дополнительные компоненты.

  Версии:
    TRyDeskTop        - 1.21
    TRyDesktopButton  - 1.21
    TRyToolBar        - 1.21
    TRyToolButton     - 1.21
 ******************************************************************************}

{----- HISTORY -----------------------------------------------------------------

  [@] кнопка, button, ярлык - это почти одни и те же объекты. на раб.столе это
      ярлык, в taskbar'е это кнопка, общего для них предка я буду называть
      button. Изменения в button одинакого относятся и к ярлыкам и к кнопкам.

  [+] для Button добавил OnDblClick - если надо выполнить какое-либо действие
      при двойном щелчке по ярлыку или кнопке.
  [+] т.к. по button'у можно не только щелкать мышью но и enter'ом ударять, то
      добавил событие OnExecute - если, например, при двойном щелчке и при
      enter'е надо выполнять одну и туже процедуру, то в object inspector'е
      просто сошлитесь на одну и ту же процедуру для обоих событий этого
      компонента.
  [-] из TRyCustomBar убраны OnClick и OnDblClick. т.е. не будут вызываться
      эти события когда вы просто щелкните по раб.столу., щелкнув же по button'у,
      один или два раза, будут вызываться соответствующие события в button'е.
  [+] добавлено PopupMenu для button'ов.
  [to-do] jpeg для background.

-------------------------------------------------------------------------------}
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ImgList, Commctrl;

type
  TRyCustomPanel = class(TCustomControl)
  private
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
  public
    constructor Create(AOwner: TComponent); override;
    property Canvas;
  published
    property Align;
    property Anchors;
    property AutoSize;
    property Enabled;
    property Color;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

  TRyCustomButton = class;

  TRyCustomBar = class(TRyCustomPanel)
  private
    FButtonFocused: TRyCustomButton;
    FButtons: TList;
    FButtonWidth: Integer;
    FButtonHeight: Integer;
    FOnPaint: TNotifyEvent;
    function GetButton(Item: Integer): TRyCustomButton;
    function GetButtonCount: Integer;
    procedure SetButtonFocused(Value: TRyCustomButton);
    procedure SetButtonHeight(Value: Integer);
    procedure SetButtonWidth(Value: Integer);
  private
    procedure WMSetFocus(var Message: TMessage); message WM_SETFOCUS;
    procedure WMKillFocus(var Message: TMessage); message WM_KILLFOCUS;
    procedure CNKeyDown(var Message: TWMKeyDown); message CN_KEYDOWN;
  protected
    function ButtonFromPoint(X, Y: Integer): TRyCustomButton;
    function GetPopupMenu: TPopupMenu; override;
    procedure GetCell(Col, Row: Integer; var ARect: TRect);
    procedure Paint; override;
    procedure Click; override;
    procedure DblClick; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure AddButton(AButton: TRyCustomButton); virtual;
    procedure DelButton(AButton: TRyCustomButton); virtual;
    procedure UpdateButton(AButton: TRyCustomButton);
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 65;
    property ButtonHeight: Integer read FButtonHeight write SetButtonHeight default 65;
    property OnClick;
    property OnDblClick;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Buttons[Item: Integer]: TRyCustomButton read GetButton;
    property ButtonCount: Integer read GetButtonCount;
    property ButtonFocused: TRyCustomButton read FButtonFocused write SetButtonFocused;
  published
    property OnPaint: TNotifyEvent read FOnPaint write FOnPaint;
    property OnContextPopup;
    property OnEnter;
    property OnExit;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

  //TBitmapAlign = (baLeft, baTop);
  TRyButtonPaintEvent = procedure(Sender: TObject; ACanvas: TCanvas;
    const ARect: TRect) of object;
  TRyCustomButton = class(TComponent)
  private
    FCaption : String;
    FParent: TRyCustomBar;
    FEnabled: Boolean;
    FPosY: Integer;
    FPosX: Integer;
    FImageList: TImageList;
    FImageIndex: Integer;
    //FBitmapAlign: TBitmapAlign;
    FOnClick: TNotifyEvent;
    FOnPaint: TRyButtonPaintEvent;
    FOnDblClick: TNotifyEvent;
    FOnExecute: TNotifyEvent;
    FPopupMenu: TPopupMenu;
    procedure SetCaption(const Value: String);
    procedure SetParent(Value: TRyCustomBar);
    procedure SetEnabled(Value: Boolean);
    procedure SetPosX(Value: Integer);
    procedure SetPosY(Value: Integer);
    procedure SetImageIndex(Value: Integer);
    procedure SetImageList(Value: TImageList);
    //procedure SetBitmapAlign(Value: TBitmapAlign);
  protected
    procedure Paint(ACanvas: TCanvas; const ARect: TRect);
    procedure DoPaint(ACanvas: TCanvas; const ARect: TRect); virtual;
    procedure DoClick; virtual;
    procedure DoDblClick; virtual;
    procedure DoExecute; virtual;
    //property BitmapAlign: TBitmapAlign read FBitmapAlign write SetBitmapAlign default baTop;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ImageList: TImageList read FImageList write SetImageList;
    property ImageIndex: Integer read FImageIndex write SetImageIndex default -1;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Caption: String read FCaption write SetCaption;
    property PosX: Integer read FPosX write SetPosX default 0;
    property PosY: Integer read FPosY write SetPosY default 0;
    property Parent: TRyCustomBar read FParent write SetParent;
    property PopupMenu: TPopupMenu read FPopupMenu write FPopupMenu;
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
    property OnDblClick: TNotifyEvent read FOnDblClick write FOnDblClick;
    property OnExecute: TNotifyEvent read FOnExecute write FOnExecute;
    property OnPaint: TRyButtonPaintEvent read FOnPaint write FOnPaint;
  end;

  TRyDesktopButton = class(TRyCustomButton)
  private
  public
  protected
    procedure DoPaint(ACanvas: TCanvas; const ARect: TRect); override;
  published
  end;

  TRyToolButton = class(TRyCustomButton)
  private
    FChecked: Boolean;
    FShowCaption: Boolean;
    FTextCenter: Boolean;
    procedure SetChecked(Value: Boolean);
    procedure SetShowCaption(Value: Boolean);
    procedure SetTextCenter(Value: Boolean);
  protected
    procedure DoPaint(ACanvas: TCanvas; const ARect: TRect); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Checked: Boolean read FChecked write SetChecked default False;
    property ShowCaption: Boolean read FShowCaption write SetShowCaption default True;
    property TextCenter: Boolean read FTextCenter write SetTextCenter default False;
  end;

  TBackgroundState = (bsFill, bsCenter, bsStretch, bsScreen);
  TRyDeskTop = class(TRyCustomBar)
  private
    FBmpName: String;
    FBmp: TBitmap;
    FBackgroundState: TBackgroundState; {fbmp - background рабочего стола,
    flist - картиночка для кнопки}
    procedure SetBmpName(const Value: String);
    procedure SetBackgroundState(Value: TBackgroundState);
  protected
    procedure Paint; override;
    procedure DblClick; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property Bmp: TBitmap read FBmp;
  published
    property BmpName: String read FBmpName write SetBmpName;
    property BackgroundState: TBackgroundState read FBackgroundState write SetBackgroundState default bsFill;
    property ButtonWidth;
    property ButtonHeight;
  end;

  TRyToolBar = class(TRyCustomBar)
  private
    procedure WMWindowPosChanged(var Message: TWMWindowPosChanged); message WM_WINDOWPOSCHANGED;
  protected
    BtnUnderMouse: TRyCustomButton;
    BtnPressed: TRyCustomButton;
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure DelButton(AButton: TRyCustomButton); override;
    property ButtonHeight;
  public
    function AppendButton: TRyToolButton;
    constructor Create(AOwner: TComponent); override;
  published
    property ButtonWidth;
  end;

type
  TGradientDirection = (gdHorizontal, gdVertical);
function GradientFill(Canvas: TCanvas; const ARect: TRect;
  Color1, Color2: TColor; Direction: TGradientDirection): Boolean;

function Max(A, B: Longint): Longint;
function GetShadeColor(Color: TColor; Shade: Byte) : TColor;

procedure DrawItem(Sender: TObject; ACanvas: TCanvas;
          ARect: TRect; State: TOwnerDrawState; TopLevel, IsLine: Boolean;
          ImageList: TCustomImageList; ImageIndex: Integer;
          const Caption, CaptionEx: String; GutterWidth: Integer;
          SelectedColor, GutterColor, MenuColor, SelLightColor: TColor);

implementation

{$R BMP32_LIST.res}
{$R BMP_BACKGROUND.res}  {ресурс с background'ом для раб.стола.
сли не нравится смените картинку в ресурсе.}

type
  TRGB = packed record
    R, G, B: Byte;
  end;

var
  FMonoBitmap: TBitmap;
  BmpCheck, BmpList: TBitmap;

function Max(A, B: Longint): Longint;
begin
  if A < B then Result := B
  else Result := A;
end;

function GetRGB(Color: TColor): TRGB;
var
  iColor: TColor;
begin
  iColor := ColorToRGB(Color);
  Result.R := GetRValue(iColor);
  Result.G := GetGValue(iColor);
  Result.B := GetBValue(iColor);
end;

function GetLightColor(Color: TColor; Light: Byte) : TColor;
var
  fFrom: TRGB;
begin
  FFrom := GetRGB(Color);

  Result := RGB(
    Round(FFrom.R + (255 - FFrom.R) * (Light / 100)),
    Round(FFrom.G + (255 - FFrom.G) * (Light / 100)),
    Round(FFrom.B + (255 - FFrom.B) * (Light / 100))
  );
end;

function  GetShadeColor(Color: TColor; Shade: Byte) : TColor;
var
  fFrom: TRGB;
begin
  FFrom := GetRGB(Color);

  Result := RGB(
    Max(0, FFrom.R - Shade),
    Max(0, FFrom.G - Shade),
    Max(0, FFrom.B - Shade)
  );
end;

function BtnHighlight : TColor;
begin
  Result := GetLightColor(clBtnFace, 50)
end;

// The definition of the TTriVertex structure in Windows.Pas is
// incorrect, therefore define my own
type
  TTriVertex = packed record
    x    : Longint;
    y    : Longint;
    Red  : SmallInt;
    Green: SmallInt;
    Blue : SmallInt;
    Alpha: SmallInt;
  end;
// Variables used for interfacing to the MSIMG32.DLL
function WndGradientFill(DC: HDC; var p2: TTriVertex; p3: ULONG; p4: Pointer; p5, p6: ULONG): BOOL; stdcall; external msimg32 name 'GradientFill';

function GradientFill(Canvas: TCanvas; const ARect: TRect; Color1,
  Color2: TColor; Direction: TGradientDirection): Boolean;

  // Function to initialise a TTriVertex
  procedure InitTriVertex(XPos, YPos: Integer; Color: TColor; var TV: TTriVertex);
  begin
    with TV do
    begin
      x := XPos;
      y := YPos;
      Alpha := 2;
      with GetRGB(Color) do
      begin
        Red := R shl 8;
        Green := G shl 8;
        Blue := B shl 8;
      end
    end
  end;

const
  Flag: array[TGradientDirection] of Longint = (
    GRADIENT_FILL_RECT_H, GRADIENT_FILL_RECT_V);
var
  GRect : TGradientRect;
  Vertex: array[0..1] of TTriVertex;
begin
  GRect.UpperLeft := 0;
  GRect.LowerRight := 1;
  InitTriVertex(ARect.Left, ARect.Top, Color1, Vertex[0]);
  InitTriVertex(ARect.Right, ARect.Bottom, Color2, Vertex[1]);
  Result := WndGradientFill(Canvas.Handle, Vertex[0], 2, @GRect, 1,
    Flag[Direction]);
end;

procedure DrawItem(Sender: TObject; ACanvas: TCanvas;
          ARect: TRect; State: TOwnerDrawState; TopLevel, IsLine: Boolean;
          ImageList: TCustomImageList; ImageIndex: Integer;
          const Caption, CaptionEx: String; GutterWidth: Integer;
          SelectedColor, GutterColor, MenuColor, SelLightColor: TColor);

  procedure GetBmpFromImgList(ABmp: TBitmap; AImgList: TCustomImageList;
            const ImageIndex: Word);
  begin
    with ABmp do
    begin
      Width := AImgList.Width;
      Height := AImgList.Height;
      Canvas.Brush.Color := clWhite;
      Canvas.FillRect(Rect(0, 0, Width, Height));
      ImageList_DrawEx(AImgList.Handle, ImageIndex,
        Canvas.Handle, 0, 0, 0, 0, CLR_DEFAULT, 0, ILD_NORMAL);
    end
  end;

  procedure DoDrawMonoBmp(ACanvas: TCanvas; const AMonoColor: TColor;
            const ALeft, ATop: Integer);
  const
    ROP_DSPDxax = $00E20746;{<-- скопировано из ImgList.TCustomImageList.DoDraw()}
  begin
    with ACanvas do
    begin
      Brush.Color := AMonoColor;
      SetTextColor(Handle, clWhite);
      SetBkColor(Handle, clBlack);
      BitBlt(Handle, ALeft, ATop, FMonoBitmap.Width, FMonoBitmap.Height,
             FMonoBitmap.Canvas.Handle, 0, 0, ROP_DSPDxax);
    end
  end;

const
  {текстовые флаги}
  _Flags: LongInt = DT_NOCLIP or DT_VCENTER or DT_END_ELLIPSIS or DT_SINGLELINE or DT_EXPANDTABS;
  _FlagsTopLevel: array[Boolean] of Longint = (DT_LEFT, DT_CENTER);
  _FlagsShortCut: {array[Boolean] of} Longint = (DT_RIGHT);
  _RectEl: array[Boolean] of Byte = (0, 6);{закругленный прямоугольник}
begin
  with ACanvas do
  begin
    Pen.Color := GetShadeColor(clHighlight, 50);
    if (odSelected in State) then {если пункт меню выделен}
    begin
      if TopLevel then {если это полоска основного меню}
      begin
        Brush.Color := BtnHighLight;
        FillRect(ARect);
        Pen.Color := GetShadeColor(clBtnShadow, 50);
        Polyline([
          Point(ARect.Left, ARect.Bottom-1),
          Point(ARect.Left, ARect.Top),
          Point(ARect.Right-1, ARect.Top),
          Point(ARect.Right-1, ARect.Bottom)
        ]);
      end else
      begin
        Brush.Color := SelectedColor;
        Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
      end
    end else
    if TopLevel then {если это полоска основного меню}
    begin
      if (odHotLight in State) then {если мышь над пунктом меню}
      begin
        Pen.Color := GetShadeColor(clHighlight, 50);
        Brush.Color := SelectedColor;
        //Brush.Color := BtnHighLight;
        Rectangle(ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
      end else
      begin
        Brush.Color := clBtnFace;
        FillRect(ARect);
      end
    end else
      begin {ничем не примечательный пункт меню}
        Brush.Color := GutterColor; {полоска}
        FillRect(Rect(ARect.Left, ARect.Top, ARect.Left + GutterWidth, ARect.Bottom));
        Brush.Color := MenuColor;
        FillRect(Rect(ARect.Left + GutterWidth, ARect.Top, ARect.Right, ARect.Bottom));
      end;

    if odChecked in State then
    begin {подсвечиваем чекнутый пункт меню}
      Pen.Color := GetShadeColor(clHighlight, 50);
      Brush.Color := SelLightColor;
      Rectangle((ARect.Left + 1), (ARect.Top + 1),
        (ARect.Left - 1 + GutterWidth - 1), (ARect.Bottom - 1)
      );
    end;

    if Assigned(ImageList) and ((ImageIndex > -1) and (not TopLevel)) then
      if not (odDisabled in State) then
        ImageList.Draw(ACanvas,
          (ARect.Left + GutterWidth - 1 - ImageList.Width) div 2,
          (ARect.Top + ARect.Bottom - ImageList.Height) div 2,
          ImageIndex, True) {рисуем цветную картинку}
      else begin {рисуем погасшую картинку}
        GetBmpFromImgList(FMonoBitmap, ImageList, ImageIndex);
        DoDrawMonoBmp(ACanvas, clBtnShadow,
          (ARect.Left + GutterWidth - 1 - ImageList.Width) div 2,
          (ARect.Top + ARect.Bottom - ImageList.Height) div 2);
      end
    else
    if odChecked in State then
      Draw((ARect.Left + GutterWidth - 1 - BmpCheck{[RadioItemFalse]}.Width) div 2,
          (ARect.Top + ARect.Bottom - BmpCheck{[RadioItemFalse]}.Height) div 2,
          BmpCheck{[RadioItemFalse]});

    with Font do
    begin
      if (odDefault in State) then Style := [fsBold];
      if (odDisabled in State) then Color := clGray
      else Color := clBlack;
    end;

    Brush.Style := bsClear;
    if TopLevel then {пусто}
    else Inc(ARect.Left, GutterWidth + 5); {отступ для текста}

    if IsLine then {если разделитель}
    begin
      Pen.Color := clBtnShadow;
      Polyline([
        Point(ARect.Left, ARect.Top + (ARect.Bottom - ARect.Top) div 2),
        Point(ARect.Right, ARect.Top + (ARect.Bottom - ARect.Top) div 2)]);
    end else
    begin {текст меню}
      DrawText(Handle, PChar(Caption), Length(Caption), ARect,
        _Flags or _FlagsTopLevel[TopLevel]);
      if CaptionEx <> '' then {разпальцовка}
      begin
        Dec(ARect.Right, 5);
        DrawText(Handle, PChar(CaptionEx), Length(CaptionEx),
          ARect, _Flags or _FlagsShortCut);
      end
    end
  end
end;

{ TRyCustomButton }

procedure TRyCustomButton.DoClick;
begin
  if Assigned(FOnClick) then FOnClick(Self)
end;

procedure TRyCustomButton.DoDblClick;
begin
  if Assigned(FOnDblClick) then FOnDblClick(Self)
end;

procedure TRyCustomButton.DoExecute;
begin
  if Assigned(FOnExecute) then FOnExecute(Self)
end;

constructor TRyCustomButton.Create(AOwner: TComponent);
begin
  inherited;

  FPosX := 0;
  FPosY := 0;
  FEnabled := True;
  FImageIndex := -1;
  //FBitmapAlign := baTop;
end;

destructor TRyCustomButton.Destroy;
begin
  if FParent <> nil then FParent.DelButton(Self);
  inherited;
end;

procedure TRyCustomButton.DoPaint(ACanvas: TCanvas; const ARect: TRect);
begin

end;

procedure TRyCustomButton.Paint(ACanvas: TCanvas; const ARect: TRect);
begin
  if Assigned(FOnPaint) then FOnPaint(Self, ACanvas, ARect)
  else
    DoPaint(ACanvas, ARect)
end;

procedure TRyCustomButton.SetCaption(const Value: String);
begin
  if FCaption = Value then Exit;
  FCaption := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

procedure TRyCustomButton.SetEnabled(Value: Boolean);
begin
  if FEnabled = Value then Exit;
  FEnabled := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

procedure TRyCustomButton.SetImageIndex(Value: Integer);
begin
  if FImageIndex = Value then Exit;
  FImageIndex := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

procedure TRyCustomButton.SetImageList(Value: TImageList);
begin
  FImageList := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

procedure TRyCustomButton.SetParent(Value: TRyCustomBar);
begin
  if FParent = Value then Exit;

  if FParent <> nil then FParent.DelButton(Self);
  FParent := Value;
  if FParent <> nil then FParent.AddButton(Self);
end;

procedure TRyCustomButton.SetPosX(Value: Integer);
var
  R: TRect;
begin
  if FPosX = Value then Exit;

  if FParent <> nil then
  begin
    FParent.GetCell(PosX, PosY, R);
    Windows.InvalidateRect(FParent.Handle, @R, True);
  end;

  FPosX := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

procedure TRyCustomButton.SetPosY(Value: Integer);
var
  R: TRect;
begin
  if FPosY = Value then Exit;

  if FParent <> nil then
  begin
    FParent.GetCell(PosX, PosY, R);
    Windows.InvalidateRect(FParent.Handle, @R, True);
  end;

  FPosY := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

{ TRyDesktopButton }

procedure TRyDesktopButton.DoPaint(ACanvas: TCanvas; const ARect: TRect);
const
  CFlags : LongInt = DT_CENTER or DT_NOCLIP or DT_END_ELLIPSIS;
var
  I: Integer;
  Flags: Longint;
  BmpWidth, BmpHeight: Integer;
  R: TRect;
begin
  if (ACanvas = nil) or (FParent = nil) then Exit;

  with ACanvas do
  begin
    Move(ARect, R, SizeOf(TRect));

    with Font do
    begin
      Name := 'MS Sans Serif';
      Size := 8;
    end;

    if (ImageList <> nil) then
    begin
      BmpWidth := ImageList.Width;
      BmpHeight := ImageList.Height;
    end else
    begin
      BmpWidth := 32;
      BmpHeight := 32;
    end;

    if (ImageList = nil) or (ImageIndex = -1) then
      Draw(R.Left + (R.Right - R.Left - BmpWidth) div 2, R.Top, BmpList)
    else
      ImageList.Draw(ACanvas,
        R.Left + (R.Right - R.Left - BmpWidth) div 2, R.Top,
        ImageIndex, Enabled);

    Inc(R.Top, BmpHeight + 3);
    I := TextWidth(Caption);
    if I > (R.Right - R.Left) - 10 then
    else Dec(R.Bottom, 10);
    if FParent.Focused and (FParent.ButtonFocused = Self) then
    begin
      Brush.Color := clLime;
      Pen.Color := clBlack;
      Rectangle(R);
    end;

    Inc(R.Left, 5);
    Dec(R.Right, 5);

    Flags := CFlags or DT_SINGLELINE or DT_VCENTER;// or DT_WORDBREAK;
    Brush.Style := bsClear;
    if not Enabled then Font.Color := clSilver
    else
    if (not FParent.Focused) or (FParent.ButtonFocused <> Self) then Font.Color := clWhite
    else
      Font.Color := clBlack;
    Windows.DrawText(Handle, PChar(Caption), Length(Caption), R, Flags);
  end
end;

{ TRyToolButton }

constructor TRyToolButton.Create(AOwner: TComponent);
begin
  inherited;

  FChecked := False;
  FShowCaption := True;
  FTextCenter:= False;
  //FBitmapAlign := baLeft;
end;

procedure TRyToolButton.DoPaint(ACanvas: TCanvas; const ARect: TRect);
const
  _FlagsText: Longint = (DT_NOCLIP or DT_END_ELLIPSIS or
    DT_VCENTER or DT_SINGLELINE);
var
  FlagsText: Longint;
  R: TRect;
begin
  if (ACanvas = nil) or (FParent = nil) then Exit;

  with ACanvas do
  begin

    Move(ARect, R, SizeOf(TRect));
    Windows.InflateRect(R, -1, -1);

    if (Enabled and
      (
        (TRyToolBar(FParent).BtnUnderMouse = Self) or
        ((FParent.ButtonFocused = Self) and FParent.Focused)
      )) then
    begin
      if Checked or (TRyToolBar(FParent).BtnPressed = Self) then
      begin
        Pen.Color := clBtnShadow;
        Brush.Color := GetLightColor(clBtnFace, 30);
        Rectangle(R);
        InflateRect(R, -1, -1);
      end else
      begin
        Pen.Color := clBtnShadow;
        Brush.Color := GetShadeColor(clBtnFace, 20);
        Rectangle(R);
        InflateRect(R, -1, -1);
      end
    end else
    if Checked then
    begin
      Pen.Color := clBtnShadow;
      Brush.Color := GetLightColor(clBtnFace, 50);
      Rectangle(R);
      InflateRect(R, -1, -1);
    end else
    begin
      Pen.Color := clBtnShadow;
      Brush.Color := clBtnFace;
      Rectangle(R);
      InflateRect(R, -1, -1);
    end;

    if (ImageList <> nil) then
    begin
      if (ImageIndex <> -1) then
      begin
        ImageList.Draw(ACanvas, R.Left + 3,
          R.Top + (R.Bottom - R.Top - ImageList.Height) div 2,
          ImageIndex, Enabled);
        Inc(R.Left, ImageList.Width + 6);
      end;
    end;

    if ShowCaption then
    begin
      with Font do
      begin
        Name := 'MS Sans Serif';
        Size := 8;
        Style := [];
      end;

      if TextCenter then FlagsText := _FlagsText or DT_CENTER
      else FlagsText := _FlagsText or DT_LEFT;
      Brush.Style := bsClear;
      if Enabled then Font.Color := clBtnText else Font.Color := clBtnShadow;
      Windows.DrawText(Handle, PChar(Caption), Length(Caption), R, FlagsText);
    end
  end
end;

procedure TRyToolButton.SetChecked(Value: Boolean);
begin
  if FChecked = Value then Exit;
  FChecked := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

procedure TRyToolButton.SetShowCaption(Value: Boolean);
begin
  if FShowCaption = Value then Exit;
  FShowCaption := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

procedure TRyToolButton.SetTextCenter(Value: Boolean);
begin
  if FTextCenter = Value then Exit;
  FTextCenter := Value;
  if FParent <> nil then FParent.UpdateButton(Self);
end;

{ TRyCustomPanel }

constructor TRyCustomPanel.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle := [csAcceptsControls, csOpaque, csClickEvents, csDoubleClicks, csCaptureMouse];
end;

procedure TRyCustomPanel.CreateParams(var Params: TCreateParams);
begin
  inherited;
  with Params do
    WindowClass.style := WindowClass.style and not (CS_HREDRAW or CS_VREDRAW);
end;

procedure TRyCustomPanel.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  Invalidate;
end;

{ TRyCustomBar }

constructor TRyCustomBar.Create(AOwner: TComponent);
begin
  inherited;

  FButtonWidth := 65;
  FButtonHeight := 65;

  TabStop := True;
  FButtons := TList.Create;
end;

destructor TRyCustomBar.Destroy;
var
  I: Integer;
begin
  for I := FButtons.Count - 1 downto 0 do
    Buttons[I].FParent := nil;
  FButtons.Free;
  inherited;
end;

procedure TRyCustomBar.WMKillFocus(var Message: TMessage);
begin
  inherited;
  UpdateButton(ButtonFocused);
end;

procedure TRyCustomBar.WMSetFocus(var Message: TMessage);
begin
  inherited;
  UpdateButton(ButtonFocused);
end;

function TRyCustomBar.GetPopupMenu: TPopupMenu;
begin
  if (ButtonFocused <> nil) then Result := ButtonFocused.PopupMenu
  else Result := inherited GetPopupMenu;
end;

procedure TRyCustomBar.CNKeyDown(var Message: TWMKeyDown); {не пинайте
меня за реализацию этой процедуры - она написана на скорую руку}

  function FindPrev(Key: Word; const I: Integer): Integer;
  var
    Last, Next: Integer;
  begin
    //if I = -1 then I := 0;
    Next := FButtons.Count - 1; Last := -1;
    while Next > -1 do
    begin
      if
          (
            ( (Key = VK_UP) and Buttons[Next].Enabled and
              (Buttons[Next].PosY < Buttons[I].PosY) and
              ( (Last = -1) or
                ( //(Buttons[Next].PosY >= Buttons[Last].PosY) and
                  (
                    (
                      (Buttons[Next].PosX >= Buttons[I].PosX) and
                      (Buttons[Next].PosX < Buttons[Last].PosX)
                    ) or
                    (
                      (Buttons[Next].PosX < Buttons[I].PosX + 1) and
                      (Buttons[Next].PosX > Buttons[Last].PosX)
                    )
                  )
                )
              )
            )
          ) or
          (
            ( (Key = VK_LEFT) and Buttons[Next].Enabled and
              (Buttons[Next].PosX < Buttons[I].PosX) and
              ( (Last = -1) or
                ( //(Buttons[Next].PosX >= Buttons[Last].PosX) and
                  (
                    (
                      (Buttons[Next].PosY >= Buttons[I].PosY) and
                      (Buttons[Next].PosY < Buttons[Last].PosY)
                    ) or
                    (
                      (Buttons[Next].PosY < Buttons[I].PosY + 1) and
                      (Buttons[Next].PosY > Buttons[Last].PosY)
                    )
                  )
                )
              )
            )
          ) then Last := Next;
      Dec(Next);
    end;
    if Last = -1 then Result := I else Result := Last;
  end;

  function FindNext(Key: Word; const I: Integer): Integer;
  var
    Last, Next: Integer;
  begin
    //if I = -1 then I := 0;
    Next := 0; Last := -1;
    while Next < FButtons.Count do
    begin
      if
          (
            ( (Key = VK_DOWN) and Buttons[Next].Enabled and
              (Buttons[Next].PosY > Buttons[I].PosY) and
              ( (Last = -1) or
                ( //(Buttons[Next].PosY <= Buttons[Last].PosY) and
                  (
                    (
                      (Buttons[Next].PosX >= Buttons[I].PosX) and
                      (Buttons[Next].PosX < Buttons[Last].PosX)
                    ) or
                    (
                      (Buttons[Next].PosX < Buttons[I].PosX + 1) and
                      (Buttons[Next].PosX > Buttons[Last].PosX)
                    )
                  )
                )
              )
            )
          ) or
          (
            ( (Key = VK_RIGHT) and Buttons[Next].Enabled and
              (Buttons[Next].PosX > Buttons[I].PosX) and
              ( (Last = -1) or
                ( //(Buttons[Next].PosX <= Buttons[Last].PosX) and
                  (
                    (
                      (Buttons[Next].PosY >= Buttons[I].PosY) and
                      (Buttons[Next].PosY < Buttons[Last].PosY)
                    ) or
                    (
                      (Buttons[Next].PosY < Buttons[I].PosY + 1) and
                      (Buttons[Next].PosY > Buttons[Last].PosY)
                    )
                  )
                )
              )
            )
          ) then Last := Next;
      Inc(Next);
    end;
    if Last = -1 then Result := I else Result := Last;
  end;

var
  I: Integer;
begin
  with Message do
    case CharCode of
      VK_RETURN:
      begin
        if FButtonFocused <> nil then ButtonFocused.DoExecute;
        Exit;
      end;
      VK_UP, VK_LEFT, VK_RIGHT, VK_DOWN:
      begin
        I := FButtons.IndexOf(ButtonFocused);
        if I = -1 then I := 0
        else if CharCode in [VK_UP, VK_LEFT] then I := FindPrev(CharCode, I)
        else if CharCode in [VK_DOWN, VK_RIGHT] then I := FindNext(CharCode, I);
        if I > -1 then ButtonFocused := Buttons[I];
        Exit;
      end;
    end;
    
  inherited;
end;

function TRyCustomBar.GetButton(Item: Integer): TRyCustomButton;
begin
  Result := TRyCustomButton(FButtons[Item])
end;

function TRyCustomBar.GetButtonCount: Integer;
begin
  Result := FButtons.Count
end;

procedure TRyCustomBar.AddButton(AButton: TRyCustomButton);
begin
  if AButton = nil then Exit;
  FButtons.Add(AButton);
  UpdateButton(AButton);
end;

procedure TRyCustomBar.DelButton(AButton: TRyCustomButton);
var
  R: TRect;
begin
  if AButton = nil then Exit;
  GetCell(AButton.PosX, AButton.PosY, R);
  FButtons.Delete(FButtons.IndexOf(AButton));
  Windows.InvalidateRect(Handle, @R, True);

  if FButtonFocused = AButton then ButtonFocused := nil;
end;

procedure TRyCustomBar.SetButtonFocused(Value: TRyCustomButton);
var
  OldBtn: TRyCustomButton;
begin
  if FButtonFocused = Value then Exit;

  OldBtn := FButtonFocused;
  FButtonFocused := Value;

  if OldBtn <> nil then UpdateButton(OldBtn);
  if Value <> nil then UpdateButton(Value);
end;

procedure TRyCustomBar.Paint;
var
  I: Integer;
  R: TRect;
begin
  if Assigned(OnPaint) then OnPaint(Self);
  for I := FButtons.Count - 1 downto 0 do
  begin
    with TRyCustomButton(FButtons[I]) do
    begin
      GetCell(PosX, PosY, R);
      Paint(Canvas, R);
    end
  end
end;

procedure TRyCustomBar.GetCell(Col, Row: Integer; var ARect: TRect);
begin
  ARect := Rect(ButtonWidth * Col + 5, ButtonHeight * Row + 5,
    ButtonWidth * Col + ButtonWidth + 5, ButtonHeight * Row + ButtonHeight + 5)
end;

procedure TRyCustomBar.UpdateButton(AButton: TRyCustomButton);
var
  R: TRect;
begin
  if AButton = nil then Exit;
  GetCell(AButton.PosX, AButton.PosY, R);
  Windows.InvalidateRect(Handle, @R, False);
end;

procedure TRyCustomBar.Click;
begin
  SetFocus;
  if FButtonFocused <> nil then FButtonFocused.DoClick;
end;

procedure TRyCustomBar.DblClick;
begin
  if FButtonFocused <> nil then FButtonFocused.DoDblClick;
end;

function TRyCustomBar.ButtonFromPoint(X, Y: Integer): TRyCustomButton;
var
  I: Integer;
  R: TRect;
begin
  Result := nil;

  for I := FButtons.Count - 1 downto 0 do
  begin
    GetCell(Buttons[I].PosX, Buttons[I].PosY, R);
    if Windows.PtInRect(R, Point(X, Y)) then
    begin
      Result := Buttons[I];
      Break;
    end
  end
end;

procedure TRyCustomBar.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  ButtonFocused := ButtonFromPoint(X, Y);
end;

procedure TRyCustomBar.SetButtonHeight(Value: Integer);
begin
  if FButtonHeight = Value then Exit;
  FButtonHeight := Value;
  Invalidate;
end;

procedure TRyCustomBar.SetButtonWidth(Value: Integer);
begin
  if FButtonWidth = Value then Exit;
  FButtonWidth := Value;
  Invalidate;
end;

{ TRyDeskTop }

procedure TRyDeskTop.Paint; {рисуем background на
рабочем столе}

  procedure DrawBackground; {если ни какая картинка не загружена,
  то отрисовываем загруженную из ресурсов.}
  var
    X , Y: Integer;
  begin
    X := 0; Y := 0;
    while X < ClientRect.Right do
    begin
      while Y < ClientRect.Bottom do
      begin
        Canvas.Draw(X, Y, Bmp);
        Inc(Y, Bmp.Height);
      end;
      Y := 0;
      Inc(X, Bmp.Width);
    end;
  end;

var
  R: TRect;
begin
  case BackgroundState of
    bsFill: DrawBackground;
    bsScreen:
    begin
      R := Canvas.ClipRect;
      Windows.BitBlt(Canvas.Handle, R.Left, R.Top, R.Right - R.Left,
        R.Bottom - R.Top, FBmp.Canvas.Handle, R.Left, R.Top, cmSrcCopy) {рисуем
        картинку на раб.столе}
    end;
    bsCenter:
    begin
      Windows.BitBlt(Canvas.Handle, Width div 2 - Bmp.Width div 2,
        Height div 2 - Bmp.Height div 2, Bmp.Width, Bmp.Height,
        FBmp.Canvas.Handle, 0, 0, cmSrcCopy) {рисуем картинку на раб.столе}
    end;
    bsStretch:
    begin
      Canvas.StretchDraw(ClientRect, Bmp)
    end;
  end;
  inherited;
end;

procedure TRyDeskTop.SetBmpName(const Value: String);
var
  FBmp: TBitmap;
begin
  if FileExists(Value) then
  begin {загружаем bitmap из файла и растягиваем на раб.стол}
    FBmp := TBitmap.Create;
    FBmp.LoadFromFile(Value);
    //SystemParametersInfo(SPI_GETWORKAREA, 0, @Rect, 0);
    Bmp.PixelFormat := pf24bit;
    if BackgroundState = bsScreen then
    begin
      Bmp.Height := GetSystemMetrics(SM_CYSCREEN);
      Bmp.Width := GetSystemMetrics(SM_CXSCREEN);
      Windows.SetStretchBltMode(Bmp.Canvas.Handle, STRETCH_HALFTONE);
      Windows.StretchBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
            FBmp.Canvas.Handle, 0, 0, FBmp.Width, FBmp.Height, SRCCOPY);
    end else
    begin
      Bmp.Height := FBmp.Height;
      Bmp.Width := FBmp.Width;
      Windows.BitBlt(Bmp.Canvas.Handle, 0, 0, Bmp.Width, Bmp.Height,
        FBmp.Canvas.Handle, 0, 0, SRCCOPY);
    end;
    FBmp.Free;

    FBmpName := Value;

    Invalidate;
  end;
end;

constructor TRyDeskTop.Create(AOwner: TComponent);
begin
  inherited;

  FBackgroundState := bsFill;

  FBmp := TBitmap.Create;
  FBmp.LoadFromResourceName(HInstance, 'BMP_BACKGROUND'); {загружаем
  из ресурса}
end;

destructor TRyDeskTop.Destroy;
begin
  FBmp.Free;
  inherited;
end;

procedure TRyDeskTop.SetBackgroundState(Value: TBackgroundState);
begin
  if FBackgroundState = Value then Exit;
  FBackgroundState := Value;
  Invalidate;
end;

procedure TRyDeskTop.DblClick;
begin
  if FButtonFocused <> nil then FButtonFocused.DoDblClick;
end;

{ TRyToolBar }

function TRyToolBar.AppendButton: TRyToolButton;
begin
  Result := TRyToolButton.Create(Self);
  Result.PosX := FButtons.Count;
  Result.PosY := 0;
  if FButtons.Count = 0 then FButtonFocused := Result;
  Result.Parent := Self;
end;

constructor TRyToolBar.Create(AOwner: TComponent);
begin
  inherited;

  FButtonWidth := 75;
end;

procedure TRyToolBar.WMWindowPosChanged(var Message: TWMWindowPosChanged);
begin
  inherited;
  ButtonHeight := Message.WindowPos.cy - 10;
end;

procedure TRyToolBar.DelButton(AButton: TRyCustomButton);
var
  I, X: Integer;
begin
  X := AButton.PosX;
  inherited;
  for I := 0 to FButtons.Count - 1 do
    if Buttons[I].PosX > X then
     Buttons[I].PosX := Buttons[I].PosX - 1;
end;

procedure TRyToolBar.MouseDown(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  BtnPressed := ButtonFromPoint(X, Y);
  UpdateButton(BtnPressed);
end;

procedure TRyToolBar.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  OldBtn: TRyCustomButton;
begin
  inherited;
  OldBtn := BtnUnderMouse;
  BtnUnderMouse := ButtonFromPoint(X, Y);
  UpdateButton(OldBtn);
  UpdateButton(BtnUnderMouse);
end;

procedure TRyToolBar.MouseUp(Button: TMouseButton; Shift: TShiftState; X,
  Y: Integer);
begin
  inherited;
  UpdateButton(BtnPressed);
  BtnPressed := nil;
end;

procedure TRyToolBar.Paint;
var
  R: TRect;
begin
  with Canvas do
  begin

    SetRect(R, 0, 0, Width, Height);

    if csDesigning in ComponentState then
    begin
      Pen.Style := psDot;
      Pen.Mode := pmXor;
      Pen.Color := clBtnShadow;
      Brush.Style := bsClear;
      Rectangle(R);
    end;

    Brush.Color := clBtnFace;
    FillRect(R);
    Pen.Color := clBtnHighlight;
    Polyline([Point(R.Left, R.Top + 1), Point(R.Right, R.Top + 1)]);
  end;
  inherited;
end;

procedure InitBmp(Bmp: TBitmap);
const
  StrBmp: String =
    '000000000000' + '-' +
    '000000000000' + '-' +
    '000000000000' + '-' +
    '000000001000' + '-' +
    '000000011000' + '-' +
    '001000111000' + '-' +
    '001101110000' + '-' +
    '001111100000' + '-' +
    '000111000000' + '-' +
    '000010000000' + '-' +
    '000000000000' + '-' +
    '000000000000';
var
  I, X, Y: Byte;
  Len: Integer;
begin
  with Bmp, Canvas do
  begin
    Width := 12;
    Height := 12;
    Monochrome := True;
    Transparent := True;
    Brush.Color := clWhite;
    FillRect(Rect(0, 0, Width, Height));
    X := 0; Y := 0;
    Len := Length(StrBmp);
    for I := 1 to Len do
      if StrBmp[I] = '-' then
      begin
        X := 0;
        Inc(Y);
      end else
      begin
        if StrBmp[I] = '1' then Pixels[X, Y] := clBlack;
        Inc(X);
      end
  end
end;

initialization
  BmpCheck := TBitmap.Create;
  BmpList := TBitmap.Create;
  BmpList.TransparentColor := clFuchsia;
  BmpList.Transparent := True;
  BmpList.LoadFromResourceName(HInstance, 'BMP32_LIST'); {загружаем
  из ресурса}
  InitBmp(BmpCheck);
  FMonoBitmap := TBitmap.Create;
  FMonoBitmap.Monochrome := True;

finalization
  FMonoBitmap.Free;
  BmpList.Free;
  BmpCheck.Free;

end.
