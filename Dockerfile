FROM debian:11.3-slim

ENV LANG C.UTF-8

LABEL maintainer="Renato Gomes <renatogomessilverio@gmail.com>"

WORKDIR /APP

COPY ./install_force.sh /tmp

RUN cd /tmp/ && chmod +x install_force.sh && bash -c "/tmp/install_force.sh" && \
    rm -rf /var/lib/apt/lists/* && \ 
    apt-get clean autoclean && \
    apt-get autoremove --yes && \
    rm -rf /var/lib/{apt,dpkg,cache,log}/
