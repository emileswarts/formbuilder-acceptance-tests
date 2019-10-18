setup: .publisher .runner .submitter .av .token-cache .test-form .datastore .filestore .pdf-generator

.filestore:
	git clone git@github.com:ministryofjustice/fb-user-filestore.git .filestore

.datastore:
	git clone git@github.com:ministryofjustice/fb-user-datastore.git .datastore

.publisher:
	git clone git@github.com:ministryofjustice/fb-publisher.git .publisher

.runner:
	git clone git@github.com:ministryofjustice/fb-runner-node.git .runner

.submitter:
	git clone git@github.com:ministryofjustice/fb-submitter.git .submitter

.av:
	git clone git@github.com:ministryofjustice/fb-av.git .av

.token-cache:
	git clone git@github.com:ministryofjustice/fb-service-token-cache .token-cache

.test-form:
	git clone git@github.com:ministryofjustice/fb-hmcts-complaints.git .test-form

.test-runner:
	git clone git@github.com:ministryofjustice/claim-for-costs-of-a-childs-funeral.git .test-form

.pdf-generator:
	git clone git@github.com:ministryofjustice/fb-pdf-generator.git .pdf-generator

destroy: .publisher .runner .submitter .av .token-cache .test-form .datastore .filestore .pdf-generator
	docker-compose down

stop:
	docker-compose down

build: setup
	echo HEAD > .runner/APP_SHA
	docker-compose build --build-arg BUNDLE_FLAGS='' --build-arg BUNDLE_ARGS='' --parallel

serve: build
	docker-compose up -d publisher-db submitter-db datastore-db
	docker-compose up -d publisher-redis
	./scripts/wait_for_db datastore-db postgres && ./scripts/wait_for_db publisher-db postgres && ./scripts/wait_for_db submitter-db postgres
	docker-compose up -d submitter-app publisher-app publisher-worker runner-app submitter-worker token-cache-app av-app pdf-generator datastore-app

spec: serve
	docker-compose run --rm app bundle exec rspec

clean:
	rm -fr .publisher .runner .submitter .av .token-cache .test-form .datastore .filestore .pdf-generator
