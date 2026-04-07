# This sets the default editor for kubectl edit
export KUBE_EDITOR='nvim'

# This command is used a LOT both below and in daily life
alias k=kubectl

# Execute a kubectl command against all namespaces
kall(){ kubectl "$@" --all-namespaces }

# Apply/Create from a YML file
alias kaf='kubectl apply -f'
alias kcf='kubectl create -f'

# Drop into an interactive terminal on a container
alias keti='kubectl exec -it'

# Manage configuration quickly to switch contexts.
alias kcuc='kubectl config use-context'
alias kcsc='kubectl config set-context'
alias kcdc='kubectl config delete-context'
alias kccc='kubectl config current-context'
alias kccn='kubectl config view --minify -o jsonpath="{...namespace}"'
alias kccs='kubectl config view --minify -o jsonpath="{...server}"'
alias kcv='kubectl config view'
alias kcvm='kubectl config view --minify'
alias kctx='kubectx'

# Update configuration tokens quickly
kcsct(){ kubectl config set-credentials "$1" --token "$2" }

# List all contexts
alias kcgc='kubectl config get-contexts'
alias kcgcn='kubectl config get-contexts -o name'

# General aliases
alias kdel='kubectl delete'
alias kdelall='kubectl delete --all'
alias kdelf='kubectl delete -f'
alias kg='kubectl get'
alias kgw='kubectl get -w'
alias kgy='kubectl get -o yaml'
alias ke='kubectl edit'
alias kdeb='kubectl debug'
alias kcr='kubectl create'

# Pod management.
alias kr='kubectl run'
alias kgp='kubectl get pods'
alias kgpall='kubectl get pods --all-namespaces'
alias kgpg='kubectl get po | grep'
alias kgpw='kubectl get po --watch'
alias kgpwg='kubectl get po -w | grep'
alias kgpwide='kubectl get po -o wide'
alias kep='kubectl edit pods'
alias kdp='kubectl describe pods'
alias kdelp='kubectl delete pods'

# get pod by label: kgpl "app=myapp" -n myns
alias kgpl='kubectl get po -l'
alias kgpwl='kubectl get po -w -l'

# get pod by namespace: kgpn kube-system"
alias kgpn='kubectl get po -n'
alias kgpwn='kubectl get po -w -n'

# Service management.
alias kgs='kubectl get svc'
alias kgsall='kubectl get svc --all-namespaces'
alias kgsw='kubectl get svc --watch'
alias kgswide='kubectl get svc -o wide'
alias kes='kubectl edit svc'
alias kds='kubectl describe svc'
alias kdels='kubectl delete svc'
alias kex='kubectl expose'

# Ingress management
alias kgi='kubectl get ingress'
alias kgiall='kubectl get ingress --all-namespaces'
alias kei='kubectl edit ingress'
alias kdi='kubectl describe ingress'
alias kdeli='kubectl delete ingress'
alias kcri='kubectl create ingress'

# Namespace management
alias kgns='kubectl get namespaces'
alias kens='kubectl edit namespace'
alias kdns='kubectl describe namespace'
alias kdelns='kubectl delete namespace'
alias kcn='kubectl config set-context --current --namespace'
alias kcrns='kubectl create ns'
alias kns='kubens'

# ConfigMap management
alias kgcm='kubectl get configmaps'
alias kgcmall='kubectl get configmaps --all-namespaces'
alias kecm='kubectl edit configmap'
alias kdcm='kubectl describe configmap'
alias kdelcm='kubectl delete configmap'
alias kcrcm='kubectl create cm'

# Secret management
alias kgsec='kubectl get secret'
alias kgsecall='kubectl get secret --all-namespaces'
alias kdsec='kubectl describe secret'
alias kdelsec='kubectl delete secret'
alias kesec='kubectl edit secret'
alias kcrsec='kubectl create secret'
kgsecv(){ kubectl get secret "$@" -o go-template='{{range $k,$v := .data}}{{"### "}}{{$k}}{{"\n"}}{{$v|base64decode}}{{"\n\n"}}{{end}}' }

# Deployment management.
alias kgd='kubectl get deployment'
alias kgdall='kubectl get deployment --all-namespaces'
alias kgdw='kubectl get deploy --watch'
alias kgdwide='kubectl get deploy -o wide'
alias ked='kubectl edit deployment'
alias kdd='kubectl describe deployment'
alias kdeld='kubectl delete deployment'
alias ksd='kubectl scale deployment'
alias krsd='kubectl rollout status deployment'
alias krrd='kubectl rollout restart deployment'
alias kcrd='kubectl create deploy'

function kres(){
  kubectl set env $@ REFRESHED_AT=$(date +%Y%m%d%H%M%S)
}

# Rollout management.
alias kgrs='kubectl get replicaset'
alias kdrs='kubectl describe replicaset'
alias kers='kubectl edit replicaset'
alias krh='kubectl rollout history'
alias kru='kubectl rollout undo'

# Statefulset management.
alias kgss='kubectl get statefulset'
alias kgssall='kubectl get statefulset --all-namespaces'
alias kgssw='kubectl get sts --watch'
alias kgsswide='kubectl get sts -o wide'
alias kess='kubectl edit statefulset'
alias kdss='kubectl describe statefulset'
alias kdelss='kubectl delete statefulset'
alias ksss='kubectl scale statefulset'
alias krsss='kubectl rollout status statefulset'
alias krrss='kubectl rollout restart statefulset'

# Port forwarding
alias kpf="kubectl port-forward"

# Tools for accessing all information
alias kga='kubectl get all'
alias kgaall='kubectl get all --all-namespaces'

# Logs
alias kl='kubectl logs'
alias kl1h='kubectl logs --since 1h'
alias kl1m='kubectl logs --since 1m'
alias kl1s='kubectl logs --since 1s'
alias klf='kubectl logs -f'
alias klf1h='kubectl logs --since 1h -f'
alias klf1m='kubectl logs --since 1m -f'
alias klf1s='kubectl logs --since 1s -f'

# File copy
alias kcp='kubectl cp'

# Node Management
alias kgno='kubectl get nodes'
alias keno='kubectl edit node'
alias kdno='kubectl describe node'
alias kdelno='kubectl delete node'
alias klno='kubectl label node'

# PVC management.
alias kgpvc='kubectl get pvc'
alias kgpvcall='kubectl get pvc --all-namespaces'
alias kgpvcw='kubectl get pvc --watch'
alias kepvc='kubectl edit pvc'
alias kdpvc='kubectl describe pvc'
alias kdelpvc='kubectl delete pvc'

# PV management.
alias kgpv='kubectl get pv'
alias kgpvall='kubectl get pv --all-namespaces'
alias kgpvw='kubectl get pv --watch'
alias kepv='kubectl edit pv'
alias kdpv='kubectl describe pv'
alias kdelpv='kubectl delete pv'

# Service account management.
alias kdsa="kubectl describe sa"
alias kdelsa="kubectl delete sa"
alias kgsa="kubectl get sa"
alias kgsaall="kubectl get sa --all-namespaces"
alias kcrsa='kubectl create sa'

# DaemonSet management.
alias kgds='kubectl get daemonset'
alias kgdsw='kubectl get ds --watch'
alias keds='kubectl edit daemonset'
alias kdds='kubectl describe daemonset'
alias kdelds='kubectl delete daemonset'
alias krrds='kubectl rollout restart daemonset'

# CronJob management.
alias kgcj='kubectl get cronjob'
alias kecj='kubectl edit cronjob'
alias kdcj='kubectl describe cronjob'
alias kdelcj='kubectl delete cronjob'
alias kcrcj='kubectl create cronjob'

# Job management.
alias kgj='kubectl get job'
alias kej='kubectl edit job'
alias kdj='kubectl describe job'
alias kdelj='kubectl delete job'
alias kcrcj='kubectl create job'

# Events monitoring.
alias kgev='kubectl get events --sort-by=.metadata.creationTimestamp'
alias kgevall='kubectl get events --sort-by=.metadata.creationTimestamp --all-namespaces'
