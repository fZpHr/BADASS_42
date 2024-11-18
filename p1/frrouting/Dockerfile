FROM quay.io/frrouting/frr:10.2.0

RUN apk update && apk add busybox

COPY daemons /etc/frr/daemons
COPY frr.conf /etc/frr/frr.conf
COPY start.sh .

RUN chown -R frr:frr /etc/frr && \
    chmod 640 /etc/frr/frr.conf && \
    chmod 640 /etc/frr/daemons && \
    chmod +x start.sh

CMD ["/start.sh"]