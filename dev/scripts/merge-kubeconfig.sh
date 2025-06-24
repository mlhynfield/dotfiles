#!/bin/bash

# Ensure a target kubeconfig file is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <target-kubeconfig>"
    exit 1
fi

target_kubeconfig=$1

# Backup the original KUBECONFIG
KUBECONFIGBAK=$KUBECONFIG
export KUBECONFIG=$target_kubeconfig:~/.kube/config

# Ensure the .kube directory exists
mkdir -p ~/.kube

# Merge the kubeconfig files
kubectl config view --merge --flatten > ~/.kube/merged

# Replace the main kubeconfig with the merged file
mv -f ~/.kube/merged ~/.kube/config
chmod 0600 ~/.kube/config

# Restore the original KUBECONFIG
export KUBECONFIG=$KUBECONFIGBAK
unset KUBECONFIGBAK

echo "Kubeconfig files merged successfully."
