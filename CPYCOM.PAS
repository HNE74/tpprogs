program SimpleTerminal;
uses Crt;
const
     THR = 0;
     RBR = 0;
     LCR = 3;
     LSR = 5;
     Latch_Low = $00;
     Latch_High = $01;
     NullLetter = #0;
     EscapeKey = #27;
var
     ComPort: array [1..4] of Word absolute $0040:$0000;
     OutputLetter: Char;
     KeyLetter : Char;
     InputFile : File;
     WasRead : Integer;

procedure InitCom;
begin
     Port[ComPort[1] + LCR] := $80;
     Port[ComPort[1] + Latch_High] := $00;
     Port[ComPort[1] + Latch_Low] := $0C;
     Port[ComPort[1] + LCR] := $03;
end;

procedure OpenInput(Filepath : String);
begin
     Assign(InputFile, Filepath);
     Reset(InputFile, 1);
end;

procedure SendFile;
var cnt : Integer;
var total : Integer;
begin
     write('Transmitting file data');
     cnt := 0;
     total := 0;
     repeat
           BlockRead(InputFile, OutputLetter, 1, WasRead);
           delay(1000);
           Port[ComPort[1] + THR] := Ord(OutputLetter);
           if KeyPressed then begin;
              KeyLetter := ReadKey;
           end;
           inc(cnt);
           inc(total);
           writeln(total);
           if cnt = 100 then begin;
              cnt := 0;
              write('.');
           end;
     until (WasRead = 0) or (KeyLetter = EscapeKey);
     Close(InputFile);
     writeln;
     write(total);
     writeln(' characters sent.');
end;

begin
     writeln('Serial Port File Sender. Press "ESC" to quit.');
     InitCom;
     OpenInput('bintest.exe');
     SendFile;
     writeln;
     writeln('End of transmission.');
     Readln;
end.