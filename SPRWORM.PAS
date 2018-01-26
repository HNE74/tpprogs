program SUPERWORM;

        uses crt;

        type   WRPTR = ^WORM;
               WORM = record
                               value : char;
                               attribute : byte;
                               xp : byte;
                               yp : byte;
                               next : WRPTR;
                         end;

        type   SCRTYPE = record
                               character : char;
                               attribute : byte;
                         end;

        type  GAMESTATE = (Initial, Running, Apple1, Apple2, Exit, Lost);

        const WALLCHR = 219;
              WALLATT = 2;
              WORMHEAD = 2;
              WORMBODY = 79;
              WORMHATT = 11;
              WORMBATT = 10;
              BLANKCHR = 32;
              BLANKATT = 0;
              APPLECHR = 4;
              APPLEATT1 = 12;
              APPLEATT2 = 13;
              OBSTACHR = 24;
              OBSTAATT = 7;

              KEYESC = #27;
              KEYUP = #72;
              KEYDOWN = #80;
              KEYLEFT = #75;
              KEYRIGHT = #77;

              MINX = 1;
              MAXX = 40;
              MINY = 2;
              MAXY = 25;

              romCharOffset = $FA6E;
              charBlockSize = 8;

        var top : WRPTR;
            xdir : shortint;
            ydir : shortint;
            screen : array [1..MAXY, 1..MAXX] of SCRTYPE absolute $B800:0000;
            state : GAMESTATE;
            score : integer;
            highscore : integer;
            delaytime : integer;
            origmode : integer;

        (* Returns pattern for byte *)
        function Byte2sym(val : byte; sym : char; empty : char) : string;
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


        (* Prints character line for large letter text *)
        procedure PrintCharLine(txt : string; xp : integer; yp : integer; offset : integer);
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
                  line := concat(line, byte2sym(charVal, chr(219), chr(32)));
             end;
             writeln(line);
        end;

        (* Prints large letter text *)
        procedure PrintTextLarge(txt : string; xp : integer; yp : integer);
        var ndx : integer;
        begin
             for ndx :=0 to 7 do
             begin
                  gotoxy(xp, yp+ndx);
                  printCharLine(txt, 0, 0, ndx);
             end;
        end;

        (* Toggles cursor on and off *)
        procedure ToggleCursor;
        var num : word;
        begin
             port[$03D4] := $0A;
             num := port[$03D5];
             port[$03D4] := $0A;
             port[$03D5] := num xor 32;
        end;

        (* Changes screen mode to 40 columns *)
        procedure AdjustScreenMode;
        begin
             origmode := LastMode;
             TextMode(CO40);
             delay(1000);
        end;

        (* Resets screen mode to original setting *)
        procedure ResetScreenMode;
        begin
             TextMode(origmode);
        end;

        (* Writes list elements to console *)
        procedure PrintList;
        var current : WRPTR;
        begin
             if top = NIL then
             begin
                  writeln('Liste ist leer.');
             end
             else
             begin
                 current := top;
                 repeat
                       writeln(current^.value,'-',current^.xp,',',current^.yp);
                       if current^.next <> NIL then
                          current := current^.next;
                 until current^.next = NIL;
                 if(current <> top) then writeln(current^.value);
             end;
        end;

        (* Adds value to end of list *)
        procedure AddValue(value : char; attribute : byte; xp : byte; yp : byte);
        var current : WRPTR;
            element : WRPTR;
        begin
             New(element);
             element^.value := value;
             element^.attribute := attribute;
             element^.xp := xp;
             element^.yp := yp;
             element^.next := NIL;

             if top = NIL then
             begin
                  top := element;
             end
             else
             begin
                  current := top;
                  while current^.next <> NIL do
                  begin
                       current := current^.next;
                  end;
                  current^.next := element;
             end;
        end;

        (* Pushes value at the begin of list *)
        procedure PushValue(value : char; attribute : byte; xp : byte; yp : byte);
        var element : WRPTR;
        begin
             New(element);
             element^.value := value;
             element^.attribute := attribute;
             element^.xp := xp;
             element^.yp := yp;
             element^.next := top;
             top := element;
        end;

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

        (* Puts apple on random position on screen *)
        procedure PutApple;
        var xa : shortint;
            ya : shortint;
        begin
             randomize;
             repeat
                   xa := random(MAXX-2)+1;
                   ya := random(MAXY-2)+2;
             until screen[ya, xa].character = chr(BLANKCHR);
             screen[ya, xa].character := chr(APPLECHR);
             if (score > 1) and ((score+1) mod 2 = 0) then
             begin
                  screen[ya, xa].attribute := APPLEATT2;
             end else
             begin
                  screen[ya, xa].attribute := APPLEATT1;
             end;

        end;

        (* Puts obstacles on random positions on screen *)
        procedure PutObstacles;
        var xa : shortint;
            ya : shortint;
            i : shortint;
        begin
             randomize;
             for i:=1 to 3 do
             begin
                  repeat
                        xa := random(MAXX-2)+1;
                        ya := random(MAXY-2)+3;
                  until screen[ya, xa].character = chr(BLANKCHR);
                  screen[ya, xa].character := chr(OBSTACHR);
                  screen[ya, xa].attribute := OBSTAATT;
             end;
        end;

        (* Draw game scene to console *)
        procedure DrawGameScene;
        var i : ShortInt;
        begin
             clrscr;
             delay(500);
             for i:=MINX to MAXX do
             begin
                  screen[MINY,i].character := chr(WALLCHR);
                  screen[MINY,i].attribute := WALLATT;
                  screen[MAXY,i].character := chr(WALLCHR);
                  screen[MAXY,i].attribute := WALLATT;
             end;

             for i:=MINY to MAXY do
             begin
                  screen[i,MINX].character := chr(WALLCHR);
                  screen[i,MINX].attribute := WALLATT;
                  screen[i,MAXX].character := chr(WALLCHR);
                  screen[i,MAXX].attribute := WALLATT;
             end;
             PutObstacles;
        end;

        (* Draws the worm to the screen *)
        procedure DrawWorm;
        var current : WRPTR;
        begin
             if top <> NIL then
             begin
                 current := top;
                 repeat
                       screen[current^.yp, current^.xp].character := current^.value;
                       screen[current^.yp, current^.xp].attribute := current^.attribute;
                       if current^.next <> NIL then
                          current := current^.next;
                 until current^.next = NIL;
                 if((current <> top) and (current^.value <> chr(255))) then
                 begin
                      screen[current^.yp, current^.xp].character := current^.value;
                      screen[current^.yp, current^.xp].attribute := current^.attribute;
                 end;
             end;
        end;

        (* Checks the state of the square on the game screen *)
        procedure CheckSquare(yp : shortint; xp : shortint);
        var sqchar : char;
            sqattr : byte;
        begin
             sqchar := screen[yp, xp].character;
             sqattr := screen[yp, xp].attribute;

             if (xp <= MINX) or (xp >= MAXX) or (yp <= MINY) or (yp >= MAXY) then
             begin
                  state := Lost;
             end
             else if sqchar = chr(WALLCHR) then
             begin
                  state := Lost;
             end
             else if (sqchar = chr(WORMBODY)) or (sqchar = chr(OBSTACHR)) then
             begin
                  state := Lost;
             end
             else if (sqchar = chr(APPLECHR)) and (sqattr = APPLEATT1) then
             begin
                  state := Apple1;
             end
             else if (sqchar = chr(APPLECHR)) and (sqattr = APPLEATT2) then
             begin
                  state := Apple2;
             end
        end;

        (* Draws score on top of screen *)
        procedure DrawScore;
        begin
             gotoxy(2,1);
             textcolor(5);
             write('SCORE: ', score);
             gotoxy(2,2);
        end;

        (* Disposes the worm elements *)
        procedure DisposeWorm;
        var current : WRPTR;
        var free : WRPTR;
        begin
             current := top;
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
             top := NIL;
        end;

        (* Crash of the worm against obstacle *)
        procedure CrashWorm;
        var current : WRPTR;
            input : char;
            i : integer;
        begin
             current := top;
             if current <> NIL then
             begin
                  while current^.next <> NIL do
                  begin
                       current^.value := chr(42);
                       current := current^.next;
                  end;
             end;
             current^.value := chr(255);
             DrawWorm;
             DisposeWorm;
             delay(1000);
             gotoxy(15,1);
             Textcolor(6);
             PrintTextLarge('GAME', 5, 5);
             PrintTextLarge('OVER', 5, 14);
             gotoxy(15,2);
             for i:=85 to 100 do
             begin
                  sound(i);
                  delay(25);
             end;
             NoSound;
             input := readkey;
             if input = KEYESC then state := Exit;
        end;

        (* Moves the worm one step forward *)
        procedure MoveWorm;
        var current : WRPTR;
            xdel : shortint;
            ydel : shortint;
        begin
             current := top;
             xdel := current^.xp;
             ydel := current^.yp;

             if top <> NIL then
             begin
                  while current^.next <> NIL do
                  begin
                       current^.xp := current^.next^.xp;
                       current^.yp := current^.next^.yp;
                       current := current^.next;
                  end;

                  CheckSquare(current^.yp + ydir, current^.xp + xdir);
                  current^.xp := current^.xp + xdir;
                  current^.yp := current^.yp + ydir;
             end;

             if (state = Apple1) or (state = Apple2) then
             begin
                  sound(50);
                  if state = Apple1 then
                  begin
                     PushValue(chr(WORMBODY), WORMBATT, xdel, ydel);
                  end
                  else if state = Apple2 then
                  begin
                     if delaytime > 25 then delaytime := delaytime - 10;
                     screen[ydel, xdel].character := chr(BLANKCHR);
                     screen[ydel, xdel].attribute := BLANKATT;
                     PutObstacles;
                  end;

                  PutApple;
                  inc(score);
                  DrawScore;
                  sound(400);
                  delay(100);
                  nosound;
                  state := Running;
             end
             else
             begin
                  screen[ydel, xdel].character := chr(BLANKCHR);
                  screen[ydel, xdel].attribute := BLANKATT;
             end;

        end;

        (* The actual game *)
        procedure GameLoop;
        var input : char;
        begin
             state := Running;
             DrawWorm;
             PutApple;
             score := 0;
             DrawScore;
             while state = Running do
             begin
                  DrawWorm;
                  delay(delaytime);
                  MoveWorm;

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
                                 sound(300);
                                 delay(10);
                                 nosound;
                            end
                            else if input = KEYRIGHT then
                            begin
                                 xdir := 1;
                                 ydir := 0;
                                 sound(300);
                                 delay(10);
                                 nosound;
                            end
                            else if input = KEYDOWN then
                            begin
                                 xdir := 0;
                                 ydir := 1;
                                 sound(300);
                                 delay(10);
                                 nosound;
                            end
                            else if input = KEYUP then
                            begin
                                 xdir := 0;
                                 ydir := -1;
                                 sound(300);
                                 delay(10);
                                 nosound;
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

             if state = Lost then
             begin
                  CrashWorm;
             end;
        end;

        (* Initializes the game *)
        procedure InitGame;
        begin
             AddValue(chr(WORMBODY), WORMBATT, 33, 10);
             AddValue(chr(WORMBODY), WORMBATT, 32, 10);
             AddValue(chr(WORMBODY), WORMBATT, 31, 10);
             AddValue(chr(WORMBODY), WORMBATT, 30, 10);
             AddValue(chr(WORMBODY), WORMBATT, 29, 10);
             AddValue(chr(WORMHEAD), WORMHATT, 28, 10);

             DrawGameScene;
             state := Initial;

             xdir := -1;
             ydir := 0;

             delaytime := 200;
        end;

        (* Shows the welcom screen *)
        procedure ShowWelcomeScreen;
        var input : char;
        begin
             Clrscr;
             Textcolor(Green);
             PrintTextLarge('SUPER', 1, 3);
             PrintTextLarge('WORM', 5, 12);
             Textcolor(LightRed);
             gotoxy(10, 20);
             writeln('(c) Noltisoft 2018');
             gotoxy(13, 22);
             Textcolor(Yellow);
             writeln('Highscore: ', highscore);
             input := readkey;
             if input = KEYESC then
             begin
                  state := Exit;
             end;
        end;

        (* Main routine *)
        begin
             top := NIL;
             AdjustScreenMode;
             ToggleCursor;

             ShowWelcomeScreen;
             while state <> Exit do
             begin
                  InitGame;
                  GameLoop;
                  if score > highscore then
                  begin
                       highscore := score;
                  end;
                  ShowWelcomeScreen;
             end;
             ResetScreenMode;
        end.
end.