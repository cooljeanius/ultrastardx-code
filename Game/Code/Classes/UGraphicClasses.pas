unit UGraphicClasses;

interface

type
 TParticle = Class
   X, Y     : Real;     //Position
   Frame    : Byte;     //act. Frame
   Tex      : Cardinal; //Tex num from Textur Manager
   Live     : Byte;     //How many Cycles before Kill
   RecIndex : Integer;  //To which rectangle this particle belongs
   StarType : Integer;  // 1: GoldenNote | 2: PerfectNote

   Constructor Create(cX,cY: Real; cTex: Cardinal; cLive: Byte; cFrame : integer; cRecArrayIndex : Integer; cStarType : Integer);
   procedure Draw;
 end;

 RectanglePositions   = Record
   xTop, yTop, xBottom, yBottom : Real;
   TotalStarCount   : Integer;
   CurrentStarCount : Integer;
 end;

 PerfectNotePositions = Record
   xPos, yPos : Real;
 end;

 TEffectManager = Class
   Particle      : array of TParticle;
   LastTime      : Cardinal;
   RecArray      : Array of RectanglePositions;
   TwinkleArray  : Array[0..5] of PerfectNotePositions; // store position of last twinkle for every player
   PerfNoteArray : Array of PerfectNotePositions;
   KillallTime   : Cardinal; // Timestamp set when Killall is called

   constructor Create;
   procedure Draw;
   function  Spawn(X, Y: Real; Tex: Cardinal; Live: Byte; StartFrame : Integer;  RecArrayIndex : Integer; StarType : Integer): Cardinal;
   procedure SpawnRec();
   procedure Kill(index: Cardinal);
   procedure KillAll();
   procedure SaveGoldenStarsRec(Xtop, Ytop, Xbottom, Ybottom: Real);
   procedure SavePerfectNotePos(Xtop, Ytop: Real);
   procedure GoldenNoteTwinkle(Top,Bottom,Right: Real; Player: Integer);
 end;

var GoldenRec : TEffectManager;

implementation
uses sysutils, Windows,OpenGl12, UThemes, USkins, UGraphic, UDrawTexture, UTexture, math, dialogs;

const
  KillallDelay: Integer = 100;


//TParticle
Constructor TParticle.Create(cX,cY: Real; cTex: Cardinal; cLive: Byte; cFrame : integer; cRecArrayIndex : Integer; cStarType : Integer);
begin
  X := cX;
  Y := cY;
  Tex := cTex;
  Live := cLive;
  Frame:= cFrame;
  RecIndex := cRecArrayIndex;
  StarType := cStarType;
end;


procedure TParticle.Draw;
var
  W, H:   real;
  Alpha : real;
begin
    //Fade Eyecandy

  Case StarType of
      1:
        begin
          Alpha := (-cos((Frame+1)*2*pi/16)+1);
          W := 20;
          H := 20;
          glColor4f(0.99, 1, 0.6, Alpha);
        end;
      2:
        begin
          Alpha := (-cos((Frame+1)*2*pi/16)+1);
          W := 30;
          H := 30;
          glColor4f(1, 1, 0.95, Alpha);
        end;
      3:
        begin
          Alpha := (Live/3);
          W := 15;
          H := 15;
          glColor4f(1, 1, 0.9, Alpha);
        end;
  end;

  glBindTexture(GL_TEXTURE_2D, Tex);
  glEnable(GL_TEXTURE_2D);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
  glEnable(GL_BLEND);

  begin
    glBegin(GL_QUADS);
    glTexCoord2f((1/16) * Frame, 0);          glVertex2f(X-W, Y-H);
    glTexCoord2f((1/16) * Frame + (1/16), 0); glVertex2f(X-W, Y+H);
    glTexCoord2f((1/16) * Frame + (1/16), 1); glVertex2f(X+W, Y+H);
    glTexCoord2f((1/16) * Frame, 1);          glVertex2f(X+W, Y-H);
    glEnd;
  end;
  glcolor4f(1,1,1,1);
end;



constructor TEffectManager.Create;
var c: Cardinal;
begin
  LastTime := GetTickCount;
  KillallTime := LastTime;
  for c:=0 to 5 do
  begin
    TwinkleArray[c].xPos := 0;
    TwinkleArray[c].yPos := 0;
  end;
end;


procedure TEffectManager.Draw;
var
  I: Integer;
  CurrentTime: Cardinal;
const
  DelayBetweenFrames : Integer = 100;
begin

  CurrentTime := GetTickCount;
  //Manage particle life
  if (CurrentTime > (LastTime + DelayBetweenFrames)) then
    begin
      LastTime := CurrentTime;
        for I := 0 to high(Particle) do
          begin
            Particle[I].Frame := (Particle[I].Frame + 1 ) mod 16;
              //Live = 0 => Live forever
              if (Particle[I].Live > 0) then
                begin
                  Dec(Particle[I].Live);
                end;
          end;
    end;

  I := 0;
  //Kill dead particles
  while (I <= High(Particle)) do
    begin
      if (Particle[I].Live <= 0) then
        begin
          kill(I);
        end
      else
        begin
          inc(I);
        end;
    end;

 //Draw
 for I := 0 to high(Particle) do
   begin
     Particle[I].Draw;
   end;
end;


function TEffectManager.Spawn(X, Y: Real; Tex: Cardinal; Live: Byte; StartFrame : Integer; RecArrayIndex : Integer; StarType : Integer): Cardinal;
begin
  Result := Length(Particle);
  SetLength(Particle, (Result + 1));
  Particle[Result] := TParticle.Create(X, Y, Tex, Live, StartFrame, RecArrayIndex, StarType);
end;


procedure TEffectManager.SpawnRec();
Var
  Xkatze, Ykatze    : Real;
  RandomFrame : Integer;
  P : Integer; // P as seen on TV as Positionman
begin
//Spawn a random amount of stars within the given coordinates
//RandomRange(0,14) <- this one starts at a random  frame, 16 is our last frame - would be senseless to start a particle with 16, cause it would be dead at the next frame
for P:= 0 to high(RecArray) do
  begin
    while (RecArray[P].TotalStarCount > RecArray[P].CurrentStarCount) do
      begin
        Xkatze := RandomRange(Ceil(RecArray[P].xTop), Ceil(RecArray[P].xBottom));
        Ykatze := RandomRange(Ceil(RecArray[P].yTop), Ceil(RecArray[P].yBottom));
        RandomFrame := RandomRange(0,14);
        Spawn(Xkatze, Ykatze, Tex_Note_Star.TexNum, 16 - RandomFrame, RandomFrame, P, 1);
        inc(RecArray[P].CurrentStarCount);
      end;
    end;
  draw;
end;


procedure TEffectManager.Kill(Index: Cardinal);
var
  LastParticleIndex : Cardinal;
begin
// We put the last element of the array on the place where our element_to_delete resides and then we shorten the array - cool, hu? :P

LastParticleIndex := high(Particle);
if not(LastParticleIndex = -1) then
  begin
  Try
    Finally
      if not(Particle[Index].RecIndex = -1) then
        dec(RecArray[Particle[Index].RecIndex].CurrentStarCount);
      Particle[Index].Destroy;
      Particle[Index] := Particle[LastParticleIndex];
      SetLength(Particle, LastParticleIndex);
    end;
    end;
end;

procedure TEffectManager.KillAll();
var c: Cardinal;
begin
//It's the kill all kennies rotuine
  while Length(Particle) > 0 do
    Kill(0);
  SetLength(RecArray,0);
  SetLength(PerfNoteArray,0);
  for c:=0 to 5 do
  begin
    TwinkleArray[c].xPos:=0;
    TwinkleArray[c].yPos:=0;
  end;
end;

procedure TeffectManager.GoldenNoteTwinkle(Top,Bottom,Right: Real; Player: Integer);
//Twinkle stars while golden note hit
// this is called from UDraw.pas, SingDrawPlayerCzesc
var
  C, P, XKatze, YKatze: Integer;
  CurrentTime: Cardinal;
begin
  CurrentTime := GetTickCount;
  //delay after Killall
  if (CurrentTime > (KillallTime + KillallDelay)) then
    // make sure we spawn only one time at one position
    if (TwinkleArray[Player].xPos < Right) then
      For P := 0 to high(RecArray) do  // Are we inside a GoldenNoteRectangle?
      begin
        if ((RecArray[P].xBottom >= Right) and
            (RecArray[P].xTop <= Right) and
            (RecArray[P].yTop <= (Top+Bottom)/2) and
            (RecArray[P].yBottom >= (Top+Bottom)/2)) then
        begin
          TwinkleArray[Player].xPos:=Right;
          
          for C := 1 to 8 do
          begin
            Ykatze := RandomRange(ceil(Top) , ceil(Bottom));
            XKatze := RandomRange(-7,3);
            Spawn(Ceil(Right)+XKatze, YKatze, Tex_Note_Star.TexNum, 3, 0, -1, 3);
          end;
          exit; // found a GoldenRec, did spawning stuff... done
        end;
      end;
end;

procedure TEffectManager.SaveGoldenStarsRec(Xtop, Ytop, Xbottom, Ybottom: Real);
var
  P : Integer;   // P like used in Positions
  NewIndex : Integer;
  CurrentTime: Cardinal;
begin
  CurrentTime := GetTickCount;
  //delay after Killall
  if (CurrentTime > (KillallTime + KillallDelay)) then
  begin
    For P := 0 to high(RecArray) do  // Do we already have that "new" position?
      begin
        if ((ceil(RecArray[P].xTop) = ceil(Xtop)) and (ceil(RecArray[P].yTop) = ceil(Ytop))) then
          exit; // it's already in the array, so we don't have to create a new one
      end;

  // we got a new position, add the new positions to our array
      NewIndex := Length(RecArray);
      SetLength(RecArray, NewIndex + 1);
      RecArray[NewIndex].xTop    := Xtop;
      RecArray[NewIndex].yTop    := Ytop;
      RecArray[NewIndex].xBottom := Xbottom;
      RecArray[NewIndex].yBottom := Ybottom;
      RecArray[NewIndex].TotalStarCount := ceil(Xbottom - Xtop) div 12 + 3;
      RecArray[NewIndex].CurrentStarCount := 0;
  end;
end;

procedure TEffectManager.SavePerfectNotePos(Xtop, Ytop: Real);
var
  P : Integer;   // P like used in Positions
  NewIndex : Integer;

  RandomFrame : Integer;
  Xkatze, Ykatze : Integer;
  CurrentTime: Cardinal;
begin
  CurrentTime := GetTickCount;
  //delay after Killall
  if (CurrentTime > (KillallTime + KillallDelay)) then
  begin
    For P := 0 to high(PerfNoteArray) do  // Do we already have that "new" position?
      begin
        if ((ceil(PerfNoteArray[P].xPos) = ceil(Xtop)) and (ceil(PerfNoteArray[P].yPos) = ceil(Ytop))) then
          exit; // it's already in the array, so we don't have to create a new one
      end;

  // we got a new position, add the new positions to our array
      NewIndex := Length(PerfNoteArray);
      SetLength(PerfNoteArray, NewIndex + 1);
      PerfNoteArray[NewIndex].xPos    := Xtop;
      PerfNoteArray[NewIndex].yPos    := Ytop;

      for P:= 0 to 2 do
        begin
          Xkatze := RandomRange(ceil(Xtop) - 5 , ceil(Xtop) + 10);
          Ykatze := RandomRange(ceil(Ytop) - 5 , ceil(Ytop) + 10);
          RandomFrame := RandomRange(0,14);
          Spawn(Xkatze, Ykatze, Tex_Note_Perfect_Star.TexNum, 16 - RandomFrame, RandomFrame, -1, 2);
      end;
  end;
end;
end.

