program GAME1;

        uses crt;

        type   ALPTR = ^ALIEN;
               ALIEN = record
                               value : char;
                               attribute : byte;
                               xp : byte;
                               yp : byte;
                               xdir : shortint;
                               ydir : shortint;
                               next : ALPTR;
                         end;

        type   SCRTYPE = record
                               character : char;
                               attribute : byte;
                         end;

        type  GAMESTATE = (Initial, Running, Exit, Lost);

        const ALIENCHR = 79;
              ALIENATT = 10;
              BLANKCHR = 32;
              BLANKATT = 0;

              KEYESC = #27;
              KEYUP = #72;
              KEYDOWN = #80;
              KEYLEFT = #75;
              KEYRIGHT = #77;

              MINX = 2;
              MAXX = 79;
              MINY = 2;
              MAXY = 24;

        var altop : ALPTR;
            xdir : shortint;
            ydir : shortint;
            screen : array [1..25, 1..80] of SCRTYPE absolute $B800:0000;
            state : GAMESTATE;
            score : integer;
            delaytime : integer;

        (* Writes list elements to console *)
        procedure PrintList;
        var current : ALPTR;
        begin
             if altop = NIL then
             begin
                  writeln('Liste ist leer.');
             end
             else
             begin
                 current := altop;
                 repeat
                       writeln(current^.value,'-',current^.xp,',',current^.yp);
                       if current^.next <> NIL then
                          current := current^.next;
                 until current^.next = NIL;
                 if(current <> altop) then writeln(current^.value);
             end;
        end;

        (* Adds value to end of list *)
        procedure AddAlienValue(value : char; attribute : byte; xp : byte; yp : byte; xdir : shortint; ydir : shortint);
        var current : ALPTR;
            element : ALPTR;
        begin
             New(element);
             element^.value := value;
             element^.attribute := attribute;
             element^.xp := xp;
             element^.yp := yp;
             element^.xdir := xdir;
             element^.ydir := ydir;
             element^.next := NIL;

             if altop = NIL then
             begin
                  altop := element;
             end
             else
             begin
                  current := altop;
                  while current^.next <> NIL do
                  begin
                       current := current^.next;
                  end;
                  current^.next := element;
             end;
        end;

        (* Prints ASCII Table to Screen *)
        procedure AsciiTable;
        var i : Byte;
        begin
             clrscr;
             for i:=1 to 255 do
             begin
                  write(i,'=',chr(i),' ');
             end;
             readkey;
        end;

        (* Draws the aliens to the screen *)
        procedure DrawAliens;
        var current : ALPTR;
        begin
             if altop <> NIL then
             begin
                 current := altop;
                 repeat
                       screen[current^.yp, current^.xp].character := current^.value;
                       screen[current^.yp, current^.xp].attribute := current^.attribute;
                       if current^.next <> NIL then
                          current := current^.next;
                 until current^.next = NIL;
                 if((current <> altop) and (current^.value <> chr(255))) then
                 begin
                      screen[current^.yp, current^.xp].character := current^.value;
                      screen[current^.yp, current^.xp].attribute := current^.attribute;
                 end;
             end;
        end;

        (* Moves an alien on the screen *)
        procedure MoveSingleAlien(current : ALPTR);
        begin
             screen[current^.yp, current^.xp].character := chr(ALIENCHR+2);
             screen[current^.yp, current^.xp].attribute := BLANKATT+1;
             if((current^.yp + current^.ydir < MINY) or
                (current^.yp + current^.ydir > MAXY) or
                (Random(9) = 0)) then
                 current^.ydir := -current^.ydir;
             if((current^.xp + current^.xdir < MINX) or
                (current^.xp + current^.xdir > MAXX) or
                (Random(9) = 0)) then
                 current^.xdir := -current^.xdir;
             current^.yp := current^.yp + current^.ydir;
             current^.xp := current^.xp + current^.xdir;
             screen[current^.yp, current^.xp].character := chr(ALIENCHR);
             screen[current^.yp, current^.xp].attribute := ALIENATT;
        end;

        (* Moves the aliens on the screen *)
        procedure MoveAliens;
        var current : ALPTR;
        begin
             if altop <> NIL then
             begin
                 current := altop;
                 repeat
                       MoveSingleAlien(current);
                       if current^.next <> NIL then
                          current := current^.next;
                 until current^.next = NIL;
                 if(current <> altop) then
                 begin
                      MoveSingleAlien(current);
                 end;
             end;
        end;

        (* Draws score on top of screen *)
        procedure DrawScore;
        begin
             gotoxy(2,1);
             textcolor(5);
             write('SCORE: ', score);
        end;

        (* Disposes the worm elements *)
        procedure DisposeAliens;
        var current : ALPTR;
        var free : ALPTR;
        begin
             current := altop;
             if current <> NIL then
             begin
                  while current^.next <> NIL do
                  begin
                       free := current;
                       current := current^.next;
                       dispose(free);
                  end;
                  dispose(current);
             end;
             altop := NIL;
        end;

        (* The actual game *)
        procedure GameLoop;
        var input : char;
        begin
             state := Running;
             score := 0;
             DrawScore;
             DrawAliens;
             while state = Running do
             begin
                  MoveAliens;
                  delay(delaytime);

                  if keypressed then
                  begin
                       input := readkey;
                       if input = #0 then
                       begin
                            input := readkey;
                            if input = KEYLEFT then
                            begin
                                 xdir := -1;
                                 ydir := 0;
                            end
                            else if input = KEYRIGHT then
                            begin
                                 xdir := 1;
                                 ydir := 0;
                            end
                            else if input = KEYDOWN then
                            begin
                                 xdir := 0;
                                 ydir := 1;
                            end
                            else if input = KEYUP then
                            begin
                                 xdir := 0;
                                 ydir := -1;
                            end
                            else if input = KEYESC then
                            begin
                                 state := Exit;
                            end
                       end
                       else if input = KEYESC then
                       begin
                            state := Exit;
                       end;
                  end;
             end;
        end;

        (* Initializes the game *)
        procedure InitGame;
        var i : shortint;
            xa : shortint;
            ya : shortint;
            dir : byte;
            xdir : shortint;
            ydir : shortint;
        begin
             Clrscr;
             Randomize;
             for i := 1 to 5 do
             begin
                  xa := Random(MAXX - MINX) + MINX;
                  ya := Random(MAXY - MINY) + MINY;

                  dir := Random(3);
                  if dir = 0 then
                  begin
                       xdir := 1;
                       ydir := 1;
                  end
                  else if dir = 1 then
                  begin
                       xdir := -1;
                       ydir := -1;
                  end
                  else if dir = 2 then
                  begin
                       xdir := -1;
                       ydir := 1;
                  end
                  else if dir = 3 then
                  begin
                       xdir := 1;
                       ydir := -1;
                  end;

                  AddAlienValue(chr(ALIENCHR), ALIENATT, xa, ya, xdir, ydir);
             end;

             state := Initial;

             xdir := -1;
             ydir := 0;

             delaytime := 100;
        end;

        (* Main routine *)
        begin
             altop := NIL;

             while state <> Exit do
             begin
                  InitGame;
                  GameLoop;
             end;
        end.
end.