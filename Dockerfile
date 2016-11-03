FROM debian:jessie
MAINTAINER MOHSEN@IPROPERTY

# Install Python
RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        python \
        python-dev \
        python-pip \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Install uWSGI
RUN pip install uwsgi flask requests

# Standard set up Nginx
ENV NGINX_VERSION 1.9.11-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base \
	&& rm -rf /var/lib/apt/lists/*
# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stderr /var/log/nginx/error.log
EXPOSE 80 443
# Finished setting up Nginx

# Make NGINX run on the foreground
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
# Copy the modified Nginx conf
COPY nginx.conf /etc/nginx/conf.d/default.conf
# Copy the base uWSGI ini file to enable default dynamic uwsgi process number
COPY uwsgi.ini /etc/uwsgi/

# Install Supervisord
RUN apt-get update && apt-get install -y supervisor \
&& rm -rf /var/lib/apt/lists/*

# Custom Supervisord config
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf

CMD ["/usr/bin/supervisord"]
