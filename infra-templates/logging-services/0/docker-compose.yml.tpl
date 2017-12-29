version: '2'
services:
  logging-agent:
    privileged: true
    image: monlog/logging-es:v0.3.1.3
    pid: host
    {{- if eq .Values.log_driver "journald" }}
    command:
    - fluentd
    - -c
    - /fluentd/etc/fluent-journald.conf
    volumes:
    - /run/log/journal:/run/log/journal
    {{- end }}
    volumes_from:
    - logging-helper
    labels:
      io.rancher.container.pull_image: always
      io.rancher.scheduler.global: 'true'
      io.rancher.sidekicks: logging-helper
    logging:
      driver: json-file
      options:
        max-size: 25m
        max-file: '2'
  logging-helper:
    privileged: true
    image: monlog/logging-helper:v0.3.0
    environment:
      LOG_VOL_PATTERN: '${log_vol_pattern}'
      LOG_FILE_PATTERN: '${log_file_pattern}'
    volumes:
    - /var/lib/docker:/var/lib/docker
    - /var/log/logging-volumes:/var/log/logging-volumes
    - /var/log/logging-containers:/var/log/logging-containers
    - /var/run/docker.sock:/var/run/docker.sock
    pid: host
    labels:
      io.rancher.container.pull_image: always
    logging:
      driver: json-file
      options:
        max-size: 25m
        max-file: '2'
  elasticsearch:
    image: rancher/external-service
    {{- if eq .Values.elasticsearch_address_type "hostname"}}
    hostname: ${elasticsearch_address}
    {{- else}}
    external_ips:
    - ${elasticsearch_address}
    {{- end }}