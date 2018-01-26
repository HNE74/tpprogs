program font;

const romCharOffset = $FA6E;
      charBlockSize = 8;

var chrPtr: ^byte;
var ipt: byte;

function byte2(val : byte) : string;
var res : byte;
var cnt : integer;
var result : string;

begin
     result := '';
     for cnt := 0 to 7 do
     begin
          res := val and 128;
          if res = 128 then begin
             result := concat(result, '1');
          end
          else
          begin
             result := concat(result, '0');
          end;
          val := (val shl 1);
     end;

     byte2bin := result;
end;

procedure printRomChars;
var charVal : byte;
    i : integer;
    ndx : integer;
    line : string;
begin
     for i := 0 to 255 do
     begin
         for ndx := 0 to 7 do
         begin
              charVal := Mem[$F000:romCharOffset + (i*charBlockSize+ndx)];
              line := byte2bin(charVal);
              writeln(line);
         end;
         writeln('=========================');
         readln;
     end;

end;

begin
  printRomChars;
  readln;
end.
