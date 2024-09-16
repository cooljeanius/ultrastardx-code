{***************************************************************** 
 * Configuration file for ultrastardx 1.1-beta
 * src/config-darwin.inc.  Generated from config.inc.in by configure.
 *****************************************************************}

{* Libraries *}

{$IF Defined(IncludeConstants)}
  lua_lib_name = 'lua5.1';
{$IFEND}

{$DEFINE HaveFFmpeg}
{$IF Defined(HaveFFmpeg) and Defined(IncludeConstants)}
  av__codec = 'libavcodec';
  LIBAVCODEC_VERSION_MAJOR   = 58;
  LIBAVCODEC_VERSION_MINOR   = 134;
  LIBAVCODEC_VERSION_RELEASE = 100;

  av__format = 'libavformat';
  LIBAVFORMAT_VERSION_MAJOR   = 58;
  LIBAVFORMAT_VERSION_MINOR   = 76;
  LIBAVFORMAT_VERSION_RELEASE = 100;

  av__util = 'libavutil';
  LIBAVUTIL_VERSION_MAJOR   = 56;
  LIBAVUTIL_VERSION_MINOR   = 70;
  LIBAVUTIL_VERSION_RELEASE = 100;
{$IFEND}

{$DEFINE HaveSWScale}
{$IF Defined(HaveSWScale) and Defined(IncludeConstants)}
  sw__scale = 'libswscale';
  LIBSWSCALE_VERSION_MAJOR   = 5;
  LIBSWSCALE_VERSION_MINOR   = 9;
  LIBSWSCALE_VERSION_RELEASE = 100;
{$IFEND}

{$UNDEF HaveProjectM}
{$IF Defined(HaveProjectM) and Defined(IncludeConstants)}
  ProjectM_DataDir = '';
  PROJECTM_VERSION_MAJOR   = 0;
  PROJECTM_VERSION_MINOR   = 0;
  PROJECTM_VERSION_RELEASE = 0;
{$IFEND}

{$DEFINE HavePortaudio}
{$IF Defined(HavePortaudio) and Defined(IncludeConstants)}
  PORTAUDIO_VERSION_MAJOR   = 19;
  PORTAUDIO_VERSION_MINOR   = 0;
  PORTAUDIO_VERSION_RELEASE = 0;
{$IFEND}

{$DEFINE HaveLibPcre}
{$IF Defined(HaveLibPcre) and Defined(IncludeConstants)}
  LIBPCRE_LIBDIR   = '/usr/lib';
{$IFEND}

{$UNDEF HavePortmixer}
