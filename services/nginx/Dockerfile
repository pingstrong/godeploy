ARG NGINX_VERSION
FROM nginx:${NGINX_VERSION}

ARG TZ
ARG NGINX_VERSION
ARG CONTAINER_PACKAGE_URL
ARG NGINX_INSTALL_APPS

ENV INSTALL_APPS=",${NGINX_INSTALL_APPS},"

RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN if [ "${CONTAINER_PACKAGE_URL}" != "" ]; then \
        sed -i "s/dl-cdn.alpinelinux.org/${CONTAINER_PACKAGE_URL}/g" /etc/apk/repositories; \
    fi

RUN if [ -z "${INSTALL_APPS##*,certbot,*}" ]; then \
        echo "---------- Install certbot ----------"; \
        #apk add python3 python3-dev py3-pip build-base libressl-dev musl-dev libffi-dev \
        #pip3 install pip --upgrade \
        #pip3 install certbot-nginx \
        apk --update add --no-cache certbot certbot-nginx; \
    fi

WORKDIR /www
