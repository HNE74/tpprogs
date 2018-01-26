program MOVETEST;

     uses crt;

     type   SCRTYPE = record
                    character : char;
                    attribute : byte;
     end;

     var
        screen : array [1..25, 1..80] of SCRTYPE absolute $B800:0000;
        buffer : array [1..25, 1..80] of SCRTYPE;

     begin

          buffer[10,10].character := chr(79);
          buffer[10,10].attribute := 4;

          repeat
          until keypressed;

          Move(buffer, screen, SizeOf(screen));

          repeat
          until keypressed;
     end.

end.