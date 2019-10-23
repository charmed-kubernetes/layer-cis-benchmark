all: unittest

.PHONY: clean
clean:
	@echo "Cleaning files"
	@rm -f .coverage .unit-state.db
	@find . -name "*.pyc" -type f -exec rm -f '{}' \;
	@find . -name "__pycache__" -type d -prune -exec rm -rf '{}' \;
	@rm -rf ./.tox
	@rm -rf ./.pytest_cache

.PHONY: lint
lint:
	@echo "Checking Python syntax..."
	@tox -e lint

.PHONY: unittest
unittest:
	@echo "Running unit tests..."
	@tox
