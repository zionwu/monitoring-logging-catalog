version: '2'

services:
  cadvisor:
    labels:
      io.rancher.scheduler.global: 'true'
    tty: true
    image: google/cadvisor:v0.28.2
    stdin_open: true
    volumes:
    - "/:/rootfs:ro"
    - "/var/run:/var/run:rw"
    - "/sys:/sys:ro"
    - "/var/lib/docker/:/var/lib/docker:ro"
    network_mode: host
    ports:
    - 0.0.0.0:18080:8080

  node-exporter:
    labels:
      io.rancher.scheduler.global: 'true'
    tty: true
    image: prom/node-exporter:v0.15.1
    stdin_open: true
    network_mode: host
    ports:
    - 0.0.0.0:19100:9100

