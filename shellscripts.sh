#!/bin/bash
# Shell scripts by Aaron Clement

# APpLReMove - A shell script to remove those fucken Apple files from repos.
function aplrm() {
  if [ -z $1 ] # If the first argument exists...
  then
    echo "Provide a repo name to remove Apple files from."
  else
    REPO_PATH="/Users/Scotty/Git/$1"
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
          exit 1
      fi
    fi
  fi
}

