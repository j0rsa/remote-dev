FROM ubuntu:21.04

LABEL MAINTAINER="red<red.avtovo@gmail.com>"

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server git sudo
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/g' /etc/ssh/sshd_config

EXPOSE 22
COPY entrypoint.sh /root
ENTRYPOINT "/root/entrypoint.sh"
