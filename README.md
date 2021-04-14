# Full Stack Solution, Swift Vapor + MongoDB behind Traefik Proxy with Let's Encrypt TLS in a Kuerbernetes Cluster with Ceph as Block Storage using Ansible + Terraform + Helm

## Introduction

I want to easily deploy a web app that can scale. Doing this can take a considerable amount of time to do and historically was done with a lot of custom scripts. Over the years tools have been developed to speed up this process and make it more repeatable. I am going to walk through how I decided to put these tools together to get deployment down to roughly 15 minutes. This was my first time learning some of these tools so looking forward to the feedback on building out this stack.
<br/>

## What are the tools:
  - [Ansible](https://www.ansible.com) is a platform that is focused on automation of just about any task. With a huge community, this tool allows you to connect these tasks in complex ways to deliver any type of solution. These tasks can be run on your local computer or a remote server.
  - [Terraform](https://www.terraform.io) is relatively new and is meant to be “Infrastructure as Code”. Instead of defining tasks, you define resources in HCL (HashiCorp Configuration Language) through providers. These resources represent your infrastructure stack.
  - [Kubernetes](https://kubernetes.io) is a cloud based infrastructure that is designed to be able to scale up and down quickly through predefined states. The “cluster” is always working to maintain that state and will create/destroy underlying resources to do so. Within the cluster there are pods that have connected software elements running on a container based process. Multiple containers are connected together in a pod.
  - [Helm](https://helm.sh) is a tool to package up Kubernetes resources and deploy them easily into the cluster. These resources could be a database or an application. 
  - [Docker](https://www.docker.com) is the container solution that is pretty familiar to most at this point. A container usually contains one process. This is the database process or the application process.
  - [MongoDB](https://www.mongodb.com) is the NoSQL database solution that is highly scalable. 
  - [Vapor](https://vapor.codes) is the Server Side Swift platform
  - [Traefik](https://traefik.io) is a modern proxy server that allows for scalability and load balancing. The interface is fairly intuitive and integrates well with Cert Manager.
  - [Let's Encrypt](https://letsencrypt.org) is a non-profit TLS certificate authority that provides https certificates at no cost.
  - [Digital Ocean](https://www.digitalocean.com), who just went public, is a cloud solution provider including managing Domains.
  - [Namecheap](https://www.namecheap.com). This is where I host my Top Level Domain (TLD)
<br/>


## How do they work.
Much like a cake, the order of the ingredients matter. By using each tool for what it does best, I am able to deploy the layers in a repeatable fashion.

- Ansible operates as a general purpose task manager to run terraform.
- Terraform plans and applies resource state. This includes creating the Kuerbenetes cluster on Digital Ocean. I’ve created several resource groups I’ve called “Formations” to build up the infrastructure resources. 
- Each of the ‘Formations uses Helm to deploy a set of Kubernetes resources that have been packaged up into “Charts”. 
- Within the Charts there are Docker images, many of these images are built by either the community of bony the software provider themselves. This is the case with the Mongo database that we will deploy. We will use Docker to package up our own image of the Vapor application for deployment. We will use a sharded mongo database a shared storage infrastructure (Ceph). Traefik will be used with Let’s Encrypt to create a TLS proxy for the application and the Traefik Proxy. This will also be deployed as a Helm Chart.
- What will you learn. In this post you will learn how to package up your vapor application and deploy it behind a proxy server. This will be done using a combination of Ansible, Terraform, Helm, and Docker. The software running will be Mongo DB, Vapor for Backend with Vapor Leaf as the front end and Traefik as the proxy server. We will be deploying on a Digital Ocean Kubernetes Cluster. We will use Let’s Encrypt for TLS management.

## Prerequisites
- A DigitalOcean account. If you do not have one, sign up for a new account.
- A DigitalOcean Personal Access Token, which you can create via the DigitalOcean control panel. Instructions to do that can be found in this link: How to Generate a Personal Access Token.
- A Top Level Domain that is already connected to Digital Ocean. I get mine from Namecheap. I manage the domain through Digital Ocean to make doing things like this easier. Managing the top level domain is outside the scope of this article.
- A Docker Hub account. They are free for what we're going to do.
- Some familiarity with Vapor, MongoDB, and Kubernetes.