#!/bin/bash
touch /etc/frr/vtysh.conf && \
chown frr:frr /etc/frr/vtysh.conf && \
chmod 640 /etc/frr/vtysh.conf && \
/usr/lib/frr/frrinit.sh start && \
/bin/bash