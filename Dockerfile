ARG PARENT

FROM ${PARENT}

RUN apk add -U tzdata

COPY sdk/lib /usr/lib/dispatcher-sdk
COPY sdk/lib/import_sdk_config.sh /docker_entrypoint.d/zzz-import-sdk-config.sh
COPY sdk/lib/overwrite_cache_invalidation.sh /docker_entrypoint.d/zzz-overwrite_cache_invalidation.sh
COPY sdk/lib/httpd-reload-monitor /usr/sbin/httpd-reload-monitor
COPY sdk/bin/validator-linux-amd64 /usr/sbin/validator

COPY dispatcher_pid.sh /dispatcher_pid.sh

RUN chown root:root /dispatcher_pid.sh

ENTRYPOINT ["/dispatcher_pid.sh", "/usr/sbin/httpd-foreground"]
