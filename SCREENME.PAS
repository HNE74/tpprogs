program screenmem;

uses crt;

type ScrType=Record
       Character: char;
       Attribute: byte;
     end;

var
   Screen: array [1..25, 1..80] of ScrType absolute $B800:0000;
   i: ShortInt;

begin
     for i:=1 to 80 do
     begin
          Screen[1, i].Character := '*';
          Screen[1, i].Attribute := 20;
     end;
     Readkey;
end.