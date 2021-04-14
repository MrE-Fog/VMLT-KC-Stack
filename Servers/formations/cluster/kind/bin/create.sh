#!/usr/bin/env bash

kind create cluster --name "thecb4-k8s" --config kind-config.yaml
kind get kubeconfig --name thecb4-k8s > kubeconfig.yaml