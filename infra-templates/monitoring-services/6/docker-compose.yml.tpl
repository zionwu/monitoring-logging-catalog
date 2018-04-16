version: '2'

services:
  cadvisor:
    labels:
      io.rancher.scheduler.global: 'true'
    tty: true
    image: google/cadvisor:v0.28.3
    stdin_open: true
    volumes:
    - "/:/rootfs:ro"
    - "/var/run:/var/run:rw"
    - "/sys:/sys:ro"
    - "/var/lib/docker/:/var/lib/docker:ro"
    command: --port={{  .Values.CADVISOR_PORT }}
    network_mode: host

  node-exporter:
    labels:
      io.rancher.scheduler.global: 'true'
    tty: true
    image: prom/node-exporter:v0.14.0
    stdin_open: true
    command: --web.listen-address=":{{  .Values.NODE_EXPORTER_PORT }}"
    network_mode: host

  rancher-health-exporter:
    tty: true
    labels:
      io.rancher.container.create_agent: 'true'
      io.rancher.container.agent.role: environment
    image: maiwj/rancher1.x-exporter:2.1.1
    ports:
    - {{  .Values.RANCHER_EXPORTER_PORT }}:9173

  


