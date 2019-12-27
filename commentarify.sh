#! env bash

set -o errexit
set -o pipefail
set -o nounset
# set -o xtrace


MOVIE=""
COMMENTARY_DELAY=""
MOVIE_AUDIO_TRACK_ID=""
COMMENTARY_AUDIO=""
OUTPUT=""
COMMENTARY_TITLE=""

ffmpeg \
	-i "$MOVIE" \
	-i "$COMMENTARY_AUDIO" \
	-filter_complex "[0:$MOVIE_AUDIO_TRACK_ID]pan=stereo|FL=FC+0.30FL+0.30BL|FR=FC+0.30FR+0.30BR[a00];\
					 [1:a:0]adelay=$COMMENTARY_DELAY|$COMMENTARY_DELAY[a10];\
					 [a00]volume=0.1[a01];\
					 [a01][a10]amix=inputs=2:duration=first[a2]" \
	-map "[a2]" \
	-map "0:v" \
	-map "0:a" \
	-map "0:s?" \
	-map "0:d?" \
	-c copy \
	-c:a:0 libvorbis -q:a:0 10.0 -metadata:s:a:0 title=$COMMENTARY_TITLE \
	"$OUTPUT"
