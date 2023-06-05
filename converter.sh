#!/bin/bash
 
# Comment in to see debug messages
#set -x
 
# Directory containing the video files
input_dir="</your/source/folder>"
 
# Output directory for converted files
output_dir="</your/target/folder>"
 
# Temporary directory for EAC3 audio files
temp_dir="/tmp/audio_conversion"
 
# Set new codec
new_codec="eac3"
 
# Set new bitrate
new_bitrate="768k"
 
# Create temporary directory if it doesn't exist
mkdir -p "$temp_dir"
 
# Iterate over video files (MKV) in the input directory
for file in "$input_dir"/*.mkv; do
  # Check if the file is a regular file
  if [ -f "$file" ]; then
    # Get the base filename
    filename=$(basename "$file")
 
    # Print the current file being processed
    echo "Processing file: $filename"
 
    # Extract audio information using ffprobe
    audio_info=$(ffprobe -v error -show_entries stream=index,codec_name,channels:stream_tags=language -select_streams a -of csv=p=0 "$file")
 
    # Split the audio information into an array of streams
    IFS=$'\n' read -rd '' -a streams <<< "$audio_info"
 
    # Create an array to store the temporary EAC3 audio files
    temp_files=()
 
    # Create an array to store the languages for mkvpropedit
    languages=()
 
    # Iterate over the audio streams
    for stream in "${streams[@]}"; do
      IFS=',' read -ra stream_info <<< "$stream"
      index=${stream_info[0]}
      codec=${stream_info[1]}
      channels=${stream_info[2]}
      language=${stream_info[3]}
 
      # Print the current audio stream information
      echo "Audio Stream $index:"
      echo "Codec: $codec"
      echo "Channels: $channels"
      echo "Bitrate: 768 kbps"
      echo "Language: $language"
 
      # If channels equal 8, change it to 6 (7.1 EAC3 is currently not supported by ffmpeg)
      if [ "$channels" -eq 8 ]; then
            channels="6"
      fi
 
      # If language is not set, dont set any metadata, if it is set then set the correct option
      if [ -z "$language" ]; then
        lang1=""
        lang2=""
      else
        lang1="-metadata:s:a:0 language=$language"
        lang2="--edit track:a$index --set language=$language "
      fi
 
      # Create a temporary EAC3 audio file with a fixed bitrate of 768 kbps
      temp_eac3_file="$temp_dir/${filename%.*}_stream_$index.eac3"
      ffmpeg -i "$file" -map 0:$index $lang1 -c:a $new_codec -b:a $new_bitrate -ac $channels "$temp_eac3_file"
 
      # Construct the temporary EAC3 audio files for mkvmerge
      temp_files+=("$temp_eac3_file")
 
      # Construct the audio stream language for mkvmerge
      languages+=("$lang2")
    done
 
    # Construct the output filename
    output_filename="$output_dir/${filename%.*}_converted.${filename##*.}"
 
    # Wait for a few seconds before remuxing to ensure the input file is closed
    sleep 5
 
    # Remux the video and audio streams using mkvmerge
    mkvmerge -o "$output_filename" -A "$file" "${temp_files[@]}"
 
    # Set language metadata for the new audio streams using mkvpropedit
    mkvpropedit "$output_filename" ${languages[@]}
 
    echo "Conversion complete for file: $filename"
    echo "----------------------------------"
 
    # Clean up temporary directory files
    rm $temp_dir/*
 
  fi
done
 
# Clean up temporary directory
rm -rf "$temp_dir"
