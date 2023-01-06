unit storage;

{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, GeneralTypes, base_graphic;
const
  MAX_COUNT_OF_COLUMNS = 7;
type
     PLine = ^Line_Node;
     Line_Node = record
       data: array[1..MAX_COUNT_OF_COLUMNS] of Cell;
       number: word;
       next: PLine;
       previous: PLine;
     end;

     { Cls_List }

     Cls_List = class
       strict private
         Line: PLine;
         countOfColumns: byte;
         procedure readLineFromFile(var f: file; Cline: PLine);
         procedure writingLineInAFile(var f: file; Cline: PLine);
         procedure _pullOffElmFromList(var elm: PLine);
         procedure _insert(var elm: PLine; i: integer);
         procedure _renumberList;
         procedure _propetiesTransmission(sender: PLine; var recipient: PLine);
       public
         nodeCount: integer;
         constructor Init(countColumns: byte);
         destructor Destroy; override;
         function getNode(n: integer): PLine;
         procedure add_line(cells: array of Cell);
         procedure rewrite_cell;
         procedure insert(var elm: PLine; var replaceableNode: PLine);
         procedure delete(lineNumber: word);
         procedure save(name: string);
         procedure load(name: string);
         {procedure rewrite_line;}
     end;

implementation
  constructor Cls_List.Init(countColumns: byte);
  begin
    nodeCount := 0;
    countOfColumns := countColumns;
    Line:=nil;
  end;

  procedure Cls_List.rewrite_cell;
  begin
  end;

  {Добавляет линию таблицы в список.
  В процессе создается копия(list_copy) свойства класса Line,
  затем копии присваивается адрес параметра записи "next" до момента,
  пока не будет найден последний элемент списка.
  После нахождения в конец становится
  указатель на запись, содержащую линию}
  procedure Cls_List.add_line(cells: array of Cell);
  var
    new_node, list_copy: PLine;
  begin
     new(new_node);
     new_Node^.data := cells;
     new_Node^.next := nil;
     nodeCount := nodeCount + 1;

     if Line = nil then
     begin
       new_node^.previous := nil;
       Line := new_node;
       Line^.number := 1;
     end
     else
     begin
       list_copy := Line;
       while list_copy^.next <> nil do
         list_copy := list_copy^.next;
       list_copy^.next := new_node;
       new_node^.previous := list_copy;
       new_node^.number := list_copy^.number + 1;
     end;
  end;

  procedure Cls_List.writingLineInAFile(var f: file; Cline: PLine);
  const
    STR_ID = '@';
    INT_ID = '#';
  var
    i: integer;
    text: string;
    textW: writeableRecord;
  begin
    for i := 1 to countOfColumns do
    begin
     text := Cline^.data[i].getText();
     if not isInteger(text) then
     begin
      textW.text := join('$', split(' ', text));
      textW.Type_ID := STR_ID;
      BlockWrite(f, textW, 1)
     end
     else
     begin
      textW.number := strToInt(text);
      textW.Type_ID := INT_ID;
      BlockWrite(f, textW, 1);
     end;
    end;
  end;

  procedure Cls_List.save(name: string);
   const
     FType = '.dat';
   var
     f: file;
     line_copy: Pline;
   begin
     name := name + FType;
     line_copy := Line;
     try
       assign(f, name);
       rewrite(f, sizeof(writeableRecord));
       while line_copy^.next <> nil do
       begin
         writingLineInAFile(f, line_copy);
         line_copy := line_copy^.next;
       end;
       close(f);
     except
     end;
   end;

   procedure Cls_List.readLineFromFile(var f: file; Cline: PLine);
   const
     STR_ID = '@';
     INT_ID = '#';
   var
     i: byte;
     intermediateText: writeableRecord;
     text: string;
   begin
     for i := 1 to countOfColumns do
     begin
       BlockRead(f, intermediateText, 1);
       case intermediateText.Type_ID of
         STR_ID: text := join(' ', split('$', intermediateText.text));
         INT_ID: text := intToStr(intermediateText.number);
       end;
       Cline^.data[i].setText(text);
     end;
   end;

   procedure Cls_List.load(name: string);
   const
     FType = '.dat';
   var
     f: File;
     line_copy: PLine;
   begin
     name := name + FType;
     line_copy := Line;
     try
       assign(f, name);
       reset(f, sizeof(writeableRecord));
       while not EOF(f) do
       begin
         readLineFromFile(f, line_copy);
         if line_copy^.next <> nil then
           line_copy := line_copy^.next;
       end;
       close(f);
     except
     end;
   end;

  {Возвращает строку таблицы с определенным номером.
  Создается копия (line_copy) свойства класс Line ей передается ссылка на следующий элемент,
  пока не будет найден элемент списка с нужным номером.
  }
  function Cls_List.getNode(n: integer): PLine;
  var
    line_copy: PLine;
  begin
     if nodeCount > 0 then
     begin
       line_copy := Line;
       if line_copy <> nil then
       begin
         while (line_copy^.number <> n) and (line_copy^.next <> nil) do
           line_copy := line_copy^.next;
         getNode := line_copy;
       end;
     end;
  end;

  procedure Cls_List.delete(lineNumber: word);
  var
    i: integer;
    newEmptyElm, elm: PLine;
  begin
    new(newEmptyElm);
    newEmptyElm^.next := nil;
    newEmptyElm^.previous := nil;
    elm := getNode(lineNumber);
    newEmptyElm^.number := elm^.number;
    for i := 1 to countOfColumns do
    begin
      newEmptyElm^.data[i] := Cell.Init(elm^.data[i].button_width, elm^.data[i].button_height,
                                        elm^.data[i].x_pos, elm^.data[i].y_pos, elm^.data[i].background, '');
      newEmptyElm^.data[i].border := Border.Init(elm^.data[i].border.symbol,
                                      elm^.data[i].border.XborderFreeSpace, elm^.data[i].border.YborderFreeSpace,
                                      elm^.data[i].border.start_x, elm^.data[i].border.top_y, elm^.data[i].border.top_y,
                                      elm^.data[i].border.text_size);
      elm^.data[i].border.Destroy;
      elm^.data[i].Destroy;
    end;

    _pullOffElmFromList(elm);
    _renumberList;

    _insert(newEmptyElm, newEmptyElm^.number);
    _renumberList;
  end;

  procedure Cls_List.insert(var elm: PLine; var replaceableNode: PLine);
  var
    i: word;
    elmDataCopy: PLine;
  begin
    new(elmDataCopy);
    for i := 1 to countOfColumns do
    begin
      elmDataCopy^.data[i] := Cell.Create;
      elmDataCopy^.data[i].border := Border.Create;
    end;
    _propetiesTransmission(elm, elmDataCopy);

    i := replaceableNode^.number;
    _pullOffElmFromList(elm);
    _renumberList;
    _insert(elm, i);
    _renumberList;

    replaceableNode := getNode(i+1);
    _propetiesTransmission(replaceableNode, elm);
    _propetiesTransmission(elmDataCopy, replaceableNode);
    for i := 1 to countOfColumns do
    begin
      elmDataCopy^.data[i].border.Destroy;
      elmDataCopy^.data[i].Destroy;
    end;
  end;

  procedure Cls_List._insert(var elm: PLine; i: integer);
  var
    node: PLine;
  begin
    if i = nodeCount then
    begin
      node := getNode(i-1);
      node^.next := elm;
      elm^.previous := node;
    end
    else if i > 1 then
    begin
      node := getNode(i-1);
      elm^.next := node^.next;
      elm^.previous := node;
      node^.next^.previous := elm;
      node^.next := elm;
    end
    else if i = 1 then
    begin
      node := getNode(i);
      node^.previous := elm;
      elm^.next := node;
      Line := elm;
    end;
    elm^.number := i;
  end;

  procedure Cls_List._pullOffElmFromList(var elm: PLine);
  var
    newN, node: PLine;
  begin
    new(newN);
    newN^.data := elm^.data;
    newN^.next := nil;
    newN^.previous := nil;

    node := elm^.previous;
    if elm^.number = nodeCount then
      node^.next := nil
    else if elm^.number > 1 then
    begin
      node^.next := elm^.next;
      node^.next^.previous := node;
    end
    else if elm = Line then
    begin
      Line := Line^.next;
      Line^.previous := nil;
    end;
    dispose(elm);
    elm := newN;
  end;

  procedure Cls_List._renumberList;
  var
    j: integer;
    node: PLine;
  begin
    node := Line;
    for j := 1 to nodeCount do
     begin
      if node <> nil then
      begin
        if node^.previous <> nil then
          node^.number := node^.previous^.number + 1
        else
          node^.number := 1;
        node := node^.next
      end;
     end;
  end;

  procedure Cls_List._propetiesTransmission(sender: PLine; var recipient: PLine);
  var
    cell: byte;
  begin
    for cell := 1 to countOfColumns do
    begin
      if (sender^.data[cell] <> nil) and (recipient^.data[cell] <> nil) then
      begin
        recipient^.data[cell].x_pos := sender^.data[cell].x_pos;
        recipient^.data[cell].y_pos := sender^.data[cell].y_pos;
        recipient^.data[cell].border.start_x := sender^.data[cell].border.start_x;
        recipient^.data[cell].border.last_x := sender^.data[cell].border.last_x;
        recipient^.data[cell].border.top_y := sender^.data[cell].border.top_y;
        recipient^.data[cell].border.bottom_y := sender^.data[cell].border.bottom_y;
        recipient^.data[cell].button_width := sender^.data[cell].button_width;
        recipient^.data[cell].button_height := sender^.data[cell].button_height;
      end;
    end;
  end;

  {
  Полность удаляет список
  }
  destructor Cls_List.Destroy;
  var
    line_copy: PLine;
  begin
    line_copy := Line;
    while Line^.number < nodeCount do
    begin
      Line := Line^.next;
      Dispose(line_copy);
      line_copy := Line;
    end;
    Line := nil;
  end;
end.

