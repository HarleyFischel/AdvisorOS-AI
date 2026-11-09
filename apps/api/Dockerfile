FROM ruby:3.3.6-slim
RUN apt-get update -qq && apt-get install -y --no-install-recommends build-essential libpq-dev curl && rm -rf /var/lib/apt/lists/*
WORKDIR /app
COPY Gemfile Gemfile.lock* ./
RUN bundle install
COPY . .
RUN useradd --create-home appuser && chown -R appuser:appuser /app
USER appuser
EXPOSE 3000
CMD ["bundle", "exec", "bin/rails", "server", "-b", "0.0.0.0"]
