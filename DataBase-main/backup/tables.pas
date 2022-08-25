unit tables;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, table_manipulation, base_graphic;

type
  Header = array of string;

  { Table1 }

  Table1 = class sealed (InheritedTableCls)
  private
    function enterAccreditation: string;
    function enterDateForm: string;
    function enterFlatNumber: string;
    function enterLicence: string;
    function enterTownName: string;
    function enterYear: string;
    public
      constructor Init(start_x, start_y, border_y, width, height: integer);
      procedure showPage;
      procedure showLine(lineNumber: integer);
      procedure showHead;
      function enterStreetName: string;
      function enterTextFormat(InputField: TextButton): string; override;
      function setHeadOfColumns(): Header; override;
      {function enterDateForm: string;}
      function checkDayFormat(day: string): boolean;
      function checkMonthFormat(month: string): boolean;
      function checkYearFormat(year: string): boolean;
      function checkOrganizationName(text: string): boolean;
      function enterOrganizationName: string;
      function enterAddress: string;
      function enterHomeNumber: string;
      {procedure enterSubmissionForm;
      procedure enterNumberForm;
      procedure enterAddressForm;}
  end;

  Table2 = class sealed (InheritedTableCls)
    public
      constructor Init(start_x, start_y, border_y, width, height: integer);
      function setHeadOfColumns(): Header; override;
      function enterTextFormat(InputField: TextButton): string; override;
  end;

  Table3 = class sealed (InheritedTableCls)
    public
      constructor Init(start_x, start_y, border_y, width, height: integer);
      function setHeadOfColumns(): Header; override;
      function enterTextFormat(InputField: TextButton): string; override;
  end;

implementation
constructor Table1.Init(start_x, start_y, border_y, width, height: integer);
begin
  countColumn := 7;
  inherited Init(start_x, start_y, border_y, width, height, countColumn);
end;

procedure Table1.showPage;
begin
  inherited;
end;

procedure Table1.showLine(lineNumber: integer);
begin
  inherited;
end;

procedure Table1.showHead;
begin
  inherited;
end;

function Table1.enterTextFormat(InputField: TextButton): string;
begin
  gotoxy(1 + borderFreeSpace, 1 + (borderFreeSpace-1));
  if on_horizontal_button <> 3 then
  begin
    case on_horizontal_button of
      1: enterTextFormat := enterOrganizationName;
      2: enterTextFormat := enterAddress;
      4: enterTextFormat := enterYear;
      5: enterTextFormat := enterLicence;
      6: enterTextFormat := enterAccreditation;
      7: enterTextFormat := enterDateForm;
    end;
    InputField.del;
  end
  else
  begin
    InputField.del;
  end;
    {enterTextFormat := ;}
end;

function Table1.setHeadOfColumns(): Header;
begin
  setlength(result, countColumn);
  Result[0] := '��������';
  Result[1] := '�����';
  Result[2] := '��� ����������';
  Result[3] := '��� ���������';
  Result[4] := '����� ��������';
  Result[5] := '����� ������������';
  Result[6] := '���� ��������� �������� ������������';
end;

function Table1.checkDayFormat(day: string): boolean;
var
  int_day: integer;
begin
  if isInteger(day) then
  begin
    int_day := strtoint(day);
    if ((int_day < 32) and (int_day > 0)) then
      result := true
    else
      result := false;
  end
  else
    result := false;
end;

function Table1.checkMonthFormat(month: string): boolean;
var
  int_month: integer;
begin
  if isInteger(month) then
  begin
    int_month := strtoint(month);
    if ((int_month < 13) and (int_month > 0)) then
      result := true
    else
      result := false;
  end
  else
    result := false;
end;

function Table1.checkYearFormat(year: string): boolean;
var
  int_year: integer;
begin
  if isinteger(year) then
  begin
    int_year := strtoint(year);
    if ((int_year > 1990) and (int_year < 2023)) then
      result := true
    else
      result := false;
  end
  else
    result := false;
end;

function Table1.checkOrganizationName(text: string): boolean;
const
  acceptSize = 100;
begin
  begin
    if length(text) <= acceptSize then
      result := true
    else
      result := false;
  end;
end;

function Table1.enterDateForm: string;
const
  otherLen = 2; { ������������� }
  yearLen = 4;
var
  x_, y_: integer;
  text: string;
begin
 { x_ := 1;
  y_ := 1;

  write('  .  .');
  gotoxy(x_ + otherLen, y_);
  repeat
    deleteText(otherLen);
    enterText(otherLen);
  until (checkDayFormat(text));

  x_ := x_ + otherLen;
  gotoxy(x_ + otherLen, y_);
  repeat
    deleteText(otherLen);
    enterText(otherLen);
    write(text);
  until (checkMonthFormat(text));

  x_ := x_ + otherLen;
  gotoxy(x_ + yearLen, y_);
  repeat
    deleteText(yearLen);
    enterText(yearLen);
  until (checkYearFormat(text)); }
end;

function Table1.enterStreetName: string;
begin
  write('��.');
  enterStreetName := '��.' + enterText(34);
end;

function Table1.enterHomeNumber: string;
begin
  write('�.');
  enterHomeNumber := '�.' + enterNumber(4);
end;

function Table1.enterTownName: string;
begin
  write('�.');
  enterTownName := enterText(25);
end;

function Table1.enterFlatNumber: string;
begin
  write('�.');
  enterFlatNumber := '�.' + enterNumber(2);
end;

function Table1.enterAddress: string;
begin
  result := enterStreetName;
  write(' ');
  result := result + ' ' + enterHomeNumber;
  write(' ');
  result := result + ' ' + enterFlatNumber;
  write(' ');
  result := result + ' ' + enterTownName;
  //result := ;
end;

function Table1.enterOrganizationName: string;
const
  MaxOrgNameSize = 100;
begin
  enterOrganizationName := enterText(MaxOrgNameSize);
end;

function Table1.enterYear: string;
begin
  repeat
    enterYear := enterNumber(4);
    if (strtoint(enterYear) < 1400) or (strtoint(enterYear) > 2022) then
      enterYear := deleteText(enterYear, length(enterYear));
  until length(enterYear) > 0;
  enterYear := enterYear + ' �.';
end;

function Table1.enterLicence: string;
const
  licenseType = '��1';
begin
  enterLicence := enterNumber(2) + licenseType + '-�';
  write(licenseType + '-�');
  enterLicence := enterLicence + enterNumber(7);
end;

function Table1.enterAccreditation: string;
const
  accreditationType = '��1';
begin
  enterAccreditation := enterNumber(2) + accreditationType + '-�';
  write(accreditationType + '-�');
  enterAccreditation := enterAccreditation + enterNumber(7);
end;

constructor Table2.Init(start_x, start_y, border_y, width, height: integer);
begin
  countColumn := 4;
  inherited Init(start_x, start_y, border_y, width, height, countColumn);
end;

function Table2.setHeadOfColumns(): Header;
begin
  setlength(result, countColumn);
  Result[0] := '����������';
  Result[1] := '�������������';
  Result[2] := '���������� ��������� ����';
  Result[3] := '���������� ������������ ����';
end;

function Table2.enterTextFormat(InputField: TextButton): string;
begin
  gotoxy(1 + borderFreeSpace, 1 + (borderFreeSpace-1));
  InputField.del;
  InputField.border.del;
end;

constructor Table3.Init(start_x, start_y, border_y, width, height: integer);
begin
  countColumn := 3;
  inherited Init(start_x, start_y, border_y, width, height, countColumn);
end;

function Table3.setHeadOfColumns(): Header;
begin
  setlength(result, countColumn);
  Result[0] := '�����';
  Result[1] := '��������';
  Result[2] := '������������� ��������';
end;

function Table3.enterTextFormat(InputField: TextButton): string;
begin
  gotoxy(1 + borderFreeSpace, 1 + (borderFreeSpace-1));
  InputField.del;
  InputField.border.del;
end;
end.
