all:
	@mkdir -p build
	@cp ~/Dropbox/cgrad/libthermo.so build/libthermo.so
	nim c --nimcache=build/nimcache --out=build/app src/app.nim
	@cp -R public build
	@cd build; ./app