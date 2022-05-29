unit base_menu;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Crt, base_graphic, example_file;

type
    Menu = class sealed
      x, y, x_border, y_border, background: integer;
      buttons: array[1..10] of TextButton;
      menu_border: Border;

      countButtons: integer;
    private
      function Key_UP(on_button: integer): integer;
      function Key_DOWN(on_button: integer): integer;
      procedure press_enter(on_button: integer);

    public
      procedure Show_menu;
      procedure Main;
      constructor Init(start_x, start_y, border_x , border_y, abs_background: integer);
      {procedure paint_background;}
      destructor del;
  end;

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
    text_size = 14;
    spaceBetweenButtons = 2;

  var
    text: string[text_size];
    cord_x, cord_y, i: integer;

  begin
    Window(x, y, x_border, y_border);
    {x � y ������������ ������������ ����. �� ���� ���� � ����� x=10 � y=10 �� ��� �������� ���������� ����������. � ����������� ����� ������ ��� ������� ����� ��� �� ���������}
    x := 1;
    y := 1;
    {Paint_Background();}
    cord_x := (x_border div 2) - (text_size div 2);
    cord_y := y_border div 2;

    for i:= 1 to base_count do
      begin
        text := '���� ������ �' + inttostr(i);
        buttons[i] := TextButton.Init(text_size, spaceBetweenButtons, cord_x, cord_y, background, text);
        buttons[i].Create();
        cord_y := cord_y + spaceBetweenButtons;
      end;
    menu_border := border.Init('~', 9, buttons[1].x_pos, buttons[1].y_pos, buttons[countButtons].y_pos, text_size);
    menu_border.create;
  end;

  function Menu.Key_UP(on_button: integer): integer;
  begin
    buttons[on_button].background := 0;
    buttons[on_button].Create();
    if on_button = 1 then
      on_button := countButtons
    else
      on_button := on_button - 1;
    Key_UP := on_button;
  end;

  function Menu.Key_DOWN(on_button: integer): integer;
  begin
    buttons[on_button].background := 0;
    buttons[on_button].Create();
    if on_button = countButtons then
      on_button := 1
    else
      on_button := on_button + 1;
    Key_DOWN := on_button;
  end;

  procedure Menu.press_enter(on_button: integer);
  const
    x_size = 80;
    y_size = 25;
  var
    base1: ViewTable;
  begin
    Window(x, y, x_size, y_size);
    TextBackground(0);
    del;
    ClrScr;

    { ��������� ������ ������� ������� �������� ������ � ����� ������� }
    base1 := ViewTable.Init(4, 4, x_border, y_border, 8, 1, 0);
    case on_button of
      1:
       base1.show_head;
      {2:
        ;
      3:
       ;}
    end;
  end;

  procedure Menu.Main;
  var
    run: boolean;
    on_button: integer;
  begin
    Show_menu();

    run := true;
    on_button := 1;
    window(x, y, x_border, y_border);
    gotoxy(buttons[on_button].x_pos, buttons[on_button].y_pos);

    while run do
    begin
      case readkey of
      #72:
        begin
          on_button := Key_UP(on_button);
        end;
      #80:
        begin
          on_button := Key_DOWN(on_button);
        end;
      #13:
        begin
          press_enter(on_button);
          run := false;
        end;
      end;
      if run then
      begin
        buttons[on_button].background := 2;
        gotoxy(buttons[on_button].x_pos, buttons[on_button].y_pos);
        buttons[on_button].Create();
      end;
    end;
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
  end;
end.
