# syntax = docker/dockerfile:1
ARG RUBY_VERSION=3.2.11
FROM ruby:$RUBY_VERSION-slim

# 作業ディレクトリを開発用に変更
WORKDIR /app

# 必要パッケージ
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      curl libjemalloc2 libvips postgresql-client build-essential git libpq-dev libyaml-dev pkg-config && \
    rm -rf /var/lib/apt/lists/*

# 環境変数（開発用ならdevelopmentでもOK）
ENV RAILS_ENV=development \
    SECRET_KEY_BASE=dummy \
    BUNDLE_PATH=/usr/local/bundle

# Gemのインストール
COPY Gemfile Gemfile.lock ./
RUN bundle install

# アプリコードをコピー（volumeで上書きされる想定）
COPY . .

# サーバー起動
EXPOSE 3000
CMD ["bin/rails", "server", "-b", "0.0.0.0"]