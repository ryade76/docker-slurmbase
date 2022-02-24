# Containerized SLURM Cluster

This was forked from a ancient fork running on Ubuntu 16.04, mods were made, things were fixed, old stuff was probably broken. 

The Docker SLURM cluster is configured with the following software packages:

- Ubuntu 20.04 LTS
- SLURM 21.08.5 

It runs things simply with supervisord if you run locally, this compose file should be parsable by https://kompose.io if you wanted to run this on kubernetes, I tried to keep the hard stuff in the container file itself while making sure this could run most anywhere.

version: '2'

services:
  slurmctld:
    container_name: slurmctld
    environment:
      SLURM_CLUSTER_NAME: ikimslurm
      SLURM_CONTROL_MACHINE: slurmctld
      SLURM_NODE_NAMES: slurmd
    tty: true
    hostname: slurmctld
    networks:
      default:
        aliases:
          - slurmctld
    image: ryade/slurmbase
    stdin_open: true
  slurmd:
    container_name: slurmd
    environment:
      SLURM_CONTROL_MACHINE: slurmctld
      SLURM_CLUSTER_NAME: ikimslurm
      SLURM_NODE_NAMES: slurmd
    tty: true
    hostname: slurmd
    networks:
      default:
        aliases:
          - slurmd
    image: ryade/slurmbase
    depends_on:
      - slurmctld
    stdin_open: true

You can create and run the configured containers with command `docker-compose up -d`. (from the compose directory)

For a stopping them run `docker-compose down`. 

**Configuration variables**:

  * `SLURM_CLUSTER_NAME`: the name of the SLURM cluster.
  * `SLURM_CONTROL_MACHINE`: the host name of the controller container. This should match `hostname` in the `slurmctld` section.
  * `SLURM_NODE_NAMES`: the host name of the compute node container. This should match `hostname` in the `slurmd` section.
