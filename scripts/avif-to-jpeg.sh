#!/bin/bash
mkdir -p Photos2
for f in Photos/*.avif; do
    [ -f "$f" ] || continue
    magick "$f" "Photos2/$(basename "$f" .avif).jpg"
done
