FROM ruby:3.2.2
RUN apt-get update -qq && apt-get install -y build-essential nodejs postgresql-client
RUN mkdir /rails_tutorial_docker
WORKDIR /rails_tutorial_docker
COPY Gemfile /rails_tutorial_docker/Gemfile
COPY Gemfile.lock /rails_tutorial_docker/Gemfile.lock
RUN bundle install
COPY . /rails_tutorial_docker

# コンテナー起動時に毎回実行されるスクリプトを追加
COPY entrypoint.sh /usr/bin/
RUN chmod +x /usr/bin/entrypoint.sh
ENTRYPOINT ["entrypoint.sh"]
EXPOSE 8080