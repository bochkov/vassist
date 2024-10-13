build:
	@mkdir -p build
	@cp libthermo.* build/
	nim c --mm:refc --nimcache=build/nimcache --out=build/app src/app.nim
	@cp -R public build

run:
	nim r --mm:refc --nimcache=build/nimcache src/app.nim

clean:
	rm -rf ./build
