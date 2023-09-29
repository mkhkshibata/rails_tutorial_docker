FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y build-essential nodejs postgresql-client
RUN mkdir /rails_tutorial_docker
WORKDIR /rails_tutorial_docker
COPY Gemfile /rails_tutorial_docker/Gemfile
COPY Gemfile.lock /rails_tutorial_docker/Gemfile.lock

ENV RAILS_ENV="production"
RUN bundle install
RUN bundle exec rails db:create
RUN bundle exec rails db:migrate:reset
RUN bundle exec rails db:seed
# RUN bundle exec rails assets:clean
# RUN bundle exec rails assets:precompile
COPY . /rails_tutorial_docker

# コンテナー起動時に毎回実行されるスクリプトを追加
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 3000

# イメージ実行時に起動させる主プロセスを設定
CMD ["rails", "server", "-e", "production", "-b", "0.0.0.0"]
# CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]