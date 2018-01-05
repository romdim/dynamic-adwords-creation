FROM ruby:2.4.1

# Get required packages
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Set up working directory
ENV DIR dac
RUN mkdir /$DIR
WORKDIR /$DIR

# Set up gems
ADD Gemfile ./Gemfile
ADD Gemfile.lock ./Gemfile.lock
RUN gem install bundler
RUN bundle install --jobs 20 --retry 5

# Finally, add the rest of our app's code
ADD ./ ./

EXPOSE 3000

CMD bundle exec puma -C config/puma.rb
