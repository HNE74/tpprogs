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
     InputLetter: Char;
     OutputLetter: Char;
     OutputFile : File;
     OutputFilePath : String;
     WasWritten : Integer;
begin
     writeln('Serial terminal. Press "ESC" to quit.');
     Port[ComPort[1] + LCR] := $80;
     Port[ComPort[1] + Latch_High] := $00;
     Port[ComPort[1] + Latch_Low] := $0C;
     Port[ComPort[1] + LCR] := $03;

     OutputFilePath := 'C:\\serial.out';
     Assign(OutputFile, OutputFilePath);
     ReWrite(OutputFile, 1);

     OutputLetter := NullLetter;
     repeat
           if(Port[ComPort[1] + LSR] and $01) > 0 then begin
              InputLetter := Chr(Port[ComPort[1] + RBR]);
              Write(InputLetter);
              Blockwrite(OutputFile, InputLetter, 1, WasWritten);
           end;
           if KeyPressed then begin;
              OutputLetter := ReadKey;
              if OutputLetter <> EscapeKey then begin
                 Port[ComPort[1] + THR] := Ord(OutputLetter);
              end;
           end;
     until OutputLetter = EscapeKey;
     Close(OutputFile);
end.