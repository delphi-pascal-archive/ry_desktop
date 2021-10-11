unit Unit6;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  RyComponents, StdCtrls, ImgList;

type
  TForm6 = class(TForm)
    ListBox1: TListBox;
    procedure ListBox1DrawItem(Control: TWinControl; Index: Integer;
      Rect: TRect; State: TOwnerDrawState);
    procedure ListBox1MeasureItem(Control: TWinControl; Index: Integer;
      var Height: Integer);
    procedure ListBox1DblClick(Sender: TObject);
  private
    FImageList: TImageList;
  public
    property ImageList: TImageList read FImageList write FImageList;
  end;

implementation

{$R *.DFM}

procedure TForm6.ListBox1DrawItem(Control: TWinControl; Index: Integer;
  Rect: TRect; State: TOwnerDrawState);
begin
  with ListBox1.Canvas.Font do
  begin
    Name := 'MS Sans Serif';
    Size := 8;
  end;

  with ListBox1 do
    DrawItem(Self, Canvas, Rect, State, False, False, ImageList, 0, Items[Index],
    '', 25, clAqua, clSilver, GetShadeColor(clWhite, 15), $0080FFFF);
end;

procedure TForm6.ListBox1MeasureItem(Control: TWinControl; Index: Integer;
  var Height: Integer);
begin
  Height := 25;
end;

procedure TForm6.ListBox1DblClick(Sender: TObject);
begin
  ModalResult := mrOk
end;

end.
