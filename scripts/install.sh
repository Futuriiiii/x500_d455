#!/bin/bash

# get the path to this script
MY_PATH="$(dirname "$(dirname "$(realpath "$0")")")"

simulation_path=$(rospack find mrs_simulation)

default=y

# Ask about udev rules
while true; do
  [[ -t 0 ]] && { read -r -t 10 -n 2 -p $'\e[1;32mDo you want to install realsense_d455 in X500? [y/n] (default: '"$default"$')\e[0m\n' resp || resp=$default ; }
  response=$(echo $resp | sed -r 's/(.*)$/\1=/')

  if [[ $response =~ ^(y|Y)=$ ]]
  then

    ln -fsT "$MY_PATH"/models/meshes "$simulation_path"/models/mrs_robots_description/meshes/custom/d455

    # add suspended load option to the spawner configs
    file="$simulation_path"/config/spawner_params.yaml
    if ! grep -q enable_d455 "$file"; then
      sed -i '1 i enable_d455: [False, '"'"'Add realsense d455 to the vehicle'"'"', [x500]]' "$file"
    fi
    
    # add mounting options for the model
    UAVS=("x500")
    
    for j in "${UAVS[@]}"
    do
      file="$simulation_path"/models/mrs_robots_description/sdf/$j.sdf.jinja
      if ! grep -q "$j"\_config "$file"; then
        sed -i '/\/model/ i\\t{%- include "mrs_robots_description/sdf/'$j'_d455.sdf.jinja" -%}' "$file"
      fi
      ln -fs "$MY_PATH"/models/sdf/"$j"\_d455.sdf.jinja "$simulation_path"/models/mrs_robots_description/sdf/.
    done

    break
  elif [[ $response =~ ^(n|N)=$ ]]
  then
    break
  else
    echo " What? \"$resp\" is not a correct answer. Try y+Enter."
  fi
done
