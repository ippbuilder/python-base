FROM debian:jessie
MAINTAINER MOHSEN@IPROPERTY

# Install Python
RUN apt-get update && apt-get install -y --no-install-recommends build-essential curl python python-dev python-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && curl -o pip_installer.py https://bootstrap.pypa.io/get-pip.py \
 && python pip_installer.py \
 && /usr/local/bin/pip -V 

# Install uWSGI
RUN /usr/local/bin/pip install uwsgi flask flask-cors requests pymemcache boto3 phonenumbers pyyaml

# Install pyodbc
RUN apt-get update && apt-get install -y tdsodbc unixodbc-dev \
 && /usr/local/bin/pip install pyodbc
ADD odbcinst.ini /etc/odbcinst.ini

# Standard set up Nginx
ENV NGINX_VERSION 1.9.11-1~jessie

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
 && echo "deb http://nginx.org/packages/mainline/debian/ jessie nginx" >> /etc/apt/sources.list \
 && apt-get update \
 && apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base \
 && rm -rf /var/lib/apt/lists/* \
 # to make docker able to get logs
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log \
 # to make the logs contain the actual source IP
 && sed -i "s/remote_addr/http_x_forwarded_for/g" /etc/nginx/nginx.conf \
 # to make NGINX run on the foreground
 && echo "daemon off;" >> /etc/nginx/nginx.conf
	
EXPOSE 80 443

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
