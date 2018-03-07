FROM alpine:edge
LABEL maintainer="iamcaleberic@tuta.io"
ENV PASSENGER_VERSION="5.2.1" \
    PATH="/lib/passenger/bin:$PATH" \
    HOME="/home/app"

# create app user
RUN adduser -h /home/app -G root -D app

RUN PACKAGES="ca-certificates ruby procps curl pcre libstdc++ libexecinfo ruby-bundler ruby-dev ruby-etc ruby-rake mariadb-dev ruby-rdoc libpng nodejs yarn ruby-bigdecimal" && \
    GEM_PACKAGES="build-base ruby-rdoc libpng-dev git libffi-dev sqlite-dev libpng-dev pngquant" && \
    BUILD_PACKAGES="linux-headers curl-dev pcre-dev libexecinfo-dev zlib" && \
    apk update && apk add --update $PACKAGES $BUILD_PACKAGES $GEM_PACKAGES && \
# download and extract
    curl -L https://s3.amazonaws.com/phusion-passenger/releases/passenger-$PASSENGER_VERSION.tar.gz | tar -xzvf - -C /lib && \
    mv /lib/passenger-$PASSENGER_VERSION /lib/passenger && \
# install nginx module
    gem install rack && \
    passenger-install-nginx-module --auto --auto-download --prefix=/etc/nginx --languages 'ruby,nodejs' && \
# Cleanup
    passenger-config validate-install --auto && \
    apk del $BUILD_PACKAGES && \
    rm -rf /var/cache/apk/* \
        /tmp/* \
        /lib/passenger/doc/ && \
# Add nginx config
    mkdir /etc/nginx/conf/sites-available && \
    mkdir /etc/nginx/conf/sites-enabled

COPY lib/nginx.conf /etc/nginx/conf/nginx.conf

WORKDIR /home/app
EXPOSE 80

CMD ["sh", "-c","passenger start --nginx-bin /etc/nginx/sbin/nginx  --port 80"]
