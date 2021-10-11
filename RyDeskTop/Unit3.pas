unit Unit3;

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
  Unit2, StdCtrls, Menus;

type
  TForm3 = class(TForm2)
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Exit1: TMenuItem;
    N1: TMenuItem;
    PrintSetup1: TMenuItem;
    Print1: TMenuItem;
    N2: TMenuItem;
    SaveAs1: TMenuItem;
    Save1: TMenuItem;
    Open1: TMenuItem;
    New1: TMenuItem;
    Edit1: TMenuItem;
    Object1: TMenuItem;
    Links1: TMenuItem;
    N3: TMenuItem;
    GoTo1: TMenuItem;
    Replace1: TMenuItem;
    Find1: TMenuItem;
    N4: TMenuItem;
    PasteSpecial1: TMenuItem;
    Paste1: TMenuItem;
    Copy1: TMenuItem;
    Cut1: TMenuItem;
    N5: TMenuItem;
    Repeatcommand1: TMenuItem;
    Undo1: TMenuItem;
    Memo1: TMemo;
    procedure Exit1Click(Sender: TObject);
  private
    { Private declarations }
  protected
    procedure CreateForm; override;
    procedure DoClose(var Action: TCloseAction); override;
  public
  end;

implementation

{$R *.DFM}

var
  NotepadCount: Integer = 0;

procedure TForm3.CreateForm;
begin
  Inc(NotepadCount);
  Caption := Caption + ' [' + IntToStr(NotepadCount) + ']';
  inherited;
end;

procedure TForm3.DoClose(var Action: TCloseAction);
begin
  if Action = caHide then Action := caFree {закрытая форма уничтожается.}
  else
    inherited;
end;

procedure TForm3.Exit1Click(Sender: TObject);
begin
  Close
end;

end.
