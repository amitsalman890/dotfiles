#!/usr/bin/env bash

hop1=$1
hop2=$2
inst_index=$3     ## optional
inst_index_end=$4 ## optional

function split_term() {
  local cmd=$1
  #    echo "$cmd"
  osascript &>/dev/null <<EOF
      tell application "iTerm"
        tell current session of current window
          set newShell to (split vertically with default profile)
        end tell

        tell newShell
            write text "$cmd"
        end tell
      end tell
EOF
}

validate=$(curl -s ident.me)

if [ $validate == "207.232.13.77" ]; then
  echo -e '\033[0;34mUpdating SSV config before running... \033[0m'
  curl -s https://s3.amazonaws.com/spotinst-private/assets/vpn/config4vpn -o ~/.ssh/config4vpn
  echo -e '\033[0;34mDone. \033[0m'
fi

#echo "cat ~/.ssh/config4vpn | grep '$1' -A 3"
filecontent=($(cat ~/.ssh/config4vpn | grep "$hop1" -A 3))

ip=${filecontent[3]}
user=${filecontent[5]}
key=${filecontent[7]}

## direct ssh
if [ -z "$hop2" ]; then
  ssh -i $key $user@$ip
else
  ## ssh via bastion to a single host
  if [ -z "$inst_index_end" ]; then
    echo -e "\033[0;31m ---------------------->>> Using Bastion Server $hop1 to connect to $hop2 <<<---------------------- \033[0m"
    # ssh -tt -i $key $user@$ip "ssh -o StrictHostKeyChecking=no -o ConnectTimeout=2 $hop2 $cmd"
    ssh -tt -i $key $user@$ip "./si $hop2 $inst_index"
  ## open iterm terminals for number of instances
  else
    [ "$(uname -s)" != "Darwin" ] && exit 2 # only for Mac users
    for i in $(seq $inst_index_end $inst_index); do
      split_term "ssh -tt -i $key $user@$ip './si $hop2 $i'"
    done
  fi
fi
