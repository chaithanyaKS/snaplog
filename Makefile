init: 
	odin run . -debug -- init

commit: 
	rm -rf .snap && odin run . -debug -- init && odin run . -debug -- commit
