#!/bin/bash
# creates files called file01.txt to fileN.txt based on the input

# Ask the user for the number of files to create
read -p "Enter the number of files to create: " n

# Initialize counter
a=1
# Loop to create files
while [ "$a" -le "$n" ]; do
  if [ "$a" -lt 10 ]; then
    filename=$(printf "file0%d.txt" "$a")  # For numbers less than 10, use leading zero
  else
    filename=$(printf "file%d.txt" "$a")   # For numbers 10 and above, no leading zero
  fi
  touch "$filename"
  let a=a+1
done
echo "$n files created successfully!"
