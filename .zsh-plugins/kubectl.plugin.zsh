# This sets the default editor for kubectl edit
export KUBE_EDITOR='nvim'

# This command is used a LOT both below and in daily life
alias k=kubectl

# Execute a kubectl command against all namespaces
kall(){ k "$@" --all-namespaces }

# Apply/Create from a YML file
alias kaf='k apply -f'
alias kcf='k create -f'

# Drop into an interactive terminal on a container
alias keti='k exec -it'

# Manage configuration quickly to switch contexts.
alias kcuc='k config use-context'
alias kcsc='k config set-context'
alias kcdc='k config delete-context'
alias kccc='k config current-context'
alias kccn='k config view --minify -o jsonpath="{...namespace}"'
alias kccs='k config view --minify -o jsonpath="{...server}"'
alias kcv='k config view'
alias kcvm='k config view --minify'

# Update configuration tokens quickly
kcsct(){ k config set-credentials "$1" --token "$2" }

# List all contexts
alias kcgc='k config get-contexts'
alias kcgcn='k config get-contexts -o name'

# General aliases
alias kdel='k delete'
alias kdelall='k delete --all'
alias kdelf='k delete -f'
alias kg='k get'
alias kgw='k get -w'
alias kgy='k get -o yaml'
alias ke='k edit'
alias kdeb='k debug'
alias kcr='k create'

# Pod management.
alias kr='k run'
alias kgp='k get pods'
alias kgpall='k get pods --all-namespaces'
alias kgpg='kgp | grep'
alias kgpw='kgp --watch'
alias kgpwg='kgpw | grep'
alias kgpwide='kgp -o wide'
alias kep='k edit pods'
alias kdp='k describe pods'
alias kdelp='k delete pods'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kgp -l'
alias kgpwl='kgpw -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kgp -n'
alias kgpwn='kgpw -n'

# Service management.
alias kgs='k get svc'
alias kgsall='kgs --all-namespaces'
alias kgsw='kgs --watch'
alias kgswide='kgs -o wide'
alias kes='k edit svc'
alias kds='k describe svc'
alias kdels='k delete svc'
alias kex='k expose'

# Ingress management
alias kgi='k get ingress'
alias kgiall='k get ingress --all-namespaces'
alias kei='k edit ingress'
alias kdi='k describe ingress'
alias kdeli='k delete ingress'
alias kcri='kcr ingress'

# Namespace management
alias kgns='k get namespaces'
alias kens='k edit namespace'
alias kdns='k describe namespace'
alias kdelns='k delete namespace'
alias kcn='k config set-context --current --namespace'
alias kcrns='kcr ns'

# ConfigMap management
alias kgcm='k get configmaps'
alias kgcmall='k get configmaps --all-namespaces'
alias kecm='k edit configmap'
alias kdcm='k describe configmap'
alias kdelcm='k delete configmap'
alias kcrcm='kcr cm'

# Secret management
alias kgsec='k get secret'
alias kgsecall='k get secret --all-namespaces'
alias kdsec='k describe secret'
alias kdelsec='k delete secret'
alias kesec='k edit secret'
alias kcrsec='kcr secret'
kgsecv(){ k get secret "$@" -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}' }

# Deployment management.
alias kgd='k get deployment'
alias kgdall='k get deployment --all-namespaces'
alias kgdw='kgd --watch'
alias kgdwide='kgd -o wide'
alias ked='k edit deployment'
alias kdd='k describe deployment'
alias kdeld='k delete deployment'
alias ksd='k scale deployment'
alias krsd='k rollout status deployment'
alias krrd='k rollout restart deployment'
alias kcrd='kcr deploy'

function kres(){
  k set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kgrs='k get replicaset'
alias kdrs='k describe replicaset'
alias kers='k edit replicaset'
alias krh='k rollout history'
alias kru='k rollout undo'

# Statefulset management.
alias kgss='k get statefulset'
alias kgssall='k get statefulset --all-namespaces'
alias kgssw='kgss --watch'
alias kgsswide='kgss -o wide'
alias kess='k edit statefulset'
alias kdss='k describe statefulset'
alias kdelss='k delete statefulset'
alias ksss='k scale statefulset'
alias krsss='k rollout status statefulset'
alias krrss='k rollout restart statefulset'

# Port forwarding
alias kpf="k port-forward"

# Tools for accessing all information
alias kga='k get all'
alias kgaall='k get all --all-namespaces'

# Logs
alias kl='k logs'
alias kl1h='k logs --since 1h'
alias kl1m='k logs --since 1m'
alias kl1s='k logs --since 1s'
alias klf='k logs -f'
alias klf1h='k logs --since 1h -f'
alias klf1m='k logs --since 1m -f'
alias klf1s='k logs --since 1s -f'

# File copy
alias kcp='k cp'

# Node Management
alias kgno='k get nodes'
alias keno='k edit node'
alias kdno='k describe node'
alias kdelno='k delete node'
alias klno='k label node'

# PVC management.
alias kgpvc='k get pvc'
alias kgpvcall='k get pvc --all-namespaces'
alias kgpvcw='kgpvc --watch'
alias kepvc='k edit pvc'
alias kdpvc='k describe pvc'
alias kdelpvc='k delete pvc'

# PV management.
alias kgpv='k get pv'
alias kgpvall='k get pv --all-namespaces'
alias kgpvw='kgpv --watch'
alias kepv='k edit pv'
alias kdpv='k describe pv'
alias kdelpv='k delete pv'

# Service account management.
alias kdsa="k describe sa"
alias kdelsa="k delete sa"
alias kgsa="k get sa"
alias kgsaall="k get sa --all-namespaces"
alias kcrsa='kcr sa'

# DaemonSet management.
alias kgds='k get daemonset'
alias kgdsw='kgds --watch'
alias keds='k edit daemonset'
alias kdds='k describe daemonset'
alias kdelds='k delete daemonset'
alias krrds='k rollout restart daemonset'

# CronJob management.
alias kgcj='k get cronjob'
alias kecj='k edit cronjob'
alias kdcj='k describe cronjob'
alias kdelcj='k delete cronjob'
alias kcrcj='kcr cronjob'

# Job management.
alias kgj='k get job'
alias kej='k edit job'
alias kdj='k describe job'
alias kdelj='k delete job'
alias kcrcj='kcr job'

# Events monitoring.
alias kgev='k get events --sort-by=.metadata.creationTimestamp'
alias kgevall='k get events --sort-by=.metadata.creationTimestamp --all-namespaces'
