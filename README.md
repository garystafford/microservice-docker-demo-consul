# Distributed Service Configuration with Consul, Spring Cloud, and Docker

_Project In Progress..._

## Introduction

This repository has been developed for the post, '[Distributed Service Configuration with Consul, Spring Cloud, and Docker](https://programmaticponderings.com/2017/02/28/distributed-service-configuration-with-consul-spring-cloud-and-docker-2/)'. The post explore the use of HashiCorp Consul for distributed configuration of containerized Spring Boot microservices, deployed to a Docker swarm cluster.

In the first half of the post, we provision a series of VMs, build a Docker swarm cluster on top of those VMs, and install Consul and Registrator on each swarm host. In the second half of the post, we configure and deploy multiple, containerized instances of a Spring Boot microservice, backed by MongoDB, to the swarm cluster, using Docker Compose version 3. The final objective of the post is have all the deployed services registered with Consul, via Registrator, and the Spring Boot service's configuration being provided dynamically by Consul, at service startup.

### Objectives

1. Provision a series of virtual machine hosts, using Docker Machine and Oracle VirtualBox
2. Provide distributed and highly available cluster management and service orchestration, using Docker swarm mode
3. Provide distributed and highly available service discovery, health checking, and a hierarchical key/value store, using HashiCorp Consul
4. Provide service registration of containerized services, using Registrator, Glider Labs' service registry bridge for Docker
5. Provide distributed configuration for containerized Spring Boot microservices using Consul and Pivotal's Spring Cloud Consul Config
6. Deploy multiple instances of a Spring Boot microservice, backed by MongoDB, to the swarm cluster, using Docker Compose version 3.

### Technologies

- Docker
- Docker Compose (v3)
- Docker Hub
- Docker Machine
- Docker swarm mode
- Docker Swarm Visualizer (Mano Marks)
- Glider Labs Registrator
- Gradle
- HashiCorp Consul
- Java
- MongoDB
- Oracle VirtualBox VM Manager
- Spring Boot
- Spring Cloud Consul Config
- Travis CI

### Cloning the Project

To clone the GitHub project:

```bash
# clone the directory
git clone --depth 1 --branch swarm-mode \
  https://github.com/garystafford/microservice-docker-demo-consul.git
cd microservice-docker-demo-consul
```

### Project Scripts

#### Stand-Up Project

1. create_vms.sh
2. create_swarm.sh
3. deploy_visualizer.sh
4. deploy_consul.sh
5. deploy_registrator.sh

#### Utility Scripts

1. remove_unused_images.sh

#### Teardown Project

1. cleanup_swarm.sh
2. leave_swarm.sh
