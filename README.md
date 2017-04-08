# Distributed Service Configuration with Consul, Spring Cloud, and Docker

_Project In Progress..._

## Introduction

This repository has been developed for the post, '[Distributed Service Configuration with Consul, Spring Cloud, and Docker](http://wp.me/p1RD28-36b)'. The post explore the use of HashiCorp Consul for distributed configuration of containerized Spring Boot microservices, deployed to a Docker swarm cluster.

In the first half of the post, we provision a series of VMs, build a Docker swarm cluster on top of those VMs, and install Consul and Registrator on each swarm host. In the second half of the post, we configure and deploy multiple, containerized instances of a Spring Boot microservice, backed by MongoDB, to the swarm cluster, using Docker Compose version 3. The final objective of the post is have all the deployed services registered with Consul, via Registrator, and the Spring Boot service's configuration being provided dynamically by Consul, at service startup.

### Objectives

1. Provision a series of virtual machine hosts, using Docker Machine and Oracle VirtualBox
2. Provide distributed and highly available cluster management and service orchestration, using Docker swarm mode
3. Provide distributed and highly available service discovery, health checking, and a hierarchical key/value store, using HashiCorp Consul
4. Provide automatic service registration of containerized services using Registrator, Glider Labs' service registry bridge for Docker
5. Provide distributed configuration for containerized services using Consul and Pivotal's Spring Cloud Consul Config
6. Provide centralized logging for containerized services using FluentD and ELK.
7. Deploy multiple instances of a containerized Spring Boot microservice, backed by MongoDB, to the swarm cluster, using Docker Compose version 3.

### Technologies

- Docker
- Docker Compose (v3)
- Docker Hub
- Docker Machine
- Docker swarm mode
- Docker Swarm Visualizer (Mano Marks)
- ELK Stack
- FluentD
- Glider Labs Registrator
- Gradle
- HashiCorp Consul
- Java 8
- MongoDB
- Oracle VirtualBox VM Manager
- Spring Boot
- Spring Cloud Consul Config
- Travis CI

### Cloning the Project

To clone the GitHub project:

```bash
# clone the directory
git clone --depth 1 --branch fluentd \
  https://github.com/garystafford/microservice-docker-demo-consul.git
cd microservice-docker-demo-consul
```

### Project Scripts

#### Stand-Up Project

1. vms_create.sh
2. swarm_create.sh
3. ntwk_vols_create.sh
4. consul_deploy.sh
5. registrator_ deploy.sh
6. stack_deploy.sh

#### Utility Scripts

1. swarm_remove_contents.sh

#### Teardown Project

1. swarm_remove_contents.sh
2. swarm_remove.sh
3. vms_ delete.sh
