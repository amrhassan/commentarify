#! env bash

# Mix-in a commentary track to your favorite movie.
# Usage:
#   commentarify movie.mkv 1 commentary.wav 14000 RLM


set -o nounset

# The path to the movie file
MOVIE="$1"

# The ID of the movie audio track to mix with the commentary track
MOVIE_AUDIO_TRACK_ID="$2"

# The path to the commentary audio file
COMMENTARY_AUDIO="$3"

# The desired delay of the commentary track (in ms)
COMMENTARY_DELAY="$4"

# The desired title of the commentary track
COMMENTARY_TITLE="$5"


# The path to the output movie file
OUTPUT="${MOVIE%.*}.$COMMENTARY_TITLE.${MOVIE##*.}"

echo "Using the movie from $MOVIE"
echo "  Audio track ID $MOVIE_AUDIO_TRACK_ID"
echo "Using the commentary from $COMMENTARY_AUDIO"
echo "  Delayed by $COMMENTARY_DELAY ms"
echo "Writing output to $OUTPUT"
echo "Processing..."



ffmpeg \
	-v panic \
	-i "$MOVIE" \
	-i "$COMMENTARY_AUDIO" \
	-filter_complex "[0:$MOVIE_AUDIO_TRACK_ID]pan=stereo|FL=FC+0.30FL+0.30BL|FR=FC+0.30FR+0.30BR[a00];\
					 [1:a:0]adelay=$COMMENTARY_DELAY|$COMMENTARY_DELAY[a10];\
					 [a00][a10]amix=inputs=2:duration=first:weights=0.1 0.9[a2]" \
	-map "[a2]" \
	-map "0:v" \
	-map "0:a" \
	-map "0:s?" \
	-map "0:d?" \
	-c copy \
	-c:a:0 libvorbis -q:a:0 10.0 -metadata:s:a:0 title=$COMMENTARY_TITLE \
	"$OUTPUT"

echo "Done!"
