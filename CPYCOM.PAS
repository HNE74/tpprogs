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
     InputLetter : Char;
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
var response : Boolean;
begin
     write('Transmitting file data');
     cnt := 0;
     total := 0;
     repeat
           BlockRead(InputFile, OutputLetter, 1, WasRead);
           Port[ComPort[1] + THR] := Ord(OutputLetter);

           response := False;
           repeat
               if KeyPressed then begin;
                   KeyLetter := ReadKey;
               end;
               if(Port[ComPort[1] + LSR] and $01) > 0 then begin
                   InputLetter := Chr(Port[ComPort[1] + RBR]);
                   if InputLetter = OutputLetter then begin
                       response := True;
                   end;
               end;
           until (response = True) or (KeyLetter = EscapeKey);

           inc(cnt);
           inc(total);
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
     OpenInput('msk.zip');
     SendFile;
     writeln;
     writeln('End of transmission.');
     Readln;
end.