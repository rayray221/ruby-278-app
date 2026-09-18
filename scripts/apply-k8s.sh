#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "$0")/.." && pwd)"
IMAGE="${IMAGE:-ruby-278-app:latest}"
IMAGE_PULL_POLICY="${IMAGE_PULL_POLICY:-IfNotPresent}"

kubectl kustomize "${root}/k8s" \
  | sed "s|image: ruby-278-app:latest|image: ${IMAGE}|g" \
  | sed "s|imagePullPolicy: IfNotPresent|imagePullPolicy: ${IMAGE_PULL_POLICY}|g" \
  | kubectl apply -f -
