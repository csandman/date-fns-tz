test:
	@env TZ=Asia/Singapore npx vitest run
.PHONY: test

test-watch:
	@env TZ=Asia/Singapore npx vitest

types:
	@npx tsc --noEmit

types-watch:
	@npx tsc --noEmit --watch

test-types: install-attw build 
	@cd lib && attw --pack

build: prepare-build
	@npx tsc -p tsconfig.lib.json 
	@env BABEL_ENV=esm npx babel src --config-file ./babel.config.lib.json --source-root src --out-dir lib --extensions .js,.ts --out-file-extension .js --quiet
	@env BABEL_ENV=cjs npx babel src --config-file ./babel.config.lib.json --source-root src --out-dir lib --extensions .js,.ts --out-file-extension .cjs --quiet
	@node copy.mjs
	# @rm -rf lib/types.*js
	@make build-cts
	
build-cts:
	@find lib -name '*.d.ts' | while read file; do \
		new_file=$${file%.d.ts}.d.cts; \
		cp $$file $$new_file; \
	done

prepare-build:
	@rm -rf lib
	@mkdir -p lib

publish: build
	cd lib && npm publish --access public

publish-next: build
	cd lib && npm publish --access public --tag next

link:
	@cd lib && npm link

install-attw:
	@if ! command -v attw >/dev/null 2>&1; then \
		npm i -g @arethetypeswrong/cli; \
	fi