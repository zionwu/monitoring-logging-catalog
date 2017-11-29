version: '2'
services:  
  prometheus-data:
    tty: true
    stdin_open: true
    image: registry.cn-hangzhou.aliyuncs.com/zionwu/prom-init:v0.0.1
    volumes:
      - /etc/prometheus
      - /etc/prometheus-rules
      - prometheus-data:/prometheus
    network_mode: none
    command: chmod -R 777 /prometheus /etc/prometheus /etc/prometheus-rules
    labels:
      io.rancher.container.start_once: true

  prometheus:
    tty: true
    stdin_open: true
    image: prom/prometheus:v2.0.0
    command: --config.file=/etc/prometheus/prometheus.yml --web.enable-lifecycle --storage.tsdb.path=/prometheus
    network_mode: host
    labels:
      io.rancher.sidekicks: prometheus-data
    volumes_from:
      - prometheus-data
    extra_hosts:
      - "rancher-server:{{  .Values.RANCHER_SERVER }}"
    links:
    - alertmanager:alertmanager

  alertmanager-data:
    tty: true
    stdin_open: true
    image: registry.cn-hangzhou.aliyuncs.com/zionwu/alertmanager-init:v0.0.1
    volumes:
      - /etc/alertmanager
      - /etc/alertmanager-templates
      - alertmanager-data:/alertmanager
    network_mode: none
    command: chmod 777 /alertmanager
    labels:
      io.rancher.container.start_once: true

  alertmanager:
    tty: true
    stdin_open: true
    image: prom/alertmanager:v0.11.0
    command:  -config.file=/etc/alertmanager/config.yml -storage.path=/alertmanager
    network_mode: host
    labels:
      io.rancher.sidekicks: alertmanager-data
    volumes_from:
      - alertmanager-data

  graf-db:
    tty: true
    stdin_open: true
    image: infinityworks/graf-db:11
    command: cat
    volumes:
      - /var/lib/grafana/
    network_mode: none

  grafana:
    tty: true
    stdin_open: true
    image: grafana/grafana:4.2.0
    ports:
      - 3000:3000
    labels:
      io.rancher.sidekicks: graf-db
    volumes_from:
       - graf-db
    links:
      - prometheus:prometheus
