#!/bin/bash

urlserver=   # http://grafana.ndd:3100/loki/api/v1/push
host=$(hostname)

cd /bin
curl -fSL -o promtail.gz "https://github.com/grafana/loki/releases/download/v1.6.1/promtail-linux-amd64.zip"
gunzip promtail.gz
chmod a+x promtail

cd /etc
mkdir promtail
cd promtail

echo "server:
  http_listen_port: 9080
  grpc_listen_port: 0

positions:
  filename: /tmp/positions.yaml

clients:
  - url: $urlserver

scrape_configs:
  - job_name: journal
    journal:
      max_age: 12h
      labels:
        host: \"$host\"
        job: systemd-journal
        service: systemd-journal
    relabel_configs:
      - source_labels: ['__journal__systemd_unit']
        target_label: 'unit'

  - job_name: varlog
    static_configs:
    - targets:
        - localhost
      labels:
        host: \"$host\"
        job: varlogs
        service: system
        __path__: /var/log/*log
        " > config-promtail.yml

      useradd --system promtail
      echo "[Unit]
Description=Promtail service
After=network.target

[Service]
Type=simple
User=promtail
ExecStart=/bin/promtail -config.file /etc/promtail/config-promtail.yml

[Install]
WantedBy=multi-user.target
" > /etc/systemd/system/promtail.service

systemctl enable promtail.service
systemctl start promtail
systemctl status promtail
