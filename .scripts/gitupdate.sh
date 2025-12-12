#!/bin/bash

#***********************************************************************************#
# Small script to update all git repositories in ~/git.				    #
# It loops through all folders in ~/git and performs 'git pull'.		    #
# SSH-keys can be imported automatically with ssh_add_pass() via pass files (gpg).  #
#***********************************************************************************#

# Function to load ssh keys with pass files
ssh_add_pass() {
    local keyfile="$1"
    local passname="$2"

    if [[ -z "$keyfile" || -z "$passname" ]]; then
        echo "Usage: ssh_add_pass <keyfile> <pass-name>"
        return 1
    fi

    # Create temp askpass helper
    local askpass
    askpass=$(mktemp)
    cat > "$askpass" <<EOF
#!/bin/sh
pass "$passname"
EOF
    chmod +x "$askpass"

    # Run ssh-add non-interactively
    DISPLAY=none SSH_ASKPASS="$askpass" setsid ssh-add "$keyfile" </dev/null

    rm -f "$askpass"
}

# Start ssh-agent and add keys
eval $(ssh-agent)
ssh_add_pass .ssh/id_ed25519_1 pass_key_1
ssh_add_pass .ssh/id_ed25519_2 pass_key_2
ssh_add_pass .ssh/id_ed25519_3 pass_key_3

# Get username and define path to ~/git
USER=$(whoami)
GIT_PATH="/home/$USER/git/"

# Loop through all the folders
cd $GIT_PATH
for dir in $(ls -d */); do
  cd $dir
  echo "${dir%/}:" && git pull
  cd $GIT_PATH
done

# Kill ssh-agent
ssh-agent -k
