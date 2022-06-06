unit example_file;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Storage, Crt, base_graphic;

type
  SArray = array[1..7] of string;

  ViewTable = class
    background, countColumn, head_width, head_height, on_vertical_button, on_horizontal_button, pageNumber, pageCount, elementsNumber: integer;
    x, y, x_border, y_border, y_line_pos, lineCount,on_page: integer;
    Cells: array[1..7] of Cell;
    head_buttons: array[1..7] of TextButton;
    Pages: array of Cls_List;
    line: PLine; {�� ������ �������������}
    borderFreeSpace: integer;

    constructor Init(start_x, start_y, border_y, width, height, abs_background: integer);
    procedure showPage;
    procedure show_head;
    procedure createNewPage;
    procedure setCellPosition(lineNum: integer);
    {procedure createPage;}
    procedure deleteText(count: integer);
    procedure enterTextFormat;
    procedure writeInCell;
    procedure enterDateForm;
    procedure DeleteMode;
    procedure onCellDeleteMode();
    procedure WriteMode;
    procedure switchPage(key: char);
    procedure deleteLine(lineNumber: integer);
    procedure deleteCell(lineNumber, cellNumber: integer);
    procedure deleteLineLighting(lineNumber, color: integer);
    procedure deleteCellLighting(lineNumber, cellNumber, color: integer);
    procedure showPosition;
    procedure showLine(lineNumber: integer);
    procedure nextPage;
    procedure previousPage;
    {procedure enterSubmissionForm;
    procedure enterNumberForm;
    procedure enterAddressForm;}
    procedure Key_UP;
    procedure Key_DOWN;
    procedure Key_RIGHT;
    procedure Key_Left;
    procedure DelKey_UP;
    procedure DelKey_DOWN;
    procedure DelKey_RIGHT;
    procedure DelKey_LEFT;
    procedure main;
    function getFirstLineNumber: integer;
    function calculationLineCount: integer;
    function isInteger(text: string): boolean;
    function enterOrganizationName: string;
    function enterText(symbolsCount: integer): string;
    function checkDayFormat(day: string): boolean;
    function checkMonthFormat(month: string): boolean;
    function checkYearFormat(year: string): boolean;
    function checkOrganizationName(text: string): boolean;
    function setHeadOfColumns(): SArray;
  end;

implementation

constructor ViewTable.Init(start_x, start_y, border_y, width, height, abs_background: integer);
begin
  countColumn := 7;
  borderFreeSpace := 2;
  on_horizontal_button := 1;
  on_vertical_button := 1;
  head_width := width;
  head_height := height;
  x := start_x;
  y := start_y;
  y_border := border_y;
  background := abs_background;
  elementsNumber := 100;
  pageNumber := 1;
  pageCount := 0;
  lineCount := calculationLineCount;
  show_head;
  createNewPage;
end;

function ViewTable.calculationLineCount: integer;
var
  lineSize, headSize: integer;
begin
  headSize := head_height + (borderFreeSpace*2);
  lineSize := head_height + borderFreeSpace;
  result := (y_border - ((borderFreeSpace div 2) + headSize)) div lineSize;
end;

function ViewTable.setHeadOfColumns(): SArray;
begin
  Result[1] := '��������';
  Result[2] := '�����';
  Result[3] := '��� ����������';
  Result[4] := '��� ���������';
  Result[5] := '����� ��������';
  Result[6] := '����� ������������';
  Result[7] := '���� ��������� �������� ������������';
end;

procedure ViewTable.showPosition;
const
  MAX_TEXT_SIZE = 21;
var
  inf_button: TextButton;
  position: string;
  x_pos, y_pos: integer;
  last_line: PLine;
begin
  position := '������: ' + inttostr(on_vertical_button) + ' ������: ' + inttostr(on_horizontal_button);
  last_line := Pages[pageNumber].getNode(Pages[pageNumber].nodeCount);
  x_pos := (last_line^.data[countColumn].x_pos + last_line^.data[countColumn].button_width + borderFreeSpace) - MAX_TEXT_SIZE;
  y_pos := last_line^.data[countColumn].y_pos + borderFreeSpace;
  inf_button := TextButton.Init(MAX_TEXT_SIZE, 1, x_pos, y_pos, 0, position);
  inf_button.Show;
end;

procedure ViewTable.show_head;
var
  i: integer;
  columnHeader: SArray;
  x_pos, y_pos: integer;
begin
  x_pos := x + borderFreeSpace;
  y_pos := y + borderFreeSpace ;
  columnHeader := setHeadOfColumns;
  for i := 1 to countColumn do
  begin
    head_width := length(columnHeader[i]);
    head_buttons[i] := TextButton.Init(head_width, head_height, x_pos, y_pos, background, columnHeader[i]);
    head_buttons[i].Border := border.Init('-', borderFreeSpace, x_pos, y_pos, y_pos, head_width);
    head_buttons[i].Border.ChangeColor(1);
    head_buttons[i].Show;
    x_pos := x_pos + length(columnHeader[i]) + borderFreeSpace;
  end;
  x_border := head_buttons[countColumn].x_pos + head_buttons[countColumn].button_width + head_buttons[countColumn].border.borderFreeSpace;
end;

procedure ViewTable.setCellPosition(lineNum: integer);
begin
  line := Pages[pageNumber-1].getNode(lineNum);
  if lineNum > 1 then
  begin
    y_line_pos := line^.data[1].y_pos;
    y_line_pos := y_line_pos + ((borderFreeSpace * 2) - 2);
  end
  else
  begin
    y_line_pos := head_buttons[1].y_pos;
    y_line_pos := y_line_pos + ((borderFreeSpace * 2) - 1)
  end;
end;

function ViewTable.getFirstLineNumber: integer;
begin
  if pageCount <> 1 then
    result := Pages[pageCount-1].nodeCount
  else
    result := 1;
end;

procedure ViewTable.createNewPage();
var
  i, j: integer;
  s_text: string;
  lineNum: integer;
begin
  pageCount := pageCount + 1;
  lineNum := 1;
  setlength(Pages, pageCount);
  Pages[pageCount-1] := Cls_List.Init;
  Pages[pageCount-1].nodeCount := getFirstLineNumber;
  for i := 1 to lineCount do
  begin
    setCellPosition(lineNum);
    lineNum := lineNum + 1;
    for j := 1 to countColumn do
    begin
      s_text := '';
      Cells[j] := Cell.Init(length(head_buttons[j].text), head_height, head_buttons[j].x_pos, y_line_pos, background, s_text);
      Cells[j].Border := Border.Init('-', borderFreeSpace-1, head_buttons[j].x_pos, y_line_pos, y_line_pos, length(head_buttons[j].text));
    end;
    Pages[pageCount-1].add_line(Cells);
  end;
end;

procedure ViewTable.showLine(lineNumber: integer);
var
  i: integer;
begin
  window(x, y, x_border, y_boder);
  line := Pages[pageCount-1].getNode(lineNumber);
  for i := 1 to countColumn do
  begin
      line^.data[i].show;
      line^.data[i].Border.ChangeColor(1);
  end;
end;

procedure ViewTable.showPage();
var
  lineNumber: integer;
begin
  lineNumber := 1;
  while LineNumber <= lineCount do
  begin
    showLine(lineNumber);
    lineNumber := lineNumber + 1;
  end;
end;

procedure ViewTable.nextPage; { �������� ������� ���������� ������ }
begin
  if pageCount <> pageCount then
    pageCount := pageCount + 1;
  showPage();
end;

procedure ViewTable.previousPage;
begin
  if pageCount <> 1 then
    pageCount := pageCount - 1;
  showPage();
end;

function ViewTable.isInteger(text: string): boolean;
var
  i: integer;
begin
  result := true;
  for i := 1 to length(text) do
  begin
    if not (text[i] in ['0'..'9']) then
      result := false;
  end;
end;

function ViewTable.checkDayFormat(day: string): boolean;
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

function ViewTable.checkMonthFormat(month: string): boolean;
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

function ViewTable.checkYearFormat(year: string): boolean;
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

function ViewTable.checkOrganizationName(text: string): boolean;
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

procedure ViewTable.enterDateForm;
const
  otherLen = 2; { ������������� }
  yearLen = 4;
var
  x_, y_: integer;
  text: string;
begin
  x_ := 1;
  y_ := 1;

  write('  .  .');
  gotoxy(x_ + otherLen, y_);
  repeat
    deleteText(otherLen);
    text := enterText(otherLen);
    write(text);
  until (checkDayFormat(text));

  x_ := x_ + otherLen;
  gotoxy(x_ + otherLen, y_);
  repeat
    deleteText(otherLen);
    text := enterText(otherLen);
    write(text);
  until (checkMonthFormat(text));

  x_ := x_ + otherLen;
  gotoxy(x_ + yearLen, y_);
  repeat
    deleteText(yearLen);
    text := enterText(yearLen);
    write(text);
  until (checkYearFormat(text));
end;

function ViewTable.enterOrganizationName: string;
var
  text: string;
begin
  text := '';
  while not checkOrganizationName(text) do
    text := enterText(0);
  result := text;
end;

procedure ViewTable.switchPage(key: char);
begin
  if key = #116 then
    nextPage()
  else if key = #115 then
    previousPage();
end;

function ViewTable.enterText(symbolsCount: integer): string;
var
  count: integer;
  key: char;
begin
  count := 0;
  enterText := '';
  key := ' ';
  if symbolsCount > 0 then
  begin
    repeat
      enterText := enterText + key;
      count := count + 1;
      key := readkey;
    until (count = symbolsCount);
  end
  else if symbolsCount = 0 then
  begin
    repeat
      enterText := enterText + key;
      key := readkey;
    until (key = #32);
  end;
end;

procedure ViewTable.deleteText(count: integer);
var
  x_, y_, stepDel: integer;
begin
  x_ := whereX;
  y_ := whereY;
  stepDel := 1;
  repeat
    x_ := x_ - stepDel;
    gotoxy(x_, y_);
    write(' ');
    count := count - 1;
  until count = 0;
end;

procedure ViewTable.enterTextFormat;
begin
  case on_horizontal_button of
    1: enterOrganizationName;
    2: ;
    3: ;
    4: ;
    5: ;
    6: ;
    7: enterDateForm;
  end;
end;

procedure ViewTable.writeInCell;
const
  height = 1;
var
  x_, y_, width: integer;
  input_field: TextButton;
begin
  x_ := line^.data[1].x_pos;
  y_ := y_border + (borderFreeSpace*2);
  width := line^.data[countColumn].x_pos + line^.data[countColumn].button_width - borderFreeSpace;

  input_field := TextButton.Init(width, height, x_, y_, 0, '');
  input_field.Border := Border.Init('-', borderFreeSpace-1, x_, y_, y_, width);
  input_field.show;
  input_field.Border.ChangeColor(15);

  window(x_, y_, x_ + width, y_ + (borderFreeSpace * 2));
  gotoxy(1, 1);

  //enterTextFormat;
  read(line^.data[on_horizontal_button].text);
  input_field.del;
  input_field.border.del;

  line^.data[on_horizontal_button].show;
  window(x, y, x_border, y_border);
  gotoxy(line^.data[on_horizontal_button].x_pos, line^.data[on_horizontal_button].y_pos);
end;

procedure ViewTable.Main;
var
  key: char;
begin
  showPage;
  key := ' ';
  window(x, y, x_border, y_border);
  line := Pages[pageCount-1].getNode(getFirstLineNumber);
  gotoxy(line^.data[1].x_pos, line^.data[1].y_pos);
  repeat
  key := readkey;
  case key of
    #1: WriteMode;
    #4: DeleteMode;
  end;
  until (key = #32);
end;

procedure ViewTable.WriteMode; { �������� main}
var
  key: char;
begin
  showPosition;
  window(x, y, x_border, y_border);
  line := Pages[pageCount].getNode(1);
  gotoxy(line^.data[1].x_pos, line^.data[1].y_pos);
  repeat
    key := readkey;
    if key = #0 then
    begin
      case readkey of
        #72: Key_UP;
        #80: Key_DOWN;
        #75: Key_LEFT;
        #77: Key_RIGHT;
      end;
      showPosition;
      window(x, y, x_border, y_border);
      line := Pages[pageCount].getNode(on_vertical_button);
      gotoxy(line^.data[on_horizontal_button].x_pos, line^.data[on_horizontal_button].y_pos);
    end
    else if key = #13 then
    begin
      writeInCell;
    end;
  until key = #27;
end;

procedure ViewTable.deleteLineLighting(lineNumber, color: integer);
var
  i: integer;
begin
  line := Pages[pageCount].getNode(lineNumber);
  for i := 1 to countColumn do
    line^.data[i].border.ChangeBackground(color);
end;

procedure ViewTable.deleteCellLighting(lineNumber, cellNumber, color: integer);
begin
  line := Pages[pageCount].getNode(lineNumber);
  line^.data[cellNumber].Border.ChangeBackground(color);
end;

procedure ViewTable.deleteLine(lineNumber: integer);
var
  i: integer;
begin
  line := Pages[pageCount].getNode(lineNumber);
  for i := 1 to countColumn do
  begin
    line^.data[i].text := '';
    line^.data[i].show;
  end;
end;

procedure ViewTable.deleteCell(lineNumber, cellNumber: integer);
begin
  line := Pages[pageCount].getNode(lineNumber);
  line^.data[cellNumber].text := '';
end;

procedure ViewTable.DeleteMode;
var
  key: char;
begin
  key := ' ';
  on_horizontal_button := 1;
  on_vertical_button := 1;
  deleteLineLighting(on_vertical_button, 7);
  repeat
  key := readkey;
  if key = #0 then
  begin
    case readkey of
      #72: DelKey_UP;
      #80: DelKey_DOWN;
    end;
  end
  else if key = #4 then
  begin
    deleteLine(on_vertical_button);
  end
  else if key = #3 then
  begin
    onCellDeleteMode;
  end;
  until (key = #27);
end;

procedure ViewTable.onCellDeleteMode();
var
  key: char;
begin
  key := ' ';
  on_horizontal_button := 1;
  on_vertical_button := 1;
  deleteCellLighting(on_vertical_button, on_horizontal_button, 7);
  repeat
  key := readkey;
  if key = #0 then
  begin
    case readkey of
    #75: DelKey_LEFT;
    #77: DelKey_RIGHT;
    end
  end
  else if (key = #4) then
    deleteCell(on_horizontal_button, on_vertical_button);
  until (key = #32) ;
end;

procedure ViewTable.DelKey_UP;
begin
  deleteLineLighting(on_vertical_button, 0);
  Key_UP;
  deleteLineLighting(on_vertical_button, 7);
end;

procedure ViewTable.DelKey_DOWN;
begin
  deleteLineLighting(on_vertical_button, 0);
  Key_DOWN;
  deleteLineLighting(on_vertical_button, 7);
end;

procedure ViewTable.DelKey_RIGHT;
begin
  deleteCellLighting(on_vertical_button, on_horizontal_button, 0);
  Key_RIGHT;
  deleteCellLighting(on_vertical_button, on_horizontal_button, 7);
end;

procedure ViewTable.DelKey_LEFT;
begin
  deleteCellLighting(on_vertical_button, on_horizontal_button, 0);
  Key_LEFT;
  deleteCellLighting(on_vertical_button, on_horizontal_button, 7);
end;

procedure ViewTable.Key_UP();
begin
  if on_vertical_button = 1 then
    on_vertical_button := Pages[pageNumber].nodeCount
  else
    on_vertical_button := on_vertical_button - 1;
end;

procedure ViewTable.Key_DOWN();
begin
  if on_vertical_button = Pages[pageNumber].nodeCount then
    on_vertical_button := 1
  else
    on_vertical_button := on_vertical_button + 1;
end;

procedure ViewTable.Key_RIGHT();
begin
  if on_horizontal_button = countColumn then
    on_horizontal_button := 1
  else
    on_horizontal_button := on_horizontal_button + 1;
end;

procedure ViewTable.Key_LEFT();
begin
  if on_horizontal_button = 1 then
    on_horizontal_button := countColumn
  else
    on_horizontal_button := on_horizontal_button - 1;
end;

begin
end.

