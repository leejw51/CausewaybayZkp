# GATE 18 — Causeway Bay ZKP
#
# One quest line, three front ends:
#
#   python/   the from-scratch age proof and its Gradio desk
#   rust/     quest 2's real Groth16 zk-SNARK (BN254, arkworks), a binary and
#             a C ABI shared library
#   love2d/   the game, which loads that library over ffi
#
# The release artifact is the Rust one: `gate18-snark` plus the shared library
# the game needs beside it. `make package` builds both optimised, signs them
# (ad-hoc unless APPLE_SIGNING_IDENTITY names a real certificate) and leaves
# them in ./dist.
#
#   make          show this help
#   make package  build the signed release binary and library into ./dist
#   make app      build the game as a double-clickable macOS .app
#   make test     run every suite

RUST_DIR   := rust
PYTHON_DIR := python
LOVE_DIR   := love2d

BIN      := gate18-snark
# --manifest-path is a subcommand option, not a cargo one, so it goes after the
# verb rather than into $(CARGO).
CARGO    := cargo
MANIFEST := --manifest-path $(RUST_DIR)/Cargo.toml

# Where every artifact lands. Overridable so CI can stage somewhere else.
DIST_DIR ?= $(abspath $(CURDIR)/dist)
SIGN     := $(abspath $(CURDIR)/scripts/codesign-binary.sh)

# The shared library the Love2D front end dlopens. Its name is the platform's,
# not ours — src/snark.lua tries all three.
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Darwin)
FFI_LIB := libgate18_snark.dylib
else
FFI_LIB := libgate18_snark.so
endif

# The version of record. Everything that stamps an artifact — packaging, the
# tag check in .github/workflows/release.yml — reads it from here, so a release
# can never carry a number nothing verified.
VERSION := $(shell sed -n 's/^version = "\(.*\)"/\1/p' $(RUST_DIR)/Cargo.toml | head -1)

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@echo
	@echo "  GATE 18 — Causeway Bay ZKP ($(BIN) $(VERSION))"
	@echo "  Python: $(PYTHON_DIR)  Rust: $(RUST_DIR)  Love2D: $(LOVE_DIR)"
	@echo
	@grep -hE '^[a-zA-Z0-9_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'
	@echo
	@echo "  Per-language targets live in each directory's own Makefile."
	@echo

# -------------------------------------------------------------------- version

.PHONY: version
version: ## Print the version of record
	@test -n "$(VERSION)" || { echo "ERROR: no version in $(RUST_DIR)/Cargo.toml" >&2; exit 1; }
	@echo "$(VERSION)"

# ------------------------------------------------------------------ packaging

.PHONY: package
package: release ## Build the signed release binary and library into ./dist
	@mkdir -p "$(DIST_DIR)"
	@cp -f $(RUST_DIR)/target/release/$(BIN) "$(DIST_DIR)/$(BIN)"
	@chmod +x "$(DIST_DIR)/$(BIN)"
	@"$(SIGN)" "$(DIST_DIR)/$(BIN)"
	@cp -f $(RUST_DIR)/target/release/$(FFI_LIB) "$(DIST_DIR)/$(FFI_LIB)"
	@"$(SIGN)" "$(DIST_DIR)/$(FFI_LIB)"
	@echo
	@echo "  $(DIST_DIR):"
	@ls -1lh "$(DIST_DIR)" | tail -n +2 | awk '{printf "    %-28s %s\n", $$9, $$5}'
	@$(MAKE) --no-print-directory package-verify

# Prove the artifact that shipped is the one that was built: it runs, it is
# the version the manifest claims, and the library beside it loads and proves.
# A binary in ./dist nothing ever executed is the worst thing a release can
# carry.
.PHONY: package-verify
package-verify: ## Check the packaged artifacts run
	@echo
	@echo "==> Checking the packaged artifacts"
	@printf '  %-28s ' "$(BIN) --version"
	@got=$$("$(DIST_DIR)/$(BIN)" --version | awk '{print $$NF}'); \
		test "$$got" = "$(VERSION)" && echo "$$got" \
		|| { echo "want $(VERSION), got $$got" >&2; exit 1; }
	@printf '  %-28s ' "$(BIN) --tamper"
	@"$(DIST_DIR)/$(BIN)" --tamper --json \
		| grep -q '"verdict": *"REJECT"' && echo "REJECT, as it should" \
		|| { echo "a tampered proof was not rejected" >&2; exit 1; }
	@printf '  %-28s ' "$(FFI_LIB)"
	@test -s "$(DIST_DIR)/$(FFI_LIB)" && echo "$$(du -h "$(DIST_DIR)/$(FFI_LIB)" | cut -f1 | tr -d ' ')" \
		|| { echo "missing" >&2; exit 1; }

# ------------------------------------------------------------------- the app
#
# The other half of a release: the game itself, as something a person can
# double-click. `make package` above produces the command-line artifacts, which
# need a terminal and a checkout to be interesting. This produces a bundle with
# LÖVE inside it, the SNARK library in Frameworks, signed and notarizable.
#
# macOS only, and it is love2d/Makefile's recipe — everything here is a door to
# it, so `make app` on a laptop and a tagged release do the same thing.
.PHONY: app
app: ## Build the double-clickable macOS .app (LÖVE embedded, signed)
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) app

.PHONY: notarize
notarize: ## Notarize and staple the built .app (needs Apple credentials)
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) notarize

.PHONY: gatekeeper
gatekeeper: ## Assess the built .app the way Finder does
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) gatekeeper

.PHONY: release
release: ## Build the optimised binary and shared library
	@echo "==> cargo build --release ($(BIN) $(VERSION))"
	@$(CARGO) build $(MANIFEST) --release --quiet

# ---------------------------------------------------------------------- tests

.PHONY: test
test: test-python test-rust test-love ## Run every suite
	@echo
	@echo "All tests passed."

.PHONY: test-python
test-python: ## Run the from-scratch ZKP tests
	@echo "==> Python tests"
	@$(MAKE) --no-print-directory -C $(PYTHON_DIR) test

.PHONY: test-rust
test-rust: ## Run the Groth16 self-tests
	@echo "==> Rust tests"
	@$(CARGO) test $(MANIFEST) --release

.PHONY: test-love
test-love: ## Run the Love2D suite (builds the SNARK library first)
	@echo "==> Love2D tests"
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) snark
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) test

# --------------------------------------------------------------------- checks

.PHONY: format
format: ## Format every front end
	@$(MAKE) --no-print-directory -C $(PYTHON_DIR) format
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) format
	@$(CARGO) fmt $(MANIFEST)

# ------------------------------------------------------------------- the game

.PHONY: run
run: ## Open the Love2D game
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) run

# ---------------------------------------------------------------------- clean

.PHONY: clean
clean: ## Remove ./dist, the app bundle and the Rust build output
	@$(CARGO) clean $(MANIFEST)
	@$(MAKE) --no-print-directory -C $(LOVE_DIR) clean
	@rm -rf "$(DIST_DIR)"
