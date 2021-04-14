FROM ubuntu:20.04

RUN DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
  && apt-get -q update \
  && apt-get -q dist-upgrade -y \
  && apt-get install -y \
  sudo openssh-server wget curl unzip \
  apt-transport-https ca-certificates \
  software-properties-common snapd \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -m -p --disabled-password --user-group --create-home --comment "" -s /bin/bash ansible

RUN usermod -aG sudo ansible

RUN su ansible

RUN sudo apt-get -q update && \
    sudo apt-add-repository --yes --update ppa:ansible/ansible && \
    sudo apt-get install -y ansible

RUN ansible-galaxy collection install community.general

RUN /bin/echo -e "[local]\nlocalhost ansible_connection=local" > /etc/ansible/hosts ;\
  ssh-keygen -q -t ed25519 -N '' -f /root/.ssh/id_ed25519 ;\
  mkdir -p ~/.ssh && echo "Host *" > ~/.ssh/config && echo " StrictHostKeyChecking no" >> ~/.ssh/config

RUN wget https://github.com/digitalocean/doctl/releases/download/v1.58.0/doctl-1.58.0-linux-amd64.tar.gz && \
    tar xf doctl-1.58.0-linux-amd64.tar.gz && \
    sudo mv doctl /usr/local/bin

RUN sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list && \
  sudo apt-get update && \
  sudo apt-get install -y kubectl

RUN wget https://get.helm.sh/helm-v3.5.3-linux-amd64.tar.gz && \
  tar xf helm-v3.5.3-linux-amd64.tar.gz && \
  ls -alF && \
  sudo mv linux-amd64/helm /usr/local/bin

RUN sudo wget https://releases.hashicorp.com/terraform/0.14.7/terraform_0.14.7_linux_amd64.zip && \
  sudo unzip terraform_0.14.7_linux_amd64.zip && \
  sudo mv terraform /usr/local/bin/
