#!/bin/bash
set -e

# Rails に対応したファイル server.pid が存在しているかもしれないので削除する。
rm -f /rails_tutorial_docker/tmp/pids/server.pid
bundle exec rake assets:clean
bundle exec rake assets:precompile

# コンテナーのプロセスを実行する。（Dockerfile 内の CMD に設定されているもの。）
exec "$@"