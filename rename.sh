#!/bin/bash

# made to rename files according to the jellyfins episode naming scheme of Series Name A S01E01.mkv et cetera. change Name to the series name.
#or just use this to rename files in general.
a=1
for i in *.mkv; do
  if [ "$a" -lt 10 ]; then
    new=$(printf "Name of Series S01E0%d.mkv" "$a")  # For numbers less than 10, use a leading zero.
  else
    new=$(printf "Name of Series S01E%d.mkv" "$a")   # For numbers 10 and above, no leading zero.
  fi
  mv -n "$i" "$new"
  let a=a+1
done
