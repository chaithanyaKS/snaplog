init:
	odin build . -debug -out:build/snap
	rm -rf .snap
	odin run . -debug -- init

commit:
	rm -rf .snap
	odin run . -debug -- init
	odin run . -debug -- commit

build-snap:
	odin build . -debug -out:build/snap
