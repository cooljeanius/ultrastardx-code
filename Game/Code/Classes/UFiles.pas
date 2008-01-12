unit UFiles;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}
{$I switches.inc}

uses SysUtils,
     ULog,
     UMusic,
     USongs,
     USong;

procedure ResetSingTemp;
function  SaveSong(Song: TSong; Czesc: TCzesci; Name: string; Relative: boolean): boolean;

var
  SongFile: TextFile;   // all procedures in this unit operates on this file
  FileLineNo: integer;  //Line which is readed at Last, for error reporting

  // variables available for all procedures
  Base    : array[0..1] of integer;
  Rel     : array[0..1] of integer;
  Mult    : integer = 1;
  MultBPM : integer = 4;

implementation

uses TextGL,
     UIni,
		 UPlatform,
     UMain;
     
//--------------------
// Resets the temporary Sentence Arrays for each Player and some other Variables
//--------------------
procedure ResetSingTemp;
var
  Pet:  integer;
begin
  SetLength(Czesci, Length(Player));
  for Pet := 0 to High(Player) do begin
    SetLength(Czesci[Pet].Czesc, 1);
    SetLength(Czesci[Pet].Czesc[0].Nuta, 0);
    Czesci[Pet].Czesc[0].Lyric := '';
    Czesci[Pet].Czesc[0].LyricWidth := 0;
    Player[pet].Score := 0;
    Player[pet].IlNut := 0;
    Player[pet].HighNut := -1;
  end;

  //Reset Path and Filename Values to Prevent Errors in Editor
  if assigned( CurrentSong ) then
  begin
    SetLength(CurrentSong.BPM, 0);
    CurrentSong.Path := '';
    CurrentSong.FileName := '';
  end;
  
//  CurrentSong := nil;
end;


//--------------------
// Saves a Song
//--------------------
function SaveSong(Song: TSong; Czesc: TCzesci; Name: string; Relative: boolean): boolean;
var
  C:      integer;
  N:      integer;
  S:      string;
  B:      integer;
  RelativeSubTime:    integer;
  NoteState: String;

begin
//  Relative := true; // override (idea - use shift+S to save with relative)
  AssignFile(SongFile, Name);
  Rewrite(SongFile);

  WriteLn(SongFile, '#TITLE:' + Song.Title + '');
  WriteLn(SongFile, '#ARTIST:' + Song.Artist);

  if Song.Creator     <> '' then    WriteLn(SongFile, '#CREATOR:'     + Song.Creator);
  if Song.Edition     <> 'Unknown' then WriteLn(SongFile, '#EDITION:' + Song.Edition);
  if Song.Genre       <> 'Unknown' then   WriteLn(SongFile, '#GENRE:' + Song.Genre);
  if Song.Language    <> 'Unknown' then    WriteLn(SongFile, '#LANGUAGE:'    + Song.Language);

  WriteLn(SongFile, '#MP3:' + Song.Mp3);

  if Song.Cover       <> '' then    WriteLn(SongFile, '#COVER:'       + Song.Cover);
  if Song.Background  <> '' then    WriteLn(SongFile, '#BACKGROUND:'  + Song.Background);
  if Song.Video       <> '' then    WriteLn(SongFile, '#VIDEO:'       + Song.Video);
  if Song.VideoGAP    <> 0  then    WriteLn(SongFile, '#VIDEOGAP:'    + FloatToStr(Song.VideoGAP));
  if Song.Resolution  <> 4  then    WriteLn(SongFile, '#RESOLUTION:'  + IntToStr(Song.Resolution));
  if Song.NotesGAP    <> 0  then    WriteLn(SongFile, '#NOTESGAP:'    + IntToStr(Song.NotesGAP));
  if Song.Start       <> 0  then    WriteLn(SongFile, '#START:'       + FloatToStr(Song.Start));
  if Song.Finish      <> 0  then    WriteLn(SongFile, '#END:'         + IntToStr(Song.Finish));
  if Relative               then    WriteLn(SongFile, '#RELATIVE:yes');

  WriteLn(SongFile, '#BPM:' + FloatToStr(Song.BPM[0].BPM / 4));
  WriteLn(SongFile, '#GAP:' + FloatToStr(Song.GAP));

  RelativeSubTime := 0;
  for B := 1 to High(CurrentSong.BPM) do
    WriteLn(SongFile, 'B ' + FloatToStr(CurrentSong.BPM[B].StartBeat) + ' ' + FloatToStr(CurrentSong.BPM[B].BPM/4));

  for C := 0 to Czesc.High do begin
    for N := 0 to Czesc.Czesc[C].HighNut do begin
      with Czesc.Czesc[C].Nuta[N] do begin


        //Golden + Freestyle Note Patch
        case Czesc.Czesc[C].Nuta[N].Wartosc of
          0: NoteState := 'F ';
          1: NoteState := ': ';
          2: NoteState := '* ';
        end; // case
        S := NoteState + IntToStr(Start-RelativeSubTime) + ' ' + IntToStr(Dlugosc) + ' ' + IntToStr(Ton) + ' ' + Tekst;


        WriteLn(SongFile, S);
      end; // with
    end; // N

    if C < Czesc.High then begin      // don't write end of last sentence
      if not Relative then
        S := '- ' + IntToStr(Czesc.Czesc[C+1].Start)
      else begin
        S := '- ' + IntToStr(Czesc.Czesc[C+1].Start - RelativeSubTime) +
          ' ' + IntToStr(Czesc.Czesc[C+1].Start - RelativeSubTime);
        RelativeSubTime := Czesc.Czesc[C+1].Start;
      end;
      WriteLn(SongFile, S);
    end;

  end; // C


  WriteLn(SongFile, 'E');
  CloseFile(SongFile);
end;

end.
