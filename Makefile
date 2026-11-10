.PHONY: setup up down migrate seed test lint logs

setup:
	docker compose build
	docker compose run --rm api bundle exec bin/rails db:prepare
	docker compose run --rm api bundle exec bin/rails db:seed

up:
	docker compose up -d

down:
	docker compose down

migrate:
	docker compose run --rm api bundle exec bin/rails db:migrate

seed:
	docker compose run --rm api bundle exec bin/rails db:seed

test:
	docker compose run --rm api bundle exec rspec
	docker compose run --rm web npm run test -- --run

lint:
	docker compose run --rm api bundle exec rubocop
	docker compose run --rm api bundle exec brakeman --no-pager
	docker compose run --rm web npm run typecheck
	docker compose run --rm web npm run lint

logs:
	docker compose logs -f --tail=200
