# GATE 18 — from-scratch age ZKP
# Default: make help

PYTHON   := .venv/bin/python
PIP      := .venv/bin/pip
PORT     := 7860
PIDFILE  := .gate18.pid
LOG      := .gate18.log
SRC      := zkp tests app.py

.DEFAULT_GOAL := help

.PHONY: help venv install start stop test format

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\n  GATE 18\n\n"} \
		/^[a-zA-Z0-9_-]+:.*##/ { printf "  make %-10s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf "\n  start binds 0.0.0.0:%s for iPhone on the same Wi-Fi.\n\n" "$(PORT)"

venv: ## Create .venv if missing
	@test -x $(PYTHON) || python3 -m venv .venv

install: venv ## Install Python deps into .venv
	@$(PIP) install -q -r requirements.txt

start: install ## Start Gradio on 0.0.0.0:$(PORT)
	@if [ -f $(PIDFILE) ] && kill -0 $$(cat $(PIDFILE)) 2>/dev/null; then \
		echo "already running  pid $$(cat $(PIDFILE))  http://127.0.0.1:$(PORT)"; \
		exit 0; \
	fi
	@PYTHONUNBUFFERED=1 nohup $(PYTHON) app.py >$(LOG) 2>&1 & echo $$! >$(PIDFILE)
	@sleep 1
	@if ! kill -0 $$(cat $(PIDFILE)) 2>/dev/null; then \
		echo "start failed — see $(LOG)"; \
		rm -f $(PIDFILE); \
		exit 1; \
	fi
	@IP=$$($(PYTHON) -c "import socket; s=socket.socket(socket.AF_INET,socket.SOCK_DGRAM); s.connect(('8.8.8.8',80)); print(s.getsockname()[0]); s.close()"); \
	echo "started  pid $$(cat $(PIDFILE))"; \
	echo "local    http://127.0.0.1:$(PORT)"; \
	echo "phone    http://$$IP:$(PORT)"; \
	echo "log      $(LOG)"

stop: ## Stop the Gradio server
	@if [ -f $(PIDFILE) ]; then \
		pid=$$(cat $(PIDFILE)); \
		kill $$pid 2>/dev/null || true; \
		rm -f $(PIDFILE); \
		echo "stopped  pid $$pid"; \
	fi
	@PIDS=$$(lsof -tiTCP:$(PORT) -sTCP:LISTEN 2>/dev/null || true); \
	if [ -n "$$PIDS" ]; then kill $$PIDS 2>/dev/null || true; echo "freed    port $(PORT)"; fi
	@echo "port $(PORT) is free"

test: install ## Run ZKP unit tests
	$(PYTHON) tests/test_age.py

format: install ## Format Python with ruff
	$(PYTHON) -m ruff format $(SRC)
	$(PYTHON) -m ruff check --fix $(SRC)
