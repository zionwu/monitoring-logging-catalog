version: '2'
services:
  monitoring-manager:
    tty: true
    stdin_open: true
    image: monlog/monitoring-manager:v0.0.10
    volumes:
      - prometheus-config:/etc/prometheus
      - prometheus-rule:/etc/prometheus-rules
      - prometheus-data:/prometheus
      - alertmanager-config:/etc/alertmanager 
    environment:
      CATTLE_URL: "http://{{  .Values.RANCHER_SERVER_IP }}:{{  .Values.RANCHER_SERVER_PORT }}"
      CATTLE_ACCESS_KEY: {{  .Values.CATTLE_ACCESS_KEY }}
      CATTLE_SECRET_KEY:  {{  .Values.CATTLE_SECRET_KEY }}
      CADVISOR_PORT:  {{  .Values.CADVISOR_PORT }}
      NODE_EXPORTER_PORT: {{  .Values.NODE_EXPORTER_PORT }}
      RANCHER_EXPORTRT_PORT: {{  .Values.RANCHER_EXPORTER_PORT }}
    ports:
      - {{ .Values.MANAGER_PORT  }}:8888/tcp

  prometheus-data:
    tty: true
    stdin_open: true
    image: monlog/prom-init:v0.0.1
    volumes:
      - prometheus-config:/etc/prometheus
      - prometheus-rule:/etc/prometheus-rules
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
      io.rancher.container.dns: 'true'
    volumes_from:
      - prometheus-data
    extra_hosts:
      - "rancher-server:{{  .Values.RANCHER_SERVER_IP }}"
    links:
    - alertmanager:alertmanager

  alertmanager-data:
    tty: true
    stdin_open: true
    image: monlog/alertmanager-init:v0.0.1
    volumes:
      - alertmanager-config:/etc/alertmanager
      - alertmanager-template:/etc/alertmanager-templates
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
    image: monlog/grafana-db:v0.0.3
    command: cat
    volumes:
      - /var/lib/grafana/
    network_mode: none

  grafana:
    environment:
      GF_USERS_DEFAULT_THEME: light
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
