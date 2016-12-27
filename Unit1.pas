unit Unit1;
{$OPTIMIZATION off}
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, Spin, Math;

type
  TForm1 = class(TForm)
    _unpackcc4: TButton;
    _LOG: TMemo;
    _SymImg: TImage;
    _allFontImg: TImage;
    _cp1251index: TScrollBar;
    FontZoom1: TScrollBar;
    _FontWidth: TSpinEdit;
    _FontStart: TSpinEdit;
    lbl1: TLabel;
    lbl2: TLabel;
    _SaveBtn: TButton;
    Label1: TLabel;
    _RowLength: TSpinEdit;
    _ClearSymbol: TButton;
    _toRusBtn: TButton;
    Button1: TButton;
    _Dlg1: TMemo;
    ScrollBar1: TScrollBar;
    btn1: TButton;
    _1: TMemo;
    Button2: TButton;
    lbl3: TLabel;
    _animwnd: TImage;
    _zoomanim: TScrollBar;
    btnLoadAnim: TButton;
    lbl4: TLabel;
    _framenum: TScrollBar;
    lbl5: TLabel;
    _museumCheckbox: TCheckBox;
    procedure _unpackcc4Click(Sender: TObject);
//    procedure ScrollBar1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormActivate(Sender: TObject);
    procedure _cp1251indexChange(Sender: TObject);
    procedure FontZoom1Change(Sender: TObject);
    procedure _SymImgMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure _SaveBtnClick(Sender: TObject);
    procedure _ClearSymbolClick(Sender: TObject);
    procedure _toRusBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btn1Click(Sender: TObject);
    procedure ScrollBar1Change(Sender: TObject);
    procedure _Dlg1ContextPopup(Sender: TObject; MousePos: TPoint;
      var Handled: Boolean);
    procedure Button2Click(Sender: TObject);
    procedure _zoomanimChange(Sender: TObject);
    procedure btnLoadAnimClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;
  buf : PByteArray;
  GFontH, GFontW : LongWord;
  FontImage : array of array of LongWord;
  FontWidth : array [0..255] of LongWord;  // ������� �����
  FontStart : array [0..255] of LongWord; // ������� �������� ������
  RUS_STR   : array [0..23470] of AnsiString;
  HeaderStart, GBufSize, strIndex : LongWord;
  ENGstr, RUSstr : array [0..23470] of string;

  animBuf : PByteArray;

implementation                            

{$R *.dfm}

function getDWORD(offset: LongWord; buf: PByteArray): LongInt;
begin
  Result := buf[offset + 0] + 256 * buf[offset + 1] + 256 * 256 * buf[offset + 2] + 256 * 256 * 256 * buf[offset + 3];
end;

function getWORD(offset: LongWord; buf: PByteArray): LongInt;
begin
  Result := buf[offset + 0] + 256 * buf[offset + 1];
end;

procedure writeWORD (num, offset : LongWord; var buf:PByteArray);
var
  HIBYTE, LOBYTE : longword;
begin
 HIBYTE := trunc(num / 256);
 LOBYTE := num - 256 * HIBYTE;

 buf[offset + 1] := HIBYTE; // ������� ���� WORD
 buf[offset + 0] := LOBYTE; // ������� ���� WORD
end;

// ������ � ���������� ������ E.CC4
procedure loadecc4();
begin

end;

Procedure refreshText;
var
  i, j : Integer;
     w : integer;
    str1:string;
begin
// Form1._Dlg1.Lines.Clear;
 Form1._1.Lines.Clear;

 //Form1._Dlg1.Lines.Add(rus_str[form1.ScrollBar1.position]);

 for i := 0 to (Form1._Dlg1.Lines.Count - 1) do
  begin
   str1 := form1._Dlg1.Lines[i];
   // ���������� ������ ������ ������
   w:=0; // ��������� ������ ������ = 0

   for j := 0 to (Length(str1)) do
    begin
     if str1[j]='*' then Continue;
     w := w + fontwidth[ord(str1[j])] + 1;
    end;

   Form1._1.Lines.Add(IntToStr(Length(form1._Dlg1.Lines[i])) + ' ����, ' + IntToStr(w) + ' ����' );

  end;
end;

// ������� �������� ��������� ��� ����� � �������,
// ��� ������ ������ ���������� �� *, ����� ���� ��������
// � _LOG ����� ��� �� ��� ������ ��������

procedure checkTXT (fname:string);
var
  f : TextFile;
  i : Integer;
  UTF8str1 : UTF8String;
  AnsiStr1 : AnsiString;
  err : Boolean; // =0 ��� ������, =1 ���� ������
begin
 err := False;
 AssignFile (f, fname);
 Reset (f);

  // 2348 �����
 for i := 0 to 2347 do
  begin
   Readln (f, UTF8str1);                               // ������ ������

   while (UTF8str1='') do                              // ���� ��� ������ ������, ��
    Readln (f, UTF8str1);                              // ����������

   Ansistr1 := Utf8ToAnsi(UTF8str1);                   // ��������� �� utf8 � ansi cp1251

   while (Ansistr1[1]='?') do
    Delete (Ansistr1, 1, 1); // ������ ��������� �������

   AnsiStr1 := StringReplace(AnsiStr1, '\', #13#10, [rfReplaceAll]);  // ������ ��� �������� \ � ��� �� ������� ������ 13 10
   RUS_STR[i] := AnsiStr1;                             // ���������� � ������ ������������ ����

   if AnsiStr1[1]<>'*' then                           // ���� ����� ���������� �� �� ���������
    begin
     Form1._LOG.Lines.Add('');                       // ������ ������ � ���
     Form1._LOG.Lines.Add(AnsiStr1);                 // ����������� ����� ������ � ���
     err := True;                                    // ��� ������, ���� �������� ��� ������ ����� ������
    end;
  end;

 CloseFile (f);

 if err=False then Form1._LOG.Lines.Add('�������� ��������� ��� ������');
 if err=true then Form1._LOG.Lines.Add('�������� ��������� � ��������');

 refreshText;
 Form1._Dlg1.Lines.Add(rus_str[form1.ScrollBar1.position]);
end;


// ����� 4 �����, DWORD � ����-�����, ������ ������ LE
// offset - ���� �����, ������ �� ����
// num - �����, ������� �����
// buf - ���� �����
procedure WriteDWORD (num: LongWord; offset: LongWord; var buf: PByteArray);
var
  byte0, byte1, byte2, byte3: Byte;
begin
 BYTE3 := Trunc(num / (256 * 256 * 256));
 BYTE2 := Trunc((num - BYTE3 * 256 * 256 * 256) / (256 * 256));
 BYTE1 := Trunc((num - BYTE2 * 256 * 256 - BYTE3 * 256 * 256 * 256) / (256));
 BYTE0 := num - BYTE1 * 256 - BYTE2 * 256 * 256 - BYTE3 * 256 * 256 * 256;

 buf[offset + 0] := byte0;
 buf[offset + 1] := byte1;
 buf[offset + 2] := byte2;
 buf[offset + 3] := byte3;
end;

procedure TForm1._unpackcc4Click(Sender: TObject);
var
  buf : PByteArray;
  f:file of Byte;
  off1, off2 : LongWord;
  num : LongInt;
  i, j, num2, i2, j2 : LongWord;
  numBlocks : LongWord; // ���������� ������ � ��������
  lenBlock : LongWord; // ����� �����
  tableSize : LongWord; //������ ������
  Fsize, newSize, delta, blockSize : LongWord;
  str1 : string;
  blockAoffsets : array [0..10] of LongWord;
  blockBoffsets, blockBsize : array [0..100000] of LongWord;
  txt, txt2 : TextFile;
  UTF8str1 : UTF8String;
  AnsiStr1 : AnsiString;
  museum : Integer;
  var1, var2, var3 : Integer;
begin
 museum := 0; // �� ��������� �� �����
 if _museumCheckbox.Checked then museum := 1;

 FileMode := fmShareDenyNone; // ����� ������� ��������� ������

 AssignFile(f, '.\in\E.CC4');      // ���� ���� e.cc4
 if museum = 1 then AssignFile(f, '.\in\_E.CC4');      // ����� _e.cc4

 Reset(f);
 Fsize := FileSize(f);
 GetMem(Buf, Fsize); // �������� ������ �������
 Blockread(f, Buf[0], Fsize); // ������ ���� ���� ����
 CloseFile (f);

 var1 := Trunc(getDWORD(0, buf)/4)-1;//10;
 //if museum = 1 then var1 := 3;

 for i :=0 to var1 do      // � ���� 11 ������ �������� 0 �� 10, // ��� ����� �� 4, 0 �� 3
  blockAoffsets[i] := getDWORD(i*4, buf);

 tableSize := (var1+1) * 4;  // 11*4 ��� e.cc4, 4*4 ��� _e.cc4
// if museum = 1 then tableSize := 4 * 4;

 assignfile (txt, '.\out\e.cc4.txt');
 if museum = 1 then assignfile (txt, '.\out\_e.cc4.txt');
 Rewrite(txt);

// var2 := 10;
// if museum = 1 then var2 := 3;
 var2:=var1;

 strIndex := 0;
 For i :=0 to var2 do       // 0 �� 10 ��� e.cc4, 0 �� 3 ��� _e.cc4
  begin
   off1 := blockAoffsets[i];
   if i <> var2 then lenBlock := blockAoffsets[i + 1] - blockAoffsets[i];     // <>10
   if i = var2 then lenBlock := Fsize - blockAoffsets[i];                   // =10

   NumBlocks := Trunc(getDword(off1, buf) / 4); // ��������� �������� = ������� �����
   if ((i=4) and (numBlocks=523)) then numBlocks:=490;  // ��� � �������� �����, ������� =523 � �� ����� 490

//   SetLength (blockBoffsets, numBlocks);
//   SetLength (blockBsize, numBlocks);

   for j := 0 to (numBlocks - 1) do
    blockBoffsets[j] := getDWORD(off1 + j*4, buf);

   Inc (tableSize, blockBoffsets[0]);

   for j := 0 to (numBlocks - 2) do
    blockBsize[j] := blockBoffsets[j + 1] - blockBoffsets[j];

   blockBsize[numBlocks-1] := lenBlock - blockBoffsets[numBlocks-1];

   // ���������� ����
   for i2:=0 to (numBlocks - 1) do
   begin
    str1 := '';
    for j2 :=0 to (blockBSize[i2] - 1) do
     begin
      delta := blockBoffsets[i2] - blockBoffsets[0];
      num2 := (($54 * (delta + j2 + 1)) and $FF);
      num := buf[off1 + blockBoffsets[i2] + j2] - num2;
      while (num < 0) do inc (num, 256);

      if ( (num = 0) and (j2 <> (blockBSize[i2]-1))) then num:=$5C; // ������� "\"
      buf[off1 + blockBoffsets[i2] + j2] := num;
      str1 := str1 + chr(num);
     end;
     writeln (txt, str1);
     ENGstr[strIndex] := str1;
     Inc (strIndex);
     //_LOG.Lines.Add(str1);
   end;
  end;

 // ������ ��������� �������
 strIndex := 0;
 AssignFile (txt2, '.\in\E.CC4.txt');
 if museum = 1 then AssignFile (txt2, '.\in\Museum_E.CC4.txt');
 Reset(txt2);

 var3 := 2347;
 if museum = 1 then var3 := 60;

 // 2348 �����
 for i := 0 to var3 do      //2347    //60
  begin
   Readln (Txt2, UTF8str1);
   while (UTF8str1='') do
    Readln (Txt2, UTF8str1);

   Ansistr1 := Utf8ToAnsi(UTF8str1);
   // Trim ������ � ������ � ����� ������� � �����������
   if Ansistr1[1]='?' then Delete (Ansistr1, 1, 1);
   if (ENGstr[strIndex]='*') then
      AnsiStr1 := '*'
        else
      Ansistr1 := Ansistr1 + #0;

   RUSstr[strIndex] := AnsiStr1;
   Inc (strIndex);
  end;

 CloseFile (txt);
 CloseFile (txt2);

 AssignFile(f, '.\out\E.CC4');
 if museum = 1 then AssignFile(f, '.\out\_E.CC4');

 Rewrite(f);
 Blockwrite(f, Buf[0], Fsize);
 CloseFile (f);
 FreeMem (buf);

 // ������� ������� E.CC4
 // ������� ����� ������ e.cc4
 // ����� �����
 newSize := 0;
 for i := 0 to var3 do//2347   //60
  Inc (newSize, Length(RUSstr[i]));
 // ���� �������

 Inc (newSize, tableSize);
 GetMem (buf, newSize);

 //====================================================
 FreeMem (buf);
 _LOG.Lines.Add('done');
end;

procedure refreshABC;
var
  i, j:LongWord;
begin
 form1._allFontImg.Picture := nil;
 form1._allFontImg.Height := GFontH;
 form1._allFontImg.Width := GFontW*8;

 for i:=0 to (GFontH - 1) do
  for j:=0 to (GFontW*8 - 1) do
   form1._allFontImg.Canvas.Pixels[j, i] := FontImage[i, j];
end;

procedure RefreshSym;
begin
 Form1._SymImg.Height := form1.FontZoom1.Position * GFontH;
 form1._SymImg.Width := form1.FontZoom1.Position * FontWidth[Form1._cp1251index.Position];

 Form1._LOG.Lines.Add('���=' + IntToStr(form1._cp1251index.Position));
 form1._LOG.Lines.Add('������=' + chr(form1._cp1251index.Position));
end;

procedure RefreshSymbol;
var
 i, j : LongWord;
begin
 form1._SymImg.Picture := nil;
 form1._SymImg.Height := GFontH;
 Form1._SymImg.Width := FontWidth[form1._cp1251index.Position];

 for i := 0 to (GFontH - 1) do
  for j := 0 to (FontWidth[form1._cp1251index.Position] - 1) do
    Form1._SymImg.Canvas.Pixels[j, i] := FontImage[i, j + fontStart[form1._cp1251index.Position]];

 RefreshSym;

 form1._FontWidth.Value := FontWidth[form1._cp1251index.Position];
 form1._FontStart.Value := FontStart[form1._cp1251index.Position];
end;

procedure parseBuf (buf : PByteArray);
var
 i, j, k : LongWord;
 curByte, curByte2 : LongWord;
begin
 // ��������� ���������� � �������� �� buf
 // ������ ������ � ���� � ����� ���� � ������
 GFontH := getWORD($2, buf);
 GFontW := getWORD($4, buf);

 Form1._RowLength.Value := GFontW;

 // ������ 8 ���� ��������� + ���� ������
 HeaderStart := $8 + GFontH * GFontW;

 // ������������� �������� ����� ������
 SetLength(FontImage, GFontH, GFontW*8);

 Form1._allFontImg.Height := GFontH;
 form1._allFontImg.Width := GFontW*8;

 // ������ �������� ����� ������
 for i:=0 to (GFontH - 1) do
  for j:=0 to (GFontW - 1) do
   begin
    // ������������� ���� � ������� ���
    curByte := buf[$8 + i*GFontW + j];

    for k:=7 downto 0 do
     begin
     // 48 = 30h = 0
     // 49 = 31h = 1
      if char($30 + (curByte and 1)) = '1' then
       FontImage[i, j * 8 + k] := 255 * 255
        else
       FontImage[i, j * 8 + k] := 0;

      curByte := curByte shr 1;
     end;
   end;

 RefreshABC;

 // ��������� ������� ����� � �������� �� ������ ������� �������
 for i := 0 to 223 do
  begin
   // ����� ���� � �������
   curByte := buf[HeaderStart + i*2];
   // �������� ������� ������
   curByte := curByte shr 4;
   FontWidth[32 + i] := curByte;
  end;

  // ������ �
  //FontWidth[255] := 5;

 for i := 0 to 223 do
  begin
  // ����� ���� � �������
  curByte := buf[HeaderStart + i*2];
  // �������� ������� 4 ���� ������
  curByte := (curByte and $0F) * 256;
  curByte2 := buf[HeaderStart + i*2 + 1];
  curByte2 := (curByte2 shr 4)*16 + (curByte2 and $0F);

  FontStart[32 + i] := curByte + curByte2;
  end;

  RefreshSymbol;
 // Form1._LOG.Lines.Add('1');
end;

procedure TForm1.FontZoom1Change(Sender: TObject);
begin
 RefreshSym;
end;

procedure initBuf();
var
  f : file of Byte;
  i : LongWord;
begin
 // ������ ���� � buf
 FileMode := fmShareDenyNone; // ����� ������� ��������� ������
 AssignFile(f, '.\in\res\ctu.pfn');
 Reset(f);
 GBufSize := FileSize(f);
 GetMem(Buf, GBufSize*2); // �������� ������ ������
 // ������
 for i := 0 to (GBufSize - 1) do
  buf[i] := 0;

 Blockread(f, Buf[0], GBufSize); // ������ ���� ���� ����
 CloseFile (f);

 parseBuf (buf);
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 FreeMem (buf);
end;

procedure TForm1.FormActivate(Sender: TObject);
begin
lbl3.Caption := IntToStr(ScrollBar1.Position);
initBuf();
//LoadECC4();
Button1Click(Sender);
refreshText;
end;

procedure TForm1._cp1251indexChange(Sender: TObject);
begin
form1._LOG.Lines.Clear;
RefreshSymbol;
end;


procedure TForm1._SymImgMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 kx, ky, d, xpos, ypos, color, fontnum, datastart, Byte1: Integer;
 f: file of Byte;
 Fsize: LongWord;
begin
 fontnum := form1._cp1251index.Position;

 kx := trunc(form1._SymImg.Width / FontWidth[fontnum]);
 ky := trunc(Form1._SymImg.Height / GFontH);

 xpos := Trunc(X / kx);
 ypos := Trunc(Y / ky);

 if (Button = mbLeft) then
   color := 255 * 255; // ��������

 if (Button = mbRight) then
  color := 0; // ������

 // ������/������� �����
 form1._SymImg.Canvas.Pixels[xpos, ypos] := color;

 // ����� � FontImage � ������ refreshABC
 FontImage[ypos, xpos + FontStart[fontnum]] := color;
 refreshABC;

end;

procedure TForm1._SaveBtnClick(Sender: TObject);
var
 fontnum, WidthStart, i, j, k : LongWord;
 f : file of Byte;
 byte1 : Byte;
begin
// ��������� ������ � ������ ���� � ������
 writeWORD (GFontH, $2, buf);

 HeaderStart := HeaderStart + (_RowLength.Value - GFontW)*GFontH;
 writeWORD ( ((HeaderStart and $FF) shl 8) + ((HeaderStart and $FF00) shr 8), $6, buf);

 GBufSize := GBufSize + (_RowLength.Value - GFontW)*GFontH;

 GFontW := _RowLength.Value;
 writeWORD (GFontW, $4, buf);
 SetLength (FontImage, GFontH, GFontW*8);

 fontnum := Form1._cp1251index.Position;
 FontWidth[fontnum] := Form1._FontWidth.Value;
 FontStart[fontnum] := form1._FontStart.Value;

 // ����������� FontImage � data buf
 for i := 0 to (GFontH - 1) do
  for j := 0 to (GFontW - 1) do
   begin
    Byte1 := 0;

    for k := 7 downto 0 do
     if FontImage[i, j*8 + (7-k)]=255*255 then byte1 := byte1 + Trunc(Power(2, k));

    buf[$8 + i*GFontW + j] := byte1;
   end;

 // ��������� ������� ����� � ��������
 for i := 32 to 255 do
  begin
   WidthStart :=  ((FontStart[i] and $00FF) shl 8) + ((FontStart[i] and $FF00) shr 8) + (FontWidth[i] shl 4);
   writeWORD (WidthStart, HeaderStart + (i-32)*2, buf);
  end;

 // ��������
 FileMode := fmShareDenyNone; // ����� ������� ��������� ������
 AssignFile(f, '.\out\res\ctu.pfn');
 Rewrite (f);
 BlockWrite (f, Buf[0], GBufSize); // ������ ���� ���� ����
 CloseFile (f);

 //parseBuf(buf);
 refreshABC;
 RefreshSym;
 RefreshSymbol;
end;

procedure TForm1._ClearSymbolClick(Sender: TObject);
var
  i, j : LongWord;
begin
 for i := 0 to (GFontH - 1) do
  for j := 0 to (FontWidth[form1._cp1251index.Position] - 1) do
   FontImage[i, j + fontStart[form1._cp1251index.Position]] := 0;

 refreshABC;
 RefreshSymbol;
end;

procedure TForm1._toRusBtnClick(Sender: TObject);
var
 buf, bufRUS : PByteArray;
 fENG, fRUS:file of Byte;
 fSize, rusSize, i, j, k, strIndex, blockBtotal, blockAnum : LongWord;
 i2, curByte2, lastByte2, count1, Size2NewRow : LongWord;

 ENGblockAoffset, RUSblockAoffset : array [0..10] of LongWord;
 ENGblockBoffset, RUSblockBoffset, ENGblockBsize, RUSblockBsize : array of LongWord;

 ENGtext, RUStext : array of AnsiString;

 UTF8str1 : UTF8String;
 AnsiStr1 : AnsiString;
 txtRUS : TextFile;
 tmpTxt : AnsiString;
 curByte : Byte;
 blockBlen : LongWord;
 museum : Integer;
 var1 : Integer;
begin
 museum := 0;
 if _museumCheckbox.Checked then museum := 1;

 // ������ ������������� e.cc4 ���� � �����
 FileMode := fmShareDenyNone; // ����� ������� ��������� ������

 AssignFile(fENG, '.\out\E.CC4');
 if museum = 1 then AssignFile(fENG, '.\out\_E.CC4');

 Reset(fENG);
 fsize := FileSize(fENG);
 GetMem(Buf, fsize); // �������� ������ ������
 GetMem (bufRUS, 3*fsize); // �������� ������ � 3 ���� ������, ������ �� ���� ������ ������ �����
 Blockread(fENG, Buf[0], fsize); // ������ ���� ���� ����
 CloseFile (fENG);

 // ������
 for i := 0 to (3*fsize-1) do
  bufRUS[i] := 0;

 //===========================================
{ // ������ ��������� �������
 strIndex := 0;
 AssignFile (txtRUS, '.\in\E.CC4.txt');
 Reset(txtRUS);
 // 2348 �����
 for i := 0 to 2347 do
  begin
   Readln (txtRUS, UTF8str1);
   while (UTF8str1='') do
    Readln (txtRUS, UTF8str1);

   Ansistr1 := Utf8ToAnsi(UTF8str1);
   if Ansistr1[1]='?' then Delete (Ansistr1, 1, 1);
   if (ENGstr[strIndex]='*') then
      AnsiStr1 := '*'
        else
      Ansistr1 := Ansistr1 + #0;

   RUSstr[strIndex] := AnsiStr1;
   Inc (strIndex);
  end;
 CloseFile (txtRUS);
 //=================================================
}
 var1 := 10;
 if museum = 1 then var1 := 3;

 // ��������� ������ ���������, �������+��������
 for blockAnum :=0 to var1 do // 10 ��� e.cc4, 3 ��� �����
  ENGblockAoffset[blockAnum] := getDWORD(blockAnum*4, buf);

 RUSblockAoffset[0] := ENGblockAoffset[0];
 rusSize := RUSblockAoffset[0];

 AssignFile (txtRUS, '.\in\E.CC4.txt');
 if museum = 1 then AssignFile (txtRUS, '.\in\Museum_E.CC4.txt');
 Reset(txtRUS);

 for blockAnum := 0 to var1 do   // 10 ��� e.cc4, 3 ��� �����
  begin
   // blockBnum - ���������� ������ � �������
   blockBtotal := Trunc ( (getDWORD(ENGblockAoffset[blockAnum], buf)) /4);

   SetLength (ENGblockBoffset, blockBtotal);
   SetLength (RUSblockBoffset, blockBtotal);
   SetLength (ENGblockBsize, blockBtotal);
   SetLength (RUSblockBsize, blockBtotal);

   // ������
   for j := 0 to (blockBtotal-1) do
    begin
     ENGblockBoffset[j] := 0;
     RUSblockBoffset[j] := 0;
     ENGblockBsize[j] := 0;
     RUSblockBsize[j] := 0;
    end;


   for j := 0 to (blockBtotal-1) do
    begin
     ENGblockBoffset[j] := getDWORD(ENGblockAoffset[blockAnum] + j*4, buf);

     if j > 0 then ENGblockBsize[j - 1] := ENGblockBoffset[j] - ENGblockBoffset[j - 1];

     if ( (j = (blockBtotal-1)) and (blockAnum < var1) ) then
          ENGblockBsize[j] := ENGblockAoffset[blockAnum + 1] - ENGblockAoffset[blockAnum] - ENGblockBoffset[j];

     if ( (j = (blockBtotal-1)) and (blockAnum = var1) ) then ENGblockBsize[j] := fsize - ENGblockAoffset[blockAnum] - ENGblockBoffset[j];
    end;

   RUSblockBoffset[0] := ENGblockBoffset[0];

   // ��������� �������� � ������� ��������, ��������� ������� ������ �������������
   SetLength (ENGtext, blockBtotal);
   SetLength (RUStext, blockBtotal);

   for j := 0 to (blockBtotal - 1) do
   begin
    for k := 0 to (ENGblockBsize[j] - 1) do
     begin
      curByte := buf[ENGblockAoffset[blockAnum] + ENGblockBoffset[j] + k];
      if curByte = $5C then curByte := $20; // \ �� ������
      tmpTxt := tmpTxt + chr(curByte);
     end;

    Readln (txtRUS, UTF8str1);
    while (UTF8str1='') do Readln (txtRUS, UTF8str1);
    Ansistr1 := Utf8ToAnsi(UTF8str1);
    if Ansistr1[1]='?' then Delete (Ansistr1, 1, 1);
    AnsiStr1 := StringReplace(ANSIstr1, '\', #0, [rfReplaceAll]); // ����� ��� \ �� ���� - ������� ������

    // ����������� �������� ����� ������ 20-25 ��������
    // �� ���������� �������, ����� ������ ������� #0
    Size2NewRow := 25;
    curByte2 := 25;
//    lastByte2 := 25;
//    count1 := 0;
{
    while (curByte2 < Length(AnsiStr1)) do
     begin
      while ( (AnsiStr1[curByte2] <> ' ') and (curByte2 > 0)) do
       Dec (curByte2);

      if curByte2=0 then
       begin
        Break;
       end;

      AnsiStr1[curByte2] := #0;
      inc (curByte2, Size2NewRow);
     end;
}

    if tmpTxt<>'*' then RUStext[j] := AnsiStr1 + #0
              else RUStext[j] := AnsiStr1;

    RUSblockBsize[j] := Length(RUStext[j]);
    if j>0 then RUSblockBoffset[j] := RUSblockBoffset[j-1] + Length(RUStext[j-1]);

    // _LOG.Lines.Add(tmpTxt);
    ENGtext[j] := tmpTxt;
    tmpTxt := '';
   end;

  // _LOG.lines.Add(' ');
  // ������� ����� ���� � ������� �������
  // ������� ����� ����� B
  blockBlen := 0;
  for j := 0 to (blockBtotal - 1) do
   inc (blockBlen, RUSblockBsize[j]);

  inc (blockBlen, 4 * blockBtotal);
  // blockBlen �������� ������ ������ ����� B

  // ��������� ������ ������� ���������
  //if blockAnum>0 then RUSblockAoffset[blockAnum] := RUSblockAoffset[blockAnum-1] + blockBlen;
  if blockAnum <> var1 then RUSblockAoffset[blockAnum + 1] := RUSblockAoffset[blockAnum] + blockBlen;

  inc (rusSize, blockBlen);

  // ���� �������� ���� A
  WriteDWORD(RUSblockAoffset[blockAnum], blockAnum*4, bufRUS);

  // ���������� ���� B  
  for j := 0 to (blockBtotal - 1) do
    WriteDWORD(RUSblockBoffset[j], RUSblockAoffset[blockAnum] + j*4 , bufRUS);

  for j := 0 to (blockBtotal - 1) do
   for k := 0 to (RUSblockBsize[j] - 1) do
    begin
     tmpTxt := RUStext[j];
     bufRUS[RUSblockAoffset[blockAnum] + RUSblockBoffset[j] + k] := ord(tmpTXT[k + 1]);
    end;

{
   FileMode := fmShareDenyNone; // ����� ������� ��������� ������
   AssignFile(fRUS, '.\out\rus\E.CC4');
   Rewrite (fRUS);
   BlockWrite (fRUS, bufRUS[0], rusSize);
   CloseFile (fRUS);

//   exit;

  if blockAnum>0 then Exit;
}
  end;

 FileMode := fmShareDenyNone; // ����� ������� ��������� ������

 AssignFile(fRUS, '.\out\rus\E.CC4');
 if museum = 1 then AssignFile(fRUS, '.\out\rus\museum_E.CC4');

 Rewrite (fRUS);
 BlockWrite (fRUS, bufRUS[0], rusSize);
 CloseFile (fRUS);

 CloseFile (txtRUS);
 FreeMem (buf);
 FreeMem (bufRUS);
 _LOG.Lines.Add('done');
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
checkTXT('.\in\E.CC4.txt');
end;

procedure TForm1.btn1Click(Sender: TObject);
var
s1 : String;
begin
 Form1._LOG.Lines.Clear;
 s1 := Form1._Dlg1.Text;
end;

procedure TForm1.ScrollBar1Change(Sender: TObject);
var
  i:Integer;
begin
Form1._Dlg1.Lines.Clear;
Form1._Dlg1.Lines.Add(rus_str[form1.ScrollBar1.position]);
refreshText;

lbl3.Caption := IntToStr(ScrollBar1.Position);
end;

procedure TForm1._Dlg1ContextPopup(Sender: TObject; MousePos: TPoint;
  var Handled: Boolean);
begin
//Beep;
end;

procedure TForm1.Button2Click(Sender: TObject);
var
  s1, tmpstr1 : string;
    f: TextFile;
    i:Integer;
begin
 for i := 0 to (Form1._Dlg1.Lines.Count - 1) do
  begin
   tmpstr1 := Trim(form1._Dlg1.Lines[i]);
   s1 := s1 + tmpstr1 + #13#10; //---rus_str[form1.ScrollBar1.position]; // ����� �� ���� �����
  end;

 if s1[1] <> '*' then   // ����� ������ ���������� �� ��������
  begin
   _LOG.Lines.Add('����� ������ ���������� �� *'); // �������, ������ �� �����������
   exit; // ������ �� ���������
  end;

 while ((Ord(s1[Length(s1)]) = 13) or (Ord(s1[Length(s1)]) = 10)) do // ������ ��� 13 10 � ����� ������
   Delete (s1, Length(s1), 1);

 //s1 := StringReplace(S1, #13#10, '\', [rfReplaceAll]);  // ������ ��� 13 10 �� �������� � ������

 rus_str[form1.ScrollBar1.position] := s1; //trim(form1._Dlg1.Text);

 AssignFile (f, '.\in\E.CC4.txt');
 Rewrite (f);

 for i:= 0 to 2347 do
  begin
   s1 := rus_str[i];
   s1 := StringReplace(S1, #13#10, '\', [rfReplaceAll]);  // ������ ��� 13 10 �� ��������

   Writeln (f, AnsiToUTF8(s1));
   Writeln (f, '');
  end;
  
 CloseFile (f);

 refreshText;
end;

procedure TForm1._zoomanimChange(Sender: TObject);
begin
 Form1._animwnd.Height := form1._zoomanim.Position * 1;
 form1._animwnd.Width := form1._zoomanim.Position * 1;
end;

procedure TForm1.btnLoadAnimClick(Sender: TObject);
var
 f : file of Byte;
 fsize, tmp, i, crcsize, num, offA, offB, twozero : LongInt;
 offset_array_A, offset_array_B : array of LongInt;
begin
 FileMode := fmShareDenyNone; // ����� ������� ��������� ������
 AssignFile(f, '.\in\anim\AMERFLAG.VA2');
 Reset(f);
 fsize := FileSize(f);
 GetMem(animBuf, fsize); // �������� ������ ������
 Blockread(f, animBuf[0], fsize); // ������ ���� ���� ����
 CloseFile (f);

 // ������� ������� ����� ������ �������� �
 offA := getDWORD(0, animBuf); // ����� ������ �������� ����� �

 num := trunc(offA / 4) - 1;    // ������� ������� �������� � ����� A
 crcsize := getDWORD(num * 4, animBuf); // ����� ������ ����� �� ����� �

 if crcsize = fsize then _LOG.Lines.Add('crc size ok')    // � ��������� � �������� �����
                    else _LOG.Lines.Add('crc size error');

 SetLength (offset_array_A, num);

 // ������� �������� ����� �
 for i:=0 to num do
  offset_array_A[i] := getDWORD(i*4, animBuf);

 // ������ ������� �������� ������ B, � ����� 00 00
 offA := getDWORD(0, animBuf); // ����� ������ �������� ����� �
 offB := getDWORD(offA, animBuf); // ����� ������ �������� ����� B
 num := trunc(offB / 4) - 1; // ����� ���������� ������, ��� �� 2 ����� ������

 twozero := getWORD(offA + offB - 2, animBuf);
 if twozero = 0 then _LOG.Lines.Add('00 00 ok')    // ��������� ��� ����
                else _LOG.Lines.Add('00 00 error');

end;

end.
