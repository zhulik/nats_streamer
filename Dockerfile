FROM ruby:3.2.0-slim as base

WORKDIR /mnt

RUN adduser --system app &&\
  bundle config --local path vendor/bundle &&\
  bundle config set --local deployment 'true' &&\
  bundle config set --local without 'development test'

RUN apt-get update &&\
  apt-get install -qy --no-install-recommends git


FROM base as builder

RUN apt-get update &&\
  apt-get install -qy --no-install-recommends build-essential

COPY Gemfile Gemfile.lock ./
RUN bundle install

FROM base

COPY --from=builder /mnt .

ADD . .

USER app

CMD ["bundle", "exec", "./exe/nats_streamer", "/config.yaml"]
