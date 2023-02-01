#!/usr/bin/env bash
# Paulo Aleixo Campos
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
function shw_info { echo -e '\033[1;34m'"$1"'\033[0m'; }
function error { echo "ERROR in ${1}"; exit 99; }
trap 'error $LINENO' ERR
#exec > >(tee -i /tmp/$(date +%Y%m%d%H%M%S.%N)__$(basename $0).log ) 2>&1
PS4='████████████████████████${BASH_SOURCE}@${FUNCNAME[0]:-}[${LINENO}]>  '
set -o errexit
set -o pipefail
set -o nounset
set -o xtrace


main() {
  # parse args - ARGx will be "" or have its value
  OrigArgs="${@}"
  #local ARG1="${1:-}"  ; [[ "${1:-}" ]] && shift
  #local ARG2="${1:-}"  ; [[ "${1:-}" ]] && shift
  cd "${__dir}"

  docker compose up -d
  # gitea docker.container is started in kind docker-network, and added into /etc/hosts as "gitea.dockr"
  DockerC8r_NetworkKind_Ip=$(docker network inspect kind | jq -r '.[0].Containers[] | select(.Name=="gitea") | .IPv4Address' | cut -d'/' -f1)
  if grep 'gitea.dockr' /etc/hosts 
  then
    sudo sed '/gitea.dockr/d' -i /etc/hosts
  fi
  echo "${DockerC8r_NetworkKind_Ip} gitea.dockr" | sudo tee -a /etc/hosts


  shw_info "
== $(basename $0) ${OrigArgs}
== Finished successfully =="

}
main "${@}"
