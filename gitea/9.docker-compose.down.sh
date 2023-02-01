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
  cd "${__dir}"
  # parse args - ARGx will be "" or have its value
  OrigArgs="${@}"
  #local ARG1="${1:-}"  ; [[ "${1:-}" ]] && shift
  #local ARG2="${1:-}"  ; [[ "${1:-}" ]] && shift
  docker compose down


  shw_info "
== $(basename $0) ${OrigArgs}
== Finished successfully =="

}
main "${@}"
