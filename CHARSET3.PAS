program font;
uses Crt;

const romCharOffset = $FA6E;
      charBlockSize = 8;

function byte2sym(val : byte; sym : char; empty : char) : string;
var res : byte;
var cnt : integer;
var result : string;

begin
     result := '';
     for cnt := 0 to 7 do
     begin
          res := val and 128;
          if res = 128 then begin
             result := concat(result, sym);
          end
          else
          begin
             result := concat(result, empty);
          end;
          val := (val shl 1);
     end;

     byte2sym := result;
end;

procedure printRomChars;
var charVal : byte;
    i : integer;
    ndx : integer;
    line : string;
begin
     for i := 40 to 42 do
     begin
         for ndx := 0 to 7 do
         begin
              charVal := Mem[$F000:romCharOffset + (i*charBlockSize+ndx)];
              line := byte2sym(charVal, chr(80), chr(32));
              writeln(line);
         end;
     end;

end;

procedure printCharLine(txt : string; xp : integer; yp : integer; offset : integer);
var pos : integer;
    line : string;
    charVal : byte;
    currentChar : char;
begin
     line := '';
     for pos := 1 to Length(txt) do
     begin
          currentChar := txt[pos];
          charVal := Mem[$F000:romCharOffset + (ord(currentChar)*charBlockSize+offset)];
          line := concat(line, byte2sym(charVal, chr(40), chr(32)));
     end;
     writeln(line);
end;

procedure printTextLarge(txt : string; xp : integer; yp : integer);
var ndx : integer;
begin
     for ndx :=0 to 7 do
     begin
          gotoxy(xp, yp+ndx);
          printCharLine(txt, 0, 0, ndx);
     end;
end;

begin
  clrscr;
  { printCharLine('ABC', 0, 0, 0); }
  textcolor(Green);
  textbackground(Blue);
  printTextLarge('Test', 5, 5);
  readln;
end.
