#!/bin/bash

# made to rename files according to the jellyfin's episode naming scheme of 'Series Name A S01E01.mkv' et cetera. change Name to the series name.
#or just use this to rename files in general.
a=1
for i in *.mkv; do
  if [ "$a" -lt 10 ]; then
    new=$(printf "Name0%d.mkv" "$a")  # For numbers less than 10, use a leading zero.
  else
    new=$(printf "Name%d.mkv" "$a")   # For numbers 10 and above, no leading zero.
  fi
  mv -i -- "$i" "$new"
  let a=a+1
done
