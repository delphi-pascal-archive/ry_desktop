program Project1;

uses
  Forms,
  RyComponents in 'RyComponents.pas',
  Unit1 in 'Unit1.pas' {Form1},
  Unit2 in 'Unit2.pas' {Form2},
  Unit3 in 'Unit3.pas' {Form3},
  Unit4 in 'Unit4.pas' {Form4},
  Unit5 in 'Unit5.pas' {Form5},
  Unit6 in 'Unit6.pas' {Form6};

{$R *.RES}

{�������� - ���� ���������������� ������ � ��� ���������� ��������
����� � ������� ����� �� ������� ���. �������, ��� �� ���������, ������ � ����
��������� ������ �� ������� �������� ����. ������ �� ��������������� ������
� ������������ �� �����������.

������ ����������� ��� ���������� � ������ ������ ���������� "���� MDI � ����� Word � Access",
�.� ���� ��� ������ ����, ��� ��� ����� ��������� � �������, ����� ��������
��������� ��� �������� � WINDOWS'������ ������� ������, � �����, �� ����� ������������,
����� ��� �� ��������� "������� 10 �������"... ����� �������, ������� ������� F9...}

begin
  with Application do {<- ��� ������� ����������, ����� � design time
  ������������� �� ����������� ������� �����.

  �� ����� ����������� ���������� ������� ������ ���� �������������� � �������
  �����������.
  ��� ����� ��������� ���� RyDeskTopLib.dpk (���� ����� ��� ���� �����-����
  ���������, �� ������������ � ����), ����� ������� ������ install (� ���
  ������ ��������� ������� RyDeskTop � ����� ������������), �������� � �����������...
  ������� �������� ���� ������ � ������ �������� ������� ����� � design time.

  ���� ���������� ��� ���� ��������������, �� ������ ���������������� RyDeskTopLib.dpk,
  � ����� ���������� ������.

  ���� ��� ������ ��� ��� ������, �� _��__����������_ ������� �����, � ������
  ������� F9.}
  begin
    Initialize;
    Title := 'RyDeskTop';
    CreateForm(TForm1, Form1);
    Run;
  end
end.
