unit UAudioPlaybackBase;

interface

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

{$I switches.inc}

uses
  UMusic;

type
  TAudioPlaybackBase = class(TInterfacedObject, IAudioPlayback)
    protected
      OutputDeviceList: TAudioOutputDeviceList;
      MusicStream: TAudioPlaybackStream;
      function CreatePlaybackStream(): TAudioPlaybackStream; virtual; abstract;
      procedure ClearOutputDeviceList();
      function GetLatency(): double; virtual; abstract;

      // open sound or music stream (used by Open() and OpenSound())
      function OpenStream(const Filename: string): TAudioPlaybackStream;
      function OpenDecodeStream(const Filename: string): TAudioDecodeStream;
    public
      function GetName: string; virtual; abstract;

      function Open(const Filename: string): boolean; // true if succeed
      procedure Close;

      procedure Play;
      procedure Pause;
      procedure Stop;
      procedure FadeIn(Time: real; TargetVolume: single);

      procedure SetSyncSource(SyncSource: TSyncSource);

      procedure SetPosition(Time: real);
      function  GetPosition: real;

      function InitializePlayback: boolean; virtual; abstract;
      function FinalizePlayback: boolean; virtual;

      //function SetOutputDevice(Device: TAudioOutputDevice): boolean;
      function GetOutputDeviceList(): TAudioOutputDeviceList;

      procedure SetAppVolume(Volume: single); virtual; abstract;
      procedure SetVolume(Volume: single);
      procedure SetLoop(Enabled: boolean);

      procedure Rewind;
      function  Finished: boolean;
      function  Length: real;

      // Sounds
      function OpenSound(const Filename: string): TAudioPlaybackStream;
      procedure PlaySound(Stream: TAudioPlaybackStream);
      procedure StopSound(Stream: TAudioPlaybackStream);

      // Equalizer
      procedure GetFFTData(var Data: TFFTData);

      // Interface for Visualizer
      function GetPCMData(var Data: TPCMData): Cardinal;

      function CreateVoiceStream(Channel: integer; FormatInfo: TAudioFormatInfo): TAudioVoiceStream; virtual; abstract;
  end;


implementation

uses
  ULog,
  SysUtils;

{ TAudioPlaybackBase }

function TAudioPlaybackBase.FinalizePlayback: boolean;
begin
  FreeAndNil(MusicStream);
  ClearOutputDeviceList();
  Result := true;
end;

function TAudioPlaybackBase.Open(const Filename: string): boolean;
begin
  // free old MusicStream
  MusicStream.Free;

  MusicStream := OpenStream(Filename);
  if not assigned(MusicStream) then
  begin
    Result := false;
    Exit;
  end;

  //MusicStream.AddSoundEffect(TVoiceRemoval.Create());

  Result := true;
end;

procedure TAudioPlaybackBase.Close;
begin
  FreeAndNil(MusicStream);
end;

function TAudioPlaybackBase.OpenDecodeStream(const Filename: String): TAudioDecodeStream;
var
  i: integer;
begin
  for i := 0 to AudioDecoders.Count-1 do
  begin
    Result := IAudioDecoder(AudioDecoders[i]).Open(Filename);
    if (assigned(Result)) then
    begin
      Log.LogInfo('Using decoder ' + IAudioDecoder(AudioDecoders[i]).GetName() +
        ' for "' + Filename + '"', 'TAudioPlaybackBase.OpenDecodeStream');
      Exit;
    end;
  end;
  Result := nil;
end;

procedure OnClosePlaybackStream(Stream: TAudioProcessingStream);
var
  PlaybackStream: TAudioPlaybackStream;
  SourceStream: TAudioSourceStream;
begin
  PlaybackStream := TAudioPlaybackStream(Stream);
  SourceStream := PlaybackStream.GetSourceStream();
  SourceStream.Free;
end;

function TAudioPlaybackBase.OpenStream(const Filename: string): TAudioPlaybackStream;
var
  PlaybackStream: TAudioPlaybackStream;
  DecodeStream: TAudioDecodeStream;
begin
  Result := nil;

  //Log.LogStatus('Loading Sound: "' + Filename + '"', 'TAudioPlayback_Bass.OpenStream');

  DecodeStream := OpenDecodeStream(Filename);
  if (not assigned(DecodeStream)) then
  begin
    Log.LogStatus('Could not open "' + Filename + '"', 'TAudioPlayback_Bass.OpenStream');
    Exit;
  end;

  // create a matching playback-stream for the decoder
  PlaybackStream := CreatePlaybackStream();
  if (not PlaybackStream.Open(DecodeStream)) then
  begin
    FreeAndNil(PlaybackStream);
    FreeAndNil(DecodeStream);
    Exit;
  end;

  PlaybackStream.AddOnCloseHandler(OnClosePlaybackStream);

  Result := PlaybackStream;
end;

procedure TAudioPlaybackBase.Play;
begin
  if assigned(MusicStream) then
    MusicStream.Play();
end;

procedure TAudioPlaybackBase.Pause;
begin
  if assigned(MusicStream) then
    MusicStream.Pause();
end;

procedure TAudioPlaybackBase.Stop;
begin
  if assigned(MusicStream) then
    MusicStream.Stop();
end;

function TAudioPlaybackBase.Length: real;
begin
  if assigned(MusicStream) then
    Result := MusicStream.Length
  else
    Result := 0;
end;

function TAudioPlaybackBase.GetPosition: real;
begin
  if assigned(MusicStream) then
    Result := MusicStream.Position
  else
    Result := 0;
end;

procedure TAudioPlaybackBase.SetPosition(Time: real);
begin
  if assigned(MusicStream) then
    MusicStream.Position := Time;
end;

procedure TAudioPlaybackBase.SetSyncSource(SyncSource: TSyncSource);
begin
  if assigned(MusicStream) then
    MusicStream.SetSyncSource(SyncSource);
end;

procedure TAudioPlaybackBase.Rewind;
begin
  SetPosition(0);
end;

function TAudioPlaybackBase.Finished: boolean;
begin
  if assigned(MusicStream) then
    Result := (MusicStream.Status = ssStopped)
  else
    Result := true;
end;

procedure TAudioPlaybackBase.SetVolume(Volume: single);
begin
  if assigned(MusicStream) then
    MusicStream.Volume := Volume;
end;

procedure TAudioPlaybackBase.FadeIn(Time: real; TargetVolume: single);
begin
  if assigned(MusicStream) then
    MusicStream.FadeIn(Time, TargetVolume);
end;

procedure TAudioPlaybackBase.SetLoop(Enabled: boolean);
begin
  if assigned(MusicStream) then
    MusicStream.Loop := Enabled;
end;

// Equalizer
procedure TAudioPlaybackBase.GetFFTData(var data: TFFTData);
begin
  if assigned(MusicStream) then
    MusicStream.GetFFTData(data);
end;

{*
 * Copies interleaved PCM SInt16 stereo samples into data.
 * Returns the number of frames
 *}
function TAudioPlaybackBase.GetPCMData(var data: TPCMData): Cardinal;
begin
  if assigned(MusicStream) then
    Result := MusicStream.GetPCMData(data)
  else
    Result := 0;
end;

function TAudioPlaybackBase.OpenSound(const Filename: string): TAudioPlaybackStream;
begin
  Result := OpenStream(Filename);
end;

procedure TAudioPlaybackBase.PlaySound(stream: TAudioPlaybackStream);
begin
  if assigned(stream) then
    stream.Play();
end;

procedure TAudioPlaybackBase.StopSound(stream: TAudioPlaybackStream);
begin
  if assigned(stream) then
    stream.Stop();
end;

procedure TAudioPlaybackBase.ClearOutputDeviceList();
var
  DeviceIndex: integer;
begin
  for DeviceIndex := 0 to High(OutputDeviceList) do
    OutputDeviceList[DeviceIndex].Free();
  SetLength(OutputDeviceList, 0);
end;

function TAudioPlaybackBase.GetOutputDeviceList(): TAudioOutputDeviceList;
begin
  Result := OutputDeviceList;
end;

end.
