all:
	@mkdir -p build
	@cp libthermo.* build/
	nim c --mm:refc --nimcache=build/nimcache --out=build/app src/app.nim
	@cp -R public build
	@cd build; ./app