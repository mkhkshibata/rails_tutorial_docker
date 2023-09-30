#!/bin/bash
set -e

# Rails に対応したファイル server.pid が存在しているかもしれないので削除する。
rm -f /rails_tutorial_docker/tmp/pids/server.pid
bundle exec rails assets:clean
bundle exec rails assets:precompile
DISABLE_DATABASE_ENVIRONMENT_CHECK=1 bundle exec rake db:migrate:reset
# bundle exec rake db:seed RAILS_ENV=production

# コンテナーのプロセスを実行する。（Dockerfile 内の CMD に設定されているもの。）
exec "$@"