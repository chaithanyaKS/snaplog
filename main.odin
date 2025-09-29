package main

import "core:flags"
import "core:fmt"
import "core:log"
import os "core:os/os2"
import "core:path/filepath"

main :: proc() {
	parse_command_line()
}

git_print_help :: proc() {
	fmt.println("A Toy git implementation")
}

git_initialize_repo :: proc() -> os.Error {
	root_path := os.get_working_directory(context.allocator) or_return
	git_path := filepath.join([]string{root_path, ".snap"}) or_return

	folders_to_create := [?]string{"objects", "refs"}

	for dir in folders_to_create {
		os.mkdir_all(filepath.join([]string{git_path, dir})) or_return
	}

	return nil
}

parse_command_line :: proc() {
	args := os.args
	if len(args) < 2 {
		git_print_help()
		return
	}
	sub_command := args[1]
	if sub_command == "init" {
		err := git_initialize_repo()
		fmt.println("Initialized git repo")
		if err != nil {
			log.fatal("Error when Initializing repo", err)
		}
	} else {
		fmt.printfln("'%s' sub command not recognized", sub_command)
	}
}
