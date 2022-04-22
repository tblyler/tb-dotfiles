if command -v mpv &> /dev/null && command -v fzf &> /dev/null; then
	if [[ "$OSTYPE" = linux* ]]; then
		function camera() {
			(
				set -euo pipefail

				printf "%s\0" /dev/video* |
					fzf --print0 --read0 -m -1 --height="$((LINES/4))" |
					xargs -0 -P 0 -I {} mpv \
						-vf=hflip \
						--demuxer-lavf-format=video4linux2 \
						--demuxer-lavf-o-set=input_format=mjpeg \
						av://v4l2:{}
			)
		}
	fi
fi
