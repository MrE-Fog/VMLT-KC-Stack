#!/usr/bin/env sh

export ANSIBLE_CONFIG=./orchestration/ansible.cfg
ansible-playbook -v orchestration/strategy.yaml -e operation=$1 -e env=$2