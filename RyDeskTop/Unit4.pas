unit Unit4;

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
  Unit2, Grids, Menus;

type
  TForm4 = class(TForm2)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    New1: TMenuItem;
    Open1: TMenuItem;
    Save1: TMenuItem;
    SaveAs1: TMenuItem;
    N2: TMenuItem;
    Print1: TMenuItem;
    PrintSetup1: TMenuItem;
    N1: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    Undo1: TMenuItem;
    Repeatcommand1: TMenuItem;
    N5: TMenuItem;
    Cut1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    PasteSpecial1: TMenuItem;
    N4: TMenuItem;
    Find1: TMenuItem;
    Replace1: TMenuItem;
    GoTo1: TMenuItem;
    N3: TMenuItem;
    Links1: TMenuItem;
    Object1: TMenuItem;
    StringGrid1: TStringGrid;
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

implementation

{$R *.DFM}

procedure TForm4.Exit1Click(Sender: TObject);
begin
  Close
end;

end.
