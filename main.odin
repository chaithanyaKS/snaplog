package main

import "core:flags"
import "core:fmt"
import "core:log"
import os "core:os/os2"
import "core:path/filepath"

import "internal/blob"
import "internal/database"
import "internal/workspace"

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

git_commit_repo :: proc() -> (err: os.Error) {
	root_path := os.get_working_directory(context.temp_allocator) or_return
	git_path := filepath.join([]string{root_path, ".snap"})
	db_path := filepath.join([]string{git_path, "objects"})

	ws := workspace.init(root_path)
	db := database.init(db_path)

	files := workspace.list_files(&ws) or_return
	fmt.println(files)
	for file in files {
		fmt.println(file)
		data := workspace.read_file(&ws, file) or_return
		blob := blob.init(data)

		database.store(&db, &blob)
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
	switch sub_command {
	case "init":
		err := git_initialize_repo()
		fmt.println("Initialized git repo")
		if err != nil {
			log.fatal("Error when Initializing repo", err)
		}
	case "commit":
		err := git_commit_repo()
		if err != nil {
			log.fatal("Error when commiting repo", err)
		}
	case:
		fmt.printfln("'%s' sub command not recognized", sub_command)
	}
}
