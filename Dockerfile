FROM ruby:2.3.7-alpine

MAINTAINER PRX <sysadmin@prx.org>
LABEL org.prx.app="yes"

RUN apk --no-cache add ca-certificates ruby ruby-irb ruby-json ruby-rake \
    ruby-bigdecimal ruby-io-console libstdc++ tzdata mysql-dev mysql-client \
    linux-headers libc-dev zlib libxml2 libxslt libffi less git groff postgresql-client \
    python py-pip py-setuptools && \
    pip --no-cache-dir install awscli

RUN git clone -o github https://github.com/PRX/aws-secrets && \
    cp ./aws-secrets/bin/* /usr/local/bin

ENV TINI_VERSION v0.9.0
ADD https://github.com/krallin/tini/releases/download/${TINI_VERSION}/tini-static /tini
RUN chmod +x /tini

ENV RAILS_ENV production
ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile ./
ADD Gemfile.lock ./
RUN gem install bundler

RUN apk --update add --virtual build-dependencies build-base curl-dev libressl-dev \
    zlib-dev libxml2-dev libxslt-dev libffi-dev libgcrypt-dev postgresql-dev && \
    bundle config --global build.nokogiri  "--use-system-libraries" && \
    bundle config --global build.nokogumbo "--use-system-libraries" && \
    bundle config --global build.ffi  "--use-system-libraries" && \
    bundle install --jobs 10 --retry 10 && \
    apk del build-dependencies && \
    (find / -type f -iname \*.apk-new -delete || true) && \
    rm -rf /var/cache/apk/* && \
    rm -rf /usr/lib/ruby/gems/*/cache/* && \
    rm -rf /tmp/* /var/tmp/* && \
    rm -rf ~/.gem

ADD . ./
RUN chown -R nobody:nogroup /app
USER nobody

ENTRYPOINT ["/tini", "--", "./bin/application"]
CMD ["web"]
