#!/bin/bash

# made to rename files according to the Kivitas naming scheme of Series Name A - v01.cbz et cetera. change Name to the books name.
#or just use this to rename files in general.
read -p "Enter the Book's Name: " n
read -p "Enter the Starting chapter Number: (default=1)" a

# setting default values if no input was provided
n=${n:-"Undefined"}
a=${a:-"1"}

for i in *.cbz; do
  if [ "$a" -lt 10 ]; then
    new=$(printf "$n - v0%d.cbz" "$a")  # For numbers less than 10, use a leading zero.
  else
    new=$(printf "$n - v%d.cbz" "$a")   # For numbers 10 and above, no leading zero.
  fi
  mv -n "$i" "$new"
  let a=a+1
done
