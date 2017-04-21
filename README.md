# Distributed Service Configuration with Consul, Spring Cloud, and Docker

## Introduction

This repository has been developed for the posts, [Distributed Service Configuration with Consul, Spring Cloud, and Docker](http://wp.me/p1RD28-36b) and [Streaming Docker Logs to the Elastic Stack using Fluentd](http://wp.me/p1RD28-3B3). The first post explores the use of HashiCorp Consul for distributed configuration of containerized Spring Boot microservices, deployed to a Docker swarm cluster. The second post adds the use of Fluentd for streaming Docker logs to the Elastic Stack.

In the first half of the post, we provision a series of VMs, build a Docker swarm cluster on top of those VMs, and install Consul and Registrator on each swarm host. In the second half of the post, we configure and deploy multiple, containerized instances of a Spring Boot microservice, backed by MongoDB, to the swarm cluster, using Docker Compose version 3. The final objective of the post is have all the deployed services registered with Consul, via Registrator, and the Spring Boot service's configuration being provided dynamically by Consul, at service startup.

In the second post, we use Fluentd to stream Docker logs from our containerized Spring Boot service instances and MongoDB, to the Elastic Stack. Fluentd and Docker’s native logging driver for Fluentd makes it easy to stream Docker logs from multiple running containers to the Elastic stack.

### Objectives

1. Provision a series of virtual machine hosts, using Docker Machine and Oracle VirtualBox
2. Provide distributed and highly available cluster management and service orchestration, using Docker swarm mode
3. Provide distributed and highly available service discovery, health checking, and a hierarchical key/value store, using HashiCorp Consul
4. Provide automatic service registration of containerized services using Registrator, Glider Labs' service registry bridge for Docker
5. Provide distributed configuration for containerized services using Consul and Pivotal's Spring Cloud Consul Config
6. Provide centralized logging for containerized services using FluentD and the Elastic Stack (aka ELK)
7. Deploy multiple instances of a containerized Spring Boot microservice, backed by MongoDB, to the swarm cluster, using Docker Compose version 3.

### Technologies

- Docker
- Docker Compose (v3)
- Docker Hub
- Docker Machine
- Docker swarm mode
- Docker Swarm Visualizer (Mano Marks)
- Elastic Stack (aka ELK)
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
```

### Project Scripts

#### Stand-Up Project

```bash
cd microservice-docker-demo-consul/scripts/
sh ./run_all.sh # single uber-script

# alternately, run the individual scripts
sh ./vms_create.sh # creates vms using docker machine
sh ./swarm_create.sh # creates the swarm
sh ./ntwk_vols_create.sh # creates overlay network and volumes
sh ./consul_deploy.sh # deploys consul to all nodes
sh ./registrator_deploy.sh # deploys registrator
sh ./stack_deploy.sh # deploys fluentd, visualizer, elastic stack
sh ./stack_validate.sh # waits/tests for all containers to start```

#### Utility Scripts

```bash
sh ./swarm_remove_contents.sh # prune docker system components
```
#### Teardown Project

```bash
sh ./swarm_remove_contents.sh # prune docker system components
sh ./swarm_remove.sh # remove swarm from vms
sh./vms_ delete.sh # delete all vms
```
