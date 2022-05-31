unit storage;

{$mode ObjFPC}{$H+}
interface
uses
  Classes, SysUtils, base_graphic;

type PLine = ^Line_Node;
     Line_Node = record
       data: array[1..7] of Cell;
       number: integer;
       next: PLine;
       previous: PLine;
     end;
     // Todo: Создать класс листа для передачи в класс для работы с базой

     Cls_List = class
       nodeCount: integer;
       Line: PLine;
       constructor Init;
       procedure getNode(n: integer);
       procedure add_line(cells: array of Cell);
       procedure rewrite_cell;
       procedure save;
       {procedure rewrite_line;}
     end;

implementation
  constructor Cls_List.Init;
  begin
    nodeCount := 1;
    new(Line);
  end;

  procedure Cls_List.rewrite_cell;
  begin
  end;

  procedure Cls_List.add_line(cells: array of Cell);
  var
    new_Node, list_copy: PLine;
  begin
     new(new_Node);
     new_Node^.data := cells;
     new_Node^.next := nil;

     if Line = nil then
     begin
       new_node^.previous := nil;
       Line := new_node;
     end
     else
     begin
       list_copy := Line;
       while list_copy^.next <> nil do
         list_copy := list_copy^.next;
       list_copy^.next := new_node;
       new_node^.previous := list_copy;
     end;
     new_Node^.number := nodeCount;
     nodeCount := nodeCount + 1;
  end;

  procedure Cls_List.save;
  begin

  end;

  procedure Cls_List.getNode(n: integer);
  var
    list_copy: PLine;
  begin
     list_copy := Line;
     while (list_copy^.number <> n) and (list_copy^.previous <> nil) do
       list_copy := list_copy^.previous;
     list_copy := Line;
     while (list_copy^.number <> n) and (list_copy <> nil) do
       list_copy := list_copy^.next;

     Line := list_copy;
  end;

end.

