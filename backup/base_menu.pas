unit base_menu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, base_graphic, table_manipulation, tables;

type
    Menu = class sealed
      x, y, x_border, y_border, background: integer;
      buttons: array[1..10] of TextButton;
      menu_border: Border;
      countButtons: byte;
    strict private
      procedure press_enter(on_button: integer);
      procedure Show_menu;
      function Key_UP(on_button: integer): integer;
      function Key_DOWN(on_button: integer): integer;
    public
      procedure Main;
      constructor Init(start_x, start_y, border_x , border_y, abs_background: integer);
      {procedure paint_background;}
      destructor del;
  end;

  _table1 = specialize ViewTable<Table1>;
  _table2 = specialize ViewTable<Table2>;
  _table3 = specialize ViewTable<Table3>;

implementation
constructor Menu.Init(start_x, start_y, border_x , border_y, abs_background: integer);
  begin
    x := start_x;
    y := start_y;
    x_border := border_x;
    y_border := border_y;
    countButtons := 3;
    background := abs_background;
  end;

  procedure Menu.Show_menu();
  const
    base_count = 3;
    spaceBetweenButtons = 2;
    text_size = 10;
  var
    text: string;
    cord_x, cord_y, i: integer;
    //allert: TextButton;
  begin
    Window(x, y, x_border, y_border);
    {x � y ������������ ������������ ����. �� ���� ���� � ����� x=10 � y=10 �� ��� �������� ���������� ����������. � ����������� ����� ������ ��� ������� ����� ��� �� ���������}
    {Paint_Background();}
    //cord_x := (x_border div 2) - (text_size div 2);
    //cord_y := (y_border div 2) + spaceBetweenButtons;
    cord_x := x;
    cord_y := y;

    for i:= 1 to base_count do
      begin
        text := '������� �' + inttostr(i);
        buttons[i] := TextButton.Init(text_size, spaceBetweenButtons, cord_x, cord_y, background, text);
        buttons[i].show();
        cord_y := cord_y + spaceBetweenButtons;
      end;
    menu_border := border.Init('~', 9, buttons[1].x_pos, buttons[1].y_pos, buttons[countButtons].y_pos, text_size);
    menu_border.show;
  end;

  function Menu.Key_UP(on_button: integer): integer;
  begin
    buttons[on_button].background := 0;
    buttons[on_button].show();
    if on_button = 1 then
      on_button := countButtons
    else
      on_button := on_button - 1;
    Key_UP := on_button;
  end;

  function Menu.Key_DOWN(on_button: integer): integer;
  begin
    buttons[on_button].background := 0;
    buttons[on_button].show();
    if on_button = countButtons then
      on_button := 1
    else
      on_button := on_button + 1;
    Key_DOWN := on_button;
  end;

  procedure Menu.press_enter(on_button: integer);
  var
    table1: _table1;
    table2: _table2;
    table3: _table3;
  begin
    menu_border.del;
    del;

    { ��������� ������ ������� ������� �������� ������ � ����� ������� }
    case on_button of
      1: begin
        table1 := _table1.Create;
        table1.main;
      end;
      2: begin
        table2 := _table2.Create;
        table2.main;
      end;
      3: begin
        table3 := _table3.Create;
        table3.main;
      end;
    end;
  end;

  procedure Menu.Main;
  var
    run: boolean;
    on_button: integer;
    key: char;
  begin
    Show_menu;
    window(x, y, x_border, y_border);
    run := true;
    on_button := 1;
    buttons[on_button].background := 5;
    buttons[on_button].show;
    while run do
    begin
      key := readkey;
      if key = #0 then
      begin
        case readkey of
        #72: begin
            on_button := Key_UP(on_button);
          end;
        #80: begin
            on_button := Key_DOWN(on_button);
          end;
        end
      end
      else if key = #13 then
      begin
        press_enter(on_button);
        run := false;
      end;
      if run then
      begin
        buttons[on_button].background := 5;
        gotoxy(buttons[on_button].x_pos, buttons[on_button].y_pos);
        buttons[on_button].show();
      end;
    end
  end;

  {procedure Menu.paint_background();
  var
    i: integer;
  begin
    TextBackground(background);

    for i := 1 to y_border do
    begin
      gotoxy(1, i);
      write('1');
    end;
  end;  }

  destructor Menu.Del;
  var
    i: integer;
  begin
    for i := 1 to countButtons do
      buttons[i].del;
    self := nil;
  end;
end.

