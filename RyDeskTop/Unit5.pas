unit Unit5;

{***********************************************************
  Демонстрация интерфейса в стиле рабочего стола Windows

  Алексей Румянцев, 2005
  Специально для Королевства Delphi
  http://www.delphikingdom.com

  Пример дочернего окна.
 ***********************************************************}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Unit2, ComCtrls;

type
  TForm5 = class(TForm2)
    MonthCalendar1: TMonthCalendar;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

end.
