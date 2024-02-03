FROM --platform=linux/amd64 ubuntu:22.04

COPY . /os

WORKDIR /os

RUN apt-get update && \
    apt-get install -y build-essential binutils gdb neofetch