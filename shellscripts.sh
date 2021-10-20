#!/bin/bash
# Shell scripts by Aaron Clement

# APpLReMove - Remove Apple files from a folder (relative to ~/)
# >aplrm [folder path]
function aplrm() {
  if [ -z $1 ] # If the first argument exists...
  then
    echo "Provide a repo name to remove Apple files from."
  else
    REPO_PATH="~/$1"
    if ! test -d $REPO_PATH  # ...check if the directory exists.
    then 
      echo "The specified repo does not exist."
    else
      echo "I will search that repository..."
      # Use an extended regex search (allows the grouping operator)...
      # ...to find files beginning with "._" or named ".DS_Store"...
      # ...then count the number of files matched.
      NUM_MATCHES=`find -E $REPO_PATH -regex "(.*\._.*|.*\.DS_Store)" | wc -l`
      # Offer prompt which accepts one character and saves the response to $REPLY.
      # The $(()) parses the variable as an integer, which strips whitespace from it.
      read -p "There are $(( $NUM_MATCHES )) Apple files in that repo. Delete them? (y/n) " -n 1 -r
      echo    # Move to a new line.
      if [[ $REPLY =~ ^[Yy]$ ]] # If the reply is Y or y...
      then
        echo "Very well then..."
        find $REPO_PATH -regex "(.*\._.*|.*\.DS_Store)" -delete # ...delete the files.
        echo "It is done, exiting now."
      else
        echo "Very well then, exiting now."
      fi
      exit 0
    fi
  fi
}

# PHoto LIMit size
# > phlim [limit] [glob path]
function phlim() {
  if [ -z $1 ]
  then
    echo "Provide a limit for the photos, either in bytes (ex. 1234B) or pixels (ex. 123x456)."
  else
    TBYTES=${1%B}
    if ((${#1} > ${#TBYTES}))
    then # There was a B (for btyes) at the end of the limiter and we should limit by bytes
      if [[ $TBYTES =~ ^[0-9]*$ ]]
      then
        echo "Bytes detected, I will limit photos by filesize to under $TBYTES bytes."
      else
        echo "The limit argument is malformed; if you want to limit bytes then it should match the pattern /^[0-9]*B$/"
      fi
    else
      TBYTES=0
      if [[ $1 =~ ^[0-9]*x[0-9]*$ ]]
      then
        TWIDTH=${1%x*}
        THEIGHT=${1#*x}
        echo "Pixels detected, I will limit images to fit in the dimensions $TWIDTH by $THEIGHT."
      else
        echo "The limit argument is malformed; if you want to limit pixels then it should match the pattern /^[0-9]*x[0-9]*$/"
      fi
    fi

    if [ -z $2 ]
    then
      echo "Provide a globbed path to check file sizes for."
    else
      for FILEPATH in "$@"
      do
        if [ "$FILEPATH" != "$1" ]
        then
          if [[ -f "$FILEPATH" ]]
          then
            INFO=`magick identify $FILEPATH`
            # ./gallery/body/mommy-makeover/01/01.jpg JPEG 800x533 800x533+0+0 8-bit sRGB 62538B 0.000u 0:00.000
            # [0]                                     [1]  [2]     [3]         [4]   [5]  [6]    [7]    [8]
            IFS=' '
            ARRAY=( $INFO )
            unset IFS
            echo "Analyzing the file ${ARRAY[0]}"
            WIDTH=${ARRAY[2]%x*}
            echo " - This image is $WIDTH pixels wide."
            HEIGHT=${ARRAY[2]#*x}
            echo " - This image is $HEIGHT pixels tall."
            BYTES=${ARRAY[6]%B}
            echo " - This image is $BYTES bytes in size."

            if [ $TBYTES -eq "0" ]
            then
              if (($WIDTH > $TWIDTH))
              then
                echo "The width exceeds the limit, I'm scaling the photo down."
                magick mogrify -resize $1 -quality 80 $FILEPATH
              elif (($HEIGHT > $THEIGHT))
              then
                echo "The height exceeds the limit, I'm scaling the photo down."
                magick mogrify -resize $1 -quality 80 $FILEPATH
              fi
            else
              if (($BYTES > $TBYTES))
              then
                echo "The filesize exceeds the limit, I'm scaling the photo down."
                # Fudging the numbers here because Bash doesn't do floating point math
                RATIO=.$(expr ${TBYTES}000 / $BYTES)
                # This ratio is for filesizes (which are proportional to area)
                # To scale a linear dimension with the ratio, we need to take its square root first
                NEWWIDTH=`echo "sqrt($RATIO) * $WIDTH" | bc`
                # Chop off the decimal places and scale to this width
                magick mogrify -resize ${NEWWIDTH%.*}x10000 -quality 80 $FILEPATH
              fi
            fi
          fi
        fi
      done
    fi
  fi
}

