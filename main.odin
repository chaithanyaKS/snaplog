package main

import "core:flags"
import "core:fmt"
import "core:log"
import "core:mem"
import os "core:os/os2"
import "core:strings"

import "internal/blob"
import "internal/database"
import "internal/entry"
import "internal/tree"
import "internal/workspace"

main :: proc() {
	when ODIN_DEBUG {
		track: mem.Tracking_Allocator
		mem.tracking_allocator_init(&track, context.allocator)
		context.allocator = mem.tracking_allocator(&track)

		defer {
			free_all(context.temp_allocator)
			free_all(context.allocator)
			if len(track.allocation_map) > 0 {
				fmt.eprintf("=== %v allocations not freed: ===\n", len(track.allocation_map))
				for _, entry in track.allocation_map {
					fmt.eprintf("- %v bytes @ %v\n", entry.size, entry.location)
				}
			}
			mem.tracking_allocator_destroy(&track)
		}
	}
	parse_command_line()
}

git_print_help :: proc() {
	fmt.println("A Toy git implementation")
}

git_initialize_repo :: proc() -> os.Error {
	root_path := os.get_working_directory(context.temp_allocator) or_return
	git_path := os.join_path([]string{root_path, ".snap"}, context.temp_allocator) or_return


	folders_to_create := [?]string{"objects", "refs"}

	for dir in folders_to_create {
		path := os.join_path([]string{git_path, dir}, context.temp_allocator) or_return
		os.mkdir_all(path) or_return
	}

	return nil
}

git_commit_repo :: proc() -> (err: os.Error) {
	root_path := os.get_working_directory(context.temp_allocator) or_return
	git_path := os.join_path([]string{root_path, ".snap"}, context.temp_allocator) or_return
	db_path := os.join_path([]string{git_path, "objects"}, context.temp_allocator) or_return
	files: [dynamic]string


	ws := workspace.init(root_path)
	db := database.init(db_path)

	workspace.list_files(&ws, &files) or_return
	entries: [dynamic]entry.Entry

	for path in files {
		data := workspace.read_file(&ws, path) or_return
		blob := blob.init(data)

		database.store(&db, &blob)

		ent := entry.init(path, blob.oid)
		append(&entries, ent)
	}

	tre := tree.init(entries)
	database.store(&db, &tre)

	for f in files {
		delete_string(f)
	}

	delete(files)
	delete(entries)

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
