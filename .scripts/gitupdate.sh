#!/bin/bash

#***********************************************************************************#
# Small script to update all git repositories in ~/git.				    #
# It loops through all folders in ~/git and performs 'git pull'.		    #
#***********************************************************************************#

# Get username and define path to ~/git
USER=$(whoami)
GIT_PATH="/home/$USER/git/"

# Loop through all the folders
cd $GIT_PATH
for dir in $(ls -d */); do
  cd $dir
  git pull
  cd $GIT_PATH
done
