# GATE 18 — Love2D Causeway Bay
# Default: make help

APP     := $(CURDIR)
LOVE    := love
PIDFILE := $(CURDIR)/.gate18-love.pid
LOGFILE := $(CURDIR)/.gate18-love.log
SRC     := main.lua conf.lua src tests
STYLUA  := stylua

.DEFAULT_GOAL := help

.PHONY: help start run stop test format status drive snark

help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"; printf "\n  GATE 18  //  Love2D\n\n"} \
		/^[a-zA-Z0-9_-]+:.*##/ { printf "  make %-10s %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@printf "\n  F1 portrait/landscape   F11 window/fullscreen\n"
	@printf "  setup JSONL lives in ~/.causewaybayzkp\n\n"

start: ## Run the game (background)
	@if [ -f "$(PIDFILE)" ] && kill -0 $$(cat "$(PIDFILE)") 2>/dev/null; then \
		echo "already running  pid $$(cat "$(PIDFILE)")"; \
	else \
		: > "$(LOGFILE)"; \
		nohup $(LOVE) "$(APP)" >"$(LOGFILE)" 2>&1 & echo $$! > "$(PIDFILE)"; \
		sleep 0.8; \
		if ! kill -0 $$(cat "$(PIDFILE)") 2>/dev/null; then \
			echo "start failed — see $(LOGFILE)"; \
			rm -f "$(PIDFILE)"; \
			cat "$(LOGFILE)"; \
			exit 1; \
		fi; \
		if grep -q '^Error:' "$(LOGFILE)" 2>/dev/null; then \
			echo "start failed — see $(LOGFILE)"; \
			kill $$(cat "$(PIDFILE)") 2>/dev/null || true; \
			rm -f "$(PIDFILE)"; \
			cat "$(LOGFILE)"; \
			exit 1; \
		fi; \
		echo "started  pid $$(cat "$(PIDFILE)")"; \
	fi

run: start ## Alias for start

stop: ## Stop the game
	@if [ -f "$(PIDFILE)" ]; then \
		pid=$$(cat "$(PIDFILE)"); \
		kill $$pid 2>/dev/null || true; \
		rm -f "$(PIDFILE)"; \
		echo "stopped  pid $$pid"; \
	else \
		pkill -f "love $(APP)" 2>/dev/null || true; \
		echo "stopped"; \
	fi

status: ## Is the game running?
	@if [ -f "$(PIDFILE)" ] && kill -0 $$(cat "$(PIDFILE)") 2>/dev/null; then \
		echo "running  pid $$(cat "$(PIDFILE)")"; \
	else \
		echo "not running"; \
	fi

test: ## Run the Love2D test suite
	@GATE18_TEST=1 GATE18_HOME="$(APP)/.test-home" $(LOVE) "$(APP)" --test; \
	status=$$?; \
	rm -rf "$(APP)/.test-home"; \
	exit $$status

drive: ## Replay a scripted session: make drive SCRIPT=tests/drive/all.lua
	@test -n "$(SCRIPT)" || { echo "usage: make drive SCRIPT=path/to/script.lua"; exit 1; }
	@GATE18_HOME="$(APP)/.drive-home" GATE18_DRIVE="$(SCRIPT)" $(LOVE) "$(APP)"; \
	status=$$?; \
	rm -rf "$(APP)/.drive-home"; \
	echo "screenshots: ~/Library/Application Support/LOVE/gate18-causewaybay"; \
	exit $$status

snark: ## Build the quest 2 Rust library the game loads over ffi
	cargo build --release --manifest-path "$(CURDIR)/../rust/Cargo.toml"

format: ## Format Lua with stylua
	@command -v $(STYLUA) >/dev/null 2>&1 || { \
		echo "stylua not found — brew install stylua"; \
		exit 1; \
	}
	$(STYLUA) $(SRC)

# ------------------------------------------------------------------ macOS app
#
# A real double-clickable .app, with LÖVE inside it.
#
# `make start` needs LÖVE installed and a checkout to run from. This produces
# something you can hand to a person who has never heard of LÖVE: the runtime is
# downloaded and embedded, the SNARK library goes in Frameworks where a signed
# bundle keeps its nested binaries, the icon comes from the game's own coin, and
# the whole thing is signed and zipped.
#
# Two entitlements are not optional and both are LuaJIT's fault:
#
#   * the hardened runtime needs `allow-jit` and
#     `allow-unsigned-executable-memory`, or the app dies the moment LuaJIT
#     compiles anything;
#   * `disable-library-validation`, because libgate18_snark is not signed by
#     whoever signed LÖVE, and without it dlopen refuses to load it.
#
# Signing uses a Developer ID if the machine has one and falls back to ad-hoc,
# which is enough to run locally and not enough to hand to somebody else.

LOVE_VERSION ?= 11.5
APP_NAME     := GATE18
BUNDLE_ID    := com.causewaybay.gate18
LOVE_URL     := https://github.com/love2d/love/releases/download/$(LOVE_VERSION)/love-$(LOVE_VERSION)-macos.zip
BUILD        := $(CURDIR)/build
BUNDLE       := $(BUILD)/$(APP_NAME).app
RUST_DIR     := $(CURDIR)/../rust
FFI_LIB      := libgate18_snark.dylib
VERSION      := $(shell sed -n 's/^version = "\(.*\)"/\1/p' $(RUST_DIR)/Cargo.toml | head -1)

.PHONY: app
app: snark ## Build a double-clickable macOS .app with LÖVE embedded
	@# Single quotes, not backticks: sh would treat `make app` as a command
	@# substitution and re-enter this target on every platform that is not macOS.
	@test "$$(uname -s)" = "Darwin" || { echo "  'make app' is macOS only." >&2; exit 1; }
	@rm -rf "$(BUNDLE)" "$(BUILD)/love-macos" "$(BUILD)/$(APP_NAME)-macos.zip"
	@mkdir -p "$(BUILD)"

	@# The game, as one archive. A glob, not a hand-written list: a module
	@# left out of the staging dies on the first `require`, and it dies on
	@# somebody else's machine, because the checkout it was built from has the
	@# file sitting right there.
	@rm -rf "$(BUILD)/stage" && mkdir -p "$(BUILD)/stage"
	@cp -R main.lua conf.lua src assets "$(BUILD)/stage/"
	@cd "$(BUILD)/stage" && zip -qr9 "../game.love" .
	@rm -rf "$(BUILD)/stage"
	@$(MAKE) --no-print-directory verify-archive ARCHIVE="$(BUILD)/game.love"

	@echo "  fetching LÖVE $(LOVE_VERSION)"
	@curl -fsSL -o "$(BUILD)/love-macos.zip" "$(LOVE_URL)"
	@unzip -q -o "$(BUILD)/love-macos.zip" -d "$(BUILD)/love-macos"
	@mv "$(BUILD)/love-macos/love.app" "$(BUNDLE)"

	@cp "$(BUILD)/game.love" "$(BUNDLE)/Contents/Resources/game.love"
	@cp -f "$(RUST_DIR)/target/release/$(FFI_LIB)" "$(BUNDLE)/Contents/Frameworks/$(FFI_LIB)"

	@# Without these the bundle is still called "LÖVE" everywhere macOS shows a
	@# name, and two different games installed at once collide on the bundle id.
	@plutil -replace CFBundleName -string "GATE 18" "$(BUNDLE)/Contents/Info.plist"
	@plutil -replace CFBundleDisplayName -string "GATE 18" "$(BUNDLE)/Contents/Info.plist"
	@plutil -replace CFBundleIdentifier -string "$(BUNDLE_ID)" "$(BUNDLE)/Contents/Info.plist"
	@plutil -replace CFBundleShortVersionString -string "$(VERSION)" "$(BUNDLE)/Contents/Info.plist"
	@plutil -replace CFBundleVersion -string "$(VERSION)" "$(BUNDLE)/Contents/Info.plist"
	@# LÖVE ships this as an editable document type so a .love dropped on the
	@# icon runs. This bundle *is* one game and must not open somebody else's.
	@plutil -remove CFBundleDocumentTypes "$(BUNDLE)/Contents/Info.plist" 2>/dev/null || true
	@plutil -remove UTExportedTypeDeclarations "$(BUNDLE)/Contents/Info.plist" 2>/dev/null || true
	@plutil -replace CFBundleExecutable -string "love" "$(BUNDLE)/Contents/Info.plist"
	@plutil -replace NSHighResolutionCapable -bool true "$(BUNDLE)/Contents/Info.plist"

	@$(MAKE) --no-print-directory app-icon
	@$(MAKE) --no-print-directory app-sign

	@# Skipped where there is no window server to draw into — a CI runner has
	@# no display, and a smoke test that cannot open a window would fail for a
	@# reason that has nothing to do with the bundle. `verify-archive` above
	@# still runs there and catches a missing module deterministically.
	@if [ -n "$(SKIP_SMOKE)" ]; then \
		echo "  smoke test skipped (SKIP_SMOKE set)"; \
	else \
		$(MAKE) --no-print-directory app-smoke; \
	fi

	@cd "$(BUILD)" && ditto -c -k --sequesterRsrc --keepParent "$(APP_NAME).app" "$(APP_NAME)-macos.zip"
	@rm -rf "$(BUILD)/love-macos" "$(BUILD)/love-macos.zip" "$(BUILD)/game.love"
	@echo
	@du -sh "$(BUNDLE)" "$(BUILD)/$(APP_NAME)-macos.zip" | sed 's/^/    /'
	@echo
	@echo "  Open it with: open \"$(BUNDLE)\""

# Every module has to be in the archive.
#
# A missing one is not a subtle failure — the bundle dies on the first
# `require` — but it dies for whoever downloaded it, never here, because
# `make start` loads from the working tree where every file exists.
.PHONY: verify-archive
verify-archive:
	@missing=""; \
	for file in main.lua conf.lua src/*.lua; do \
		unzip -l "$(ARCHIVE)" 2>/dev/null | grep -qE " $$file$$" || missing="$$missing $$file"; \
	done; \
	if [ -n "$$missing" ]; then \
		echo "  the archive is missing:$$missing" >&2; \
		echo "  (staging is a glob; if this fires, something excluded it)" >&2; \
		exit 1; \
	fi; \
	echo "  archive carries every module ($$(ls main.lua conf.lua src/*.lua | wc -l | tr -d ' ') files)"

# Start the thing that was built and see whether it draws.
#
# The archive check proves every file is present; this proves they add up to a
# program, and that the bundle finds its own SNARK library in Frameworks rather
# than a build sitting in the checkout. That last part is the whole reason this
# runs the bundle instead of `make start`: the search path that works here is
# the one that has nothing else to fall back on.
.PHONY: app-smoke
app-smoke:
	@test -d "$(BUNDLE)" || { echo "  no $(BUNDLE); run 'make app'" >&2; exit 1; }
	@# A fused bundle saves under its own identity; a `love .` run puts it
	@# under LOVE/. Both are checked so this target works either way.
	@fused="$$HOME/Library/Application Support/gate18-causewaybay"; \
	 loose="$$HOME/Library/Application Support/LOVE/gate18-causewaybay"; \
	 rm -f "$$fused/gate18-smoke.png" "$$loose/gate18-smoke.png"; \
	 printf '%s\n' \
		'local Snark = require "src.snark"' \
		'print("SMOKE snark=" .. tostring(Snark.available()) .. " " .. tostring(Snark.libPath()))' \
		'return {' \
		'  { at = 2.0, shot = "gate18-smoke.png" },' \
		'  { at = 2.6, quit = true },' \
		'}' > "$(BUILD)/smoke.lua"; \
	 GATE18_DRIVE="$(BUILD)/smoke.lua" GATE18_HOME="$(BUILD)/smoke-home" \
		"$(BUNDLE)/Contents/MacOS/love" > "$(BUILD)/smoke.log" 2>&1 & \
	 pid=$$!; \
	 for _ in $$(seq 1 40); do \
		[ -f "$$fused/gate18-smoke.png" ] || [ -f "$$loose/gate18-smoke.png" ] && break; \
		sleep 0.5; \
	 done; \
	 kill $$pid 2>/dev/null || true; \
	 wait $$pid 2>/dev/null || true; \
	 if [ ! -f "$$fused/gate18-smoke.png" ] && [ ! -f "$$loose/gate18-smoke.png" ]; then \
		echo "  the bundle did not draw a frame:" >&2; \
		head -20 "$(BUILD)/smoke.log" >&2; \
		exit 1; \
	 fi; \
	 rm -f "$$fused/gate18-smoke.png" "$$loose/gate18-smoke.png"; \
	 echo "  the bundle starts and draws"; \
	 line=$$(grep '^SMOKE snark=' "$(BUILD)/smoke.log" | head -1); \
	 case "$$line" in \
		*"snark=true"*Frameworks*) echo "  the bundle loads its own library: $${line#SMOKE snark=true }";; \
		*) echo "  the bundle did not load Frameworks/$(FFI_LIB): $$line" >&2; exit 1;; \
	 esac
	@rm -rf "$(BUILD)/smoke-home" "$(BUILD)/smoke.log" "$(BUILD)/smoke.lua"

# The icon, from the game's own coin. `sips` refuses to upscale cleanly, so
# every size comes from the 1024px source.
.PHONY: app-icon
app-icon:
	@test -f assets/icon.png || { echo "  no assets/icon.png; keeping LÖVE's icon"; exit 0; }
	@rm -rf "$(BUILD)/icon.iconset" && mkdir -p "$(BUILD)/icon.iconset"
	@for size in 16 32 64 128 256 512 1024; do \
		sips -s format png -z $$size $$size assets/icon.png \
			--out "$(BUILD)/icon.iconset/icon_$${size}x$${size}.png" > /dev/null 2>&1; \
	done
	@for size in 16 32 128 256 512; do \
		double=$$((size * 2)); \
		cp "$(BUILD)/icon.iconset/icon_$${double}x$${double}.png" \
			"$(BUILD)/icon.iconset/icon_$${size}x$${size}@2x.png" 2>/dev/null || true; \
	done
	@rm -f "$(BUILD)/icon.iconset/icon_1024x1024.png"
	@iconutil -c icns "$(BUILD)/icon.iconset" -o "$(BUILD)/icon.icns"
	@cp "$(BUILD)/icon.icns" "$(BUNDLE)/Contents/Resources/OS X AppIcon.icns" 2>/dev/null || true
	@cp "$(BUILD)/icon.icns" "$(BUNDLE)/Contents/Resources/Love.icns" 2>/dev/null || true
	@rm -rf "$(BUILD)/icon.iconset" "$(BUILD)/icon.icns"
	@echo "  icon from assets/icon.png"

# Signed inside-out: nested binaries first, then the executable, then the
# bundle. Signing the outer bundle first invalidates itself the moment anything
# inside it is signed afterwards.
.PHONY: app-sign
app-sign:
	@test -d "$(BUNDLE)" || { echo "  no $(BUNDLE); run 'make app'" >&2; exit 1; }
	@rm -f "$(BUILD)/entitlements.plist"
	@printf '%s\n' \
		'<?xml version="1.0" encoding="UTF-8"?>' \
		'<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">' \
		'<plist version="1.0"><dict>' \
		'  <key>com.apple.security.cs.allow-jit</key><true/>' \
		'  <key>com.apple.security.cs.allow-unsigned-executable-memory</key><true/>' \
		'  <key>com.apple.security.cs.disable-library-validation</key><true/>' \
		'</dict></plist>' \
		> "$(BUILD)/entitlements.plist"
	@# APPLE_SIGNING_IDENTITY wins when it is set, because that is what the
	@# release workflow exports after importing the certificate into a keychain
	@# it made for the job. Falling back to a keychain search is for a laptop.
	@identity="$${APPLE_SIGNING_IDENTITY:-}"; \
	if [ -z "$$identity" ] || [ "$$identity" = "-" ]; then \
		identity=$$(security find-identity -v -p codesigning 2>/dev/null \
			| grep "Developer ID Application" | head -1 | awk -F'"' '{print $$2}'); \
	fi; \
	if [ -z "$$identity" ]; then \
		identity="-"; \
		echo "  no Developer ID found — signing ad-hoc (runs here, not elsewhere)"; \
	else \
		echo "  signing as $$identity"; \
	fi; \
	stamp=--timestamp; \
	[ "$$identity" = "-" ] && stamp=""; \
	find "$(BUNDLE)/Contents/Frameworks" -type f 2>/dev/null | while read -r file; do \
		if file "$$file" | grep -q "Mach-O"; then \
			codesign --force --options runtime --sign "$$identity" \
				--entitlements "$(BUILD)/entitlements.plist" $$stamp "$$file" || exit 1; \
		fi; \
	done; \
	find "$(BUNDLE)/Contents/Frameworks" -maxdepth 1 -name "*.framework" 2>/dev/null | while read -r bundle; do \
		codesign --force --options runtime --sign "$$identity" \
			--entitlements "$(BUILD)/entitlements.plist" $$stamp "$$bundle" || exit 1; \
	done; \
	codesign --force --options runtime --sign "$$identity" \
		--entitlements "$(BUILD)/entitlements.plist" $$stamp \
		"$(BUNDLE)/Contents/MacOS/love" || exit 1; \
	codesign --force --options runtime --sign "$$identity" \
		--entitlements "$(BUILD)/entitlements.plist" $$stamp "$(BUNDLE)" || exit 1
	@rm -f "$(BUILD)/entitlements.plist"
	@codesign --verify --deep --strict "$(BUNDLE)" && echo "  signature verifies"

# ---------------------------------------------------------------- notarize
#
# Signing is not enough on its own, and this is the part that finishes it.
#
# A Developer ID signature with the hardened runtime and a secure timestamp is
# necessary and not sufficient: since macOS 10.15 anything distributed outside
# the App Store must also be notarized by Apple. Without it a *downloaded* copy
# is refused, and the person who downloaded it gets "Apple could not verify…".
#
# Not part of `make app`: it needs credentials this repository must not carry,
# and it uploads the bundle to Apple and waits, which is not something a build
# should do without being asked.
#
#     export APPLE_ID=you@example.com
#     export APPLE_PASSWORD=abcd-efgh-ijkl-mnop   # app-specific
#     export APPLE_TEAM_ID=ABCDE12345
#     make notarize
.PHONY: notarize
notarize: ## Notarize and staple the built .app (needs Apple credentials)
	@test -d "$(BUNDLE)" || { echo "  no $(BUNDLE); run 'make app' first" >&2; exit 1; }
	@for name in APPLE_ID APPLE_PASSWORD APPLE_TEAM_ID; do \
		eval "value=\$$$$name"; \
		[ -n "$$value" ] || { \
			echo "  $$name is not set." >&2; \
			echo "  Notarizing needs an Apple ID, an app-specific password" >&2; \
			echo "  from appleid.apple.com, and the team id. None is kept here." >&2; \
			exit 1; }; \
	done

	@# Ad-hoc cannot be notarized, and finding that out from Apple takes
	@# minutes. The signature says which it is, so ask it first.
	@codesign -dv --verbose=2 "$(BUNDLE)" 2>&1 | grep -q "Authority=Developer ID Application" || { \
		echo "  $(BUNDLE) is not signed with a Developer ID." >&2; \
		echo "  Apple will refuse an ad-hoc signature; there is nothing to submit." >&2; \
		exit 1; }

	@echo "  submitting to Apple — this takes minutes, not seconds"
	@ditto -c -k --sequesterRsrc --keepParent "$(BUNDLE)" "$(BUILD)/notarize.zip"
	@xcrun notarytool submit "$(BUILD)/notarize.zip" \
		--apple-id "$$APPLE_ID" \
		--password "$$APPLE_PASSWORD" \
		--team-id "$$APPLE_TEAM_ID" \
		--wait --timeout 20m
	@rm -f "$(BUILD)/notarize.zip"

	@# Stapled, so the ticket travels with the bundle and Gatekeeper can check
	@# it with no network at all. A .app can hold one; a bare binary cannot.
	@xcrun stapler staple "$(BUNDLE)"
	@xcrun stapler validate "$(BUNDLE)"

	@# The distribution zip was made before any of this and carries an
	@# unstapled copy. Rebuilt, or the download is exactly what it was.
	@rm -f "$(BUILD)/$(APP_NAME)-macos.zip"
	@cd "$(BUILD)" && ditto -c -k --sequesterRsrc --keepParent \
		"$(APP_NAME).app" "$(APP_NAME)-macos.zip"

	@$(MAKE) --no-print-directory gatekeeper

# What a person who downloads it will actually get.
#
# `--context context:primary-signature` is the one that matters: plain
# `spctl -a` accepts an un-notarized Developer ID bundle, and Finder does not.
# Asking the wrong question is how "it is signed" gets mistaken for "it opens".
.PHONY: gatekeeper
gatekeeper: ## Assess the bundle the way Finder does
	@test -d "$(BUNDLE)" || { echo "  no $(BUNDLE); run 'make app' first" >&2; exit 1; }
	@codesign --verify --deep --strict "$(BUNDLE)" && echo "  signature: valid"
	@if xcrun stapler validate "$(BUNDLE)" > /dev/null 2>&1; then \
		echo "  notarized: yes, and stapled"; \
	else \
		echo "  notarized: NO — a downloaded copy will be blocked"; \
	fi
	@spctl -a -vvv -t open --context context:primary-signature "$(BUNDLE)" 2>&1 \
		| sed 's/^/  /' || true

.PHONY: clean
clean: ## Remove the app bundle and staged output
	@rm -rf "$(BUILD)"
