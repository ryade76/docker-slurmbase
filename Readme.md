# Containerized SLURM Cluster

This was forked from a ancient fork running on Ubuntu 16.04, mods were made, things were fixed, old stuff was probably broken. 

The Docker SLURM cluster is configured with the following software packages:

- Ubuntu 20.04 LTS
- SLURM 21.08.5 

To updater the containter image, use the Dockerfile and change the variables to whatever release you want, it may break some things, so be prepared. Don't forget to update the docker-compose.yml with your new image file after the build!

It runs things simply with supervisord. this compose file should be parsable by https://kompose.io if you wanted to run this on kubernetes, I tried to keep the hard stuff in the container file itself while making sure this could run most anywhere.

You can create and run the configured containers with command `docker-compose up -d`. (from the compose directory)

For a stopping them run `docker-compose down`. 

If you have kubernetes running, go into the compose directory and run the following command: `kubectl apply -k kubernetes`.

**Configuration variables**:

  * `SLURM_CLUSTER_NAME`: the name of the SLURM cluster.
  * `SLURM_CONTROL_MACHINE`: the host name of the controller container. This should match `hostname` in the `slurmctld` section.
  * `SLURM_NODE_NAMES`: the host name of the compute node container. This should match `hostname` in the `slurmd` section.
