FROM ruby:2.3.8-alpine

LABEL PRX <sysadmin@prx.org>
LABEL org.prx.app="yes"
LABEL org.prx.spire.publish.ecr="WEB_SERVER"

RUN apk --no-cache add ca-certificates ruby ruby-irb ruby-json ruby-rake \
    ruby-bigdecimal ruby-io-console libstdc++ tzdata mysql-dev mysql-client \
    linux-headers libc-dev zlib libxml2 libxslt libffi less git groff shared-mime-info

ENV RAILS_ENV production
ENV APP_HOME /app
RUN mkdir -p $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile ./
ADD Gemfile.lock ./
RUN gem install bundler -v 2.3.26

RUN apk --update add --virtual build-dependencies build-base curl-dev libressl-dev \
    zlib-dev libxml2-dev libxslt-dev libffi-dev libgcrypt-dev && \
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

ENTRYPOINT ["./bin/application"]
CMD ["web"]
