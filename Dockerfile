FROM ubuntu:20.04
MAINTAINER Ryan Aydelott <ryan.aydelott@uk-essen.de>

ENV SLURM_VER=21.08.5

ARG DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

# Create users, set up SSH keys (for MPI)
RUN useradd -u 2001 -d /home/slurm slurm
RUN useradd -u 6000 -ms /bin/bash ikimslurm
ADD etc/sudoers.d/ikimslurm /etc/sudoers.d/ikimslurm
ADD home/ikimslurm/ssh/config /home/ikimslurm/.ssh/config
ADD home/ikimslurm/ssh/id_rsa /home/ikimslurm/.ssh/id_rsa
ADD home/ikimslurm/ssh/id_rsa.pub /home/ikimslurm/.ssh/id_rsa.pub
ADD home/ikimslurm/ssh/authorized_keys /home/ikimslurm/.ssh/authorized_keys
RUN chown -R ikimslurm:ikimslurm /home/ikimslurm/.ssh/
RUN chmod 400 /home/ikimslurm/.ssh/*

# Install packages
RUN apt-get update && apt-get -y  dist-upgrade
RUN apt-get install -y munge curl gcc make bzip2 supervisor python python-dev \
    libmunge-dev libmunge2 lua5.3 lua5.3-dev libopenmpi-dev openmpi-bin \
    gfortran vim python3-mpi4py python-numpy python-psutil sudo psmisc \
    software-properties-common iputils-ping \
    openssh-server openssh-client \
    automake autoconf unzip \ 
    libgtk2.0-dev libglib2.0-dev \
    libhdf5-dev \
    libcurl4-openssl-dev


# Download, compile and install SLURM
RUN curl -fsL http://download.schedmd.com/slurm/slurm-${SLURM_VER}.tar.bz2 | tar xfj - -C /opt/ && \
    cd /opt/slurm-${SLURM_VER}/ && \
    ./configure --with-libcurl && \
    make && make install
ADD etc/slurm/slurm.conf /usr/local/etc/slurm.conf
ADD etc/supervisord.d/slurmctld.conf /etc/supervisor/conf.d/slurmctld.conf
ADD etc/supervisord.d/slurmd.conf /etc/supervisor/conf.d/slurmd.conf

# Configure OpenSSH
# Also see: https://docs.docker.com/engine/examples/running_ssh_service/
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN mkdir /var/run/sshd
RUN echo 'ikimslurm:ikimslurm' | chpasswd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ADD etc/supervisord.d/sshd.conf /etc/supervisor/conf.d/sshd.conf

# Configure munge (for SLURM authentication)
ADD etc/munge/munge.key /etc/munge/munge.key
RUN mkdir /var/run/munge && \
    chown root /var/lib/munge && \
    chown root /etc/munge && chmod 600 /var/run/munge && \
    chmod 755  /run/munge && \
    chmod 600 /etc/munge/munge.key
ADD etc/supervisord.d/munged.conf /etc/supervisor/conf.d/munged.conf

ADD scripts/start.sh /root/start.sh
RUN chown root /root/start.sh && \
    chmod 755 /root/start.sh

ENTRYPOINT ["bash", "/root/start.sh"]

EXPOSE 22
