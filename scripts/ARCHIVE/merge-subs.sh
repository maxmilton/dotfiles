#!/usr/bin/env bash
set -euo pipefail
shopt -s nullglob

dir=${1:-.}

[[ -d $dir ]] || {
  printf 'error: not a directory: %s\n' "$dir" >&2
  exit 2
}

for cmd in ffmpeg ffprobe; do
  command -v "$cmd" >/dev/null || {
    printf 'error: %s not found\n' "$cmd" >&2
    exit 127
  }
done

tmp=

cleanup() {
  [[ -z $tmp ]] || rm -f -- "$tmp"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

rc=0

for video in "$dir"/*.mkv; do
  [[ $video == *.temp.mkv ]] && continue

  stem=${video%.mkv}
  subs=( "$stem".*.vtt )

  ((${#subs[@]})) || continue

  # Don't delete a sidecar that FFmpeg sees as containing no subtitle cues.
  for sub in "${subs[@]}"; do
    packets=$(
      ffprobe \
        -v error \
        -count_packets \
        -select_streams s:0 \
        -show_entries stream=nb_read_packets \
        -of default=nw=1:nk=1 \
        "$sub"
    ) || packets=

    if [[ ! $packets =~ ^[1-9][0-9]*$ ]]; then
      printf 'error: no readable subtitle cues: %s\n' "${sub##*/}" >&2
      rc=1
      continue 2
    fi
  done

  tmp=$(
    mktemp \
      --tmpdir="$(dirname -- "$video")" \
      --suffix=.mkv \
      '.merge-subs.XXXXXXXX'
  )

  printf 'Merging: %s\n' "${video##*/}"

  args=(
    ffmpeg
    -hide_banner
    -loglevel warning
    -xerror
    -nostdin
    -y
    -i "$video"
  )

  for sub in "${subs[@]}"; do
    printf '  + %s\n' "${sub##*/}"
    args+=( -i "$sub" )
  done

  # Preserve every existing stream except embedded subtitles.
  args+=(
    -map 0
    -map '-0:s?'
    -c copy
  )

  # Add the replacement sidecars.
  for i in "${!subs[@]}"; do
    sub=${subs[$i]}

    lang=${sub#"$stem".}
    lang=${lang%.vtt}

    case $lang in
      en) lang=eng ;;
      ko) lang=kor ;;
    esac

    args+=(
      -map "$((i + 1)):s:0"
      -metadata:s:s:"$i" language="$lang"
    )
  done

  # Don't arbitrarily make the first subtitle the default.
  args+=(
    -disposition:s 0
    "$tmp"
  )

  if "${args[@]}"; then
    # Preserve mode, ownership, timestamps, ACLs/xattrs, etc. without
    # replacing the newly remuxed contents.
    cp --attributes-only --preserve=all -- "$video" "$tmp"

    # Same directory/filesystem, so this is a rename rather than a copy.
    mv -f -- "$tmp" "$video"
    tmp=

    rm -f -- "${subs[@]}"

    echo '  done'
  else
    printf '  failed; original and sidecars left intact\n' >&2
    rm -f -- "$tmp"
    tmp=
    rc=1
  fi
done

exit "$rc"
