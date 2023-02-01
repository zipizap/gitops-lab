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

run_kind() {
  local START_OR_STOP="${1?missing args}"
  case "${START_OR_STOP}" in
  start)
    if kind get clusters | grep kind &>/dev/null
    then
	  	# kind cluster already exists, do nothing
      :
    else
	  	# kind cluster does not exist, lets create it
      cat <<EOF | kind create cluster --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
name: kind   #cluster name for "kind get cluster"
nodes:
- role: control-plane
  # #K8s version to deploy (see  https://github.com/kubernetes-sigs/kind/releases)
  # image: kindest/node:v1.21.1@sha256:69860bda5563ac81e3c0057d654b5253219618a22ec3a346306239bba8cfa1a6
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  # Ingress: expose k8s-ingress-ports (containerPort) into dockerhost-ports (hostPort)
  # dockerHost:10080 and 10443
  - containerPort: 80
    hostPort: 10080
    protocol: TCP
  - containerPort: 443
    hostPort: 10443
    protocol: TCP
EOF
    fi
    ;;
  stop)
    kind delete cluster
    ;;
  esac
}

run_gitea() {
  local START_OR_STOP="${1?missing args}"
  case "${START_OR_STOP}" in
  start)
    gitea/0.docker-compose.up.sh
    ;;
  stop)
    gitea/9.docker-compose.down.sh
    ;;
  esac

}

run_fluxcd_bootstrap() {
  local START_OR_STOP="${1?missing args}"
  case "${START_OR_STOP}" in
  start)
    #fluxcd/0.download.fluxcd.sh
    fluxcd/1.flux.bootstrap.sh
    ;;
  stop)
    # do nothing, fluxcd will disapear when kind cluster is destroyed
    :
    ;;
  esac
}

main() {
  cd "${__dir}"
  # parse args - ARGx will be "" or have its value
  OrigArgs="${@}"
  START_OR_STOP="${1?USAGE: $0 start|stop}"

  case "${START_OR_STOP}" in
    start)
      run_kind "${START_OR_STOP}"
      run_gitea "${START_OR_STOP}"  
      run_fluxcd_bootstrap "${START_OR_STOP}"
      ;;
    stop)
      run_fluxcd_bootstrap "${START_OR_STOP}"
      run_gitea "${START_OR_STOP}"  
      run_kind "${START_OR_STOP}"
      ;;
  esac


  shw_info "
== $(basename $0) ${OrigArgs}
== Finished successfully =="

}
main "${@}"
