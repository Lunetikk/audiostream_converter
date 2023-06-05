# Audiostream Converter
this script will convert any audiostream (AAC, DTS, ...) of a .mkv file to EAC3 768k with the same channels (via ffmpeg), then remux these audiostreams to a new .mkv (via mkvmerge)

***Prerequisites***

mkvtoolnix - Matroska tools
ffmpeg - Audio conversion tool

While these apps are available via the default repos on Ubuntu, you can get a newer version of mkvtoolnix via their [mkvtoolnix - Repo](https://mkvtoolnix.download/downloads.html#ubuntu)

Visit [developer.spotify.com](https://developer.spotify.com/documentation/general/guides/authorization/app-settings/) and register an App. 

***Usage***

Edit the following variables inside the script

```
# Directory containing the video files
input_dir=“</your/source/folder>“
# Output directory for converted files
output_dir=”</your/target/folder>“
# Temporary directory for EAC3 audio files
temp_dir=”/tmp/audio_conversion”
# Set new codec
new_codec=“eac3”
# Set new bitrate
new_bitrate=“768k”
```

If you run the script it will convert all files inside the “input_dir”, the output file will have all audio streams converted to the set “new_codec” and “new_bitrate” but with the same channels as before. 
If the original audio stream had 7.1 channels it will be set to 5.1 because ffmpeg EAC3 only supports up to 5.1.

***ToDo***

I currently work on the following changes:
- accept commandline options like "-b bitrate"
- keep existing aac/ac3 audiostreams, only convert dts
- keep lower existing bitrate, if 256k dont use 768k
