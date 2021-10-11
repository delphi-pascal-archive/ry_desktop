unit RyDeskTopReg;

interface

procedure Register;

implementation

uses Windows, Sysutils, Classes, RyComponents;

procedure Register;
begin
  RegisterComponents('RyDeskTop', [TRyDeskTop, TRyToolBar, TRyDesktopButton]);
end;

end. 
