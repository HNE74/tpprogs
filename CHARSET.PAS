program font;

var MptrOff: word;
    MptrSeg: word;
    OurFont: array[1..28] of byte;

begin

  OurFont[1]  := $00;         { 00000000b }
  OurFont[2]  := $7F;         { 01111111b }
  OurFont[3]  := $63;         { 01100011b }
  OurFont[4]  := $63;         { 01100011b }
  OurFont[5]  := $63;         { 01100011b }
  OurFont[6]  := $7F;         { 01111111b }
  OurFont[7]  := $63;         { 01100011b }
  OurFont[8]  := $63;         { 01100011b }
  OurFont[9]  := $63;         { 01100011b }
  OurFont[10] := $63;         { 01100011b }
  OurFont[11] := $63;         { 01100011b }
  OurFont[12] := $63;         { 01100011b }
  OurFont[13] := $00;         { 00000000b }
  OurFont[14] := $FF;         { 00000000b }

  OurFont[15] := $00;         { 00000000b }
  OurFont[16] := $7E;         { 01111110b }
  OurFont[17] := $66;         { 01100110b }
  OurFont[18] := $66;         { 01100110b }
  OurFont[19] := $66;         { 01100110b }
  OurFont[20] := $7F;         { 01111111b }
  OurFont[21] := $63;         { 01100011b }
  OurFont[22] := $63;         { 01100011b }
  OurFont[23] := $63;         { 01100011b }
  OurFont[24] := $63;         { 01100011b }
  OurFont[25] := $63;         { 01100011b }
  OurFont[26] := $7F;         { 01111111b }
  OurFont[27] := $00;         { 00000000b }
  OurFont[28] := $FF;         { 00000000b }

  MptrSeg := seg(OurFont[1]);
  MptrOff := ofs(OurFont[1]);

  asm
    mov  ax,$1100
    mov  dx,$41                   { 65  'A' }
    mov  cx,$02                   { two char's to change }
    mov  bx,$0E00                 { number of bytes in each char }
    mov  bp,MptrOff               {    bl = 0 }
    mov  es,MptrSeg
    int  $10

  end;
  writeln('ABABABABABAB');
  readln;
end.
