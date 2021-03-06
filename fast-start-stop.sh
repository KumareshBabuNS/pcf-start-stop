#!/bin/bash
# Deletes BOSH vms with ruthless abandon

if [[ ($1 == "shut") || ($1 == "start" ) || ($1 == "shutall") ]]
        then
                echo "Running PCF $1 Process (warning: this toggles director resurrection off/on!)..."
        else
                echo "Usage: $0 [shut|start|shutall]"
                exit 1
fi

deleteVMs() {
 bosh vm resurrection off
  for x in $jobVMs; do
     jobId=$(echo $x | awk -F "/" '{ print $1 }')
     instanceId=$(echo $x | awk -F "/" '{ print $2 }'| awk -F '(' '{ print $1 }')
     if [ -z $instanceId ]; then
       continue
     fi
     jobVMID=$(echo $x | awk -F ',' '{ print $2 }')
       echo Killing: $jobId
       bosh -n -N delete vm $jobVMID
   done
   echo "Kill VM tasks scheduled, execing 'watch bosh tasks --no-filter' to track progress"
   watch bosh tasks --no-filter
}

if [ $1 == "shutall" ]; then
 jobVMs=$(bosh vms --details| awk -F '|' '{gsub(/ /, "", $0); print $2","$7 }')
 deleteVMs
fi

if [ $1 == "shut" ]; then
 jobVMs=$(bosh instances --details| awk -F '|' '{gsub(/ /, "", $0); print $2","$7 }')
 deleteVMs
fi


if [ $1 == "start" ]; then
 bosh -n deploy
 bosh vm resurrection on
fi

