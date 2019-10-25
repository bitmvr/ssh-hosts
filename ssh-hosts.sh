#!/usr/bin/env bash

readonly SCRIPT_NAME="$(basename "$0")"
readonly VERSION="1.0.0"

ssh-hosts::getConfigs(){
    find "${HOME}/.ssh/" -type f -name "*config*"
}

ssh-hosts::getHosts(){
    for config in $(ssh-hosts::getConfigs); do
        grep "^Host" "$config" | awk '{ print $2 }'
    done
}

ssh-hosts::sshWrapper(){
  host="$1"
  ssh -q -o StrictHostKeyChecking=no -o PasswordAuthentication=no ${host} exit
}

ssh-hosts::configCheck(){
  for host in $(ssh-hosts::getHosts); do
    ssh-hosts::sshWrapper "$host"
    if [ "$?" != 0 ]; then
      echo "${host}: UNSUCCESSFUL"
    else
      echo "${host}: SUCCESSFUL"
    fi
  done
}

bff::usage(){
  echo ""
  echo "${SCRIPT_NAME} - List and validate your SSH configuration(s)"
  echo ""
  echo "usage: ${SCRIPT_NAME} <option>"
  echo ""
  echo "  -c | --check-config   Validates connections to each machine inside the configuration"
  echo "  -h | --help           Display this help text"
  echo "  -l | --list           Lists all name from the configuration. This is the default operation"
  echo "  -v | --version        Displays version of ${SCRIPT_NAME}"
  echo ""
}

bff::getVersion(){
  echo "$VERSION"
}

bff::hasValue(){
  if [ -z "$1" ]; then
    return 1
  fi
}

if [ "$#" -eq 0 ]; then
  ssh-hosts::getHosts
fi

while (( $# )); do
  case "$1" in 
  -c|--check-config)
    ssh-hosts::configCheck
    exit 0
  ;;
  -h|--help)
    bff::usage
    exit 0
  ;;
  -l|--list)
    ssh-hosts::getHosts
    exit 0
  ;;
  -v|--version)
    bff::getVersion
    exit 0
  ;;
  *)
    echo ""
    echo "Invalid option(s) given"
    echo ""
    exit 1
  ;;
  esac
done

