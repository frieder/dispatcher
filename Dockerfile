ARG PARENT

FROM ${PARENT}

COPY dispatcher_pid.sh /dispatcher_pid.sh

RUN chown root:root /dispatcher_pid.sh

ENTRYPOINT ["/dispatcher_pid.sh", "/usr/sbin/httpd-foreground"]
