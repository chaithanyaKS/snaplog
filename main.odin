package main

import "core:fmt"
import "core:log"
import "core:mem"
import os "core:os/os2"
import "core:time"

import "internal/author"
import "internal/blob"
import "internal/commit"
import "internal/database"
import "internal/entry"
import "internal/refs"
import "internal/tree"
import "internal/workspace"

GIT_AUTHOR_NAME :: "chaithanya"
GIT_AUTHOR_EMAIL :: "chaithanya@test.com"
GIT_MESSAGE :: "test message"

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
	files: [dynamic]string
	entries: [dynamic]entry.Entry
	name := GIT_AUTHOR_NAME
	email := GIT_AUTHOR_EMAIL
	message := GIT_MESSAGE
	current_time := time.to_unix_seconds(time.now())

	root_path := os.get_working_directory(context.temp_allocator) or_return
	git_path := os.join_path([]string{root_path, ".snap"}, context.temp_allocator) or_return
	db_path := os.join_path([]string{git_path, "objects"}, context.temp_allocator) or_return
	head_path := os.join_path([]string{git_path, "HEAD"}, context.temp_allocator) or_return

	ws := workspace.init(root_path)
	db := database.init(db_path)
	r := refs.new(git_path)
	workspace.list_files(&ws, &files) or_return

	for path in files {
		data := workspace.read_file(&ws, path) or_return
		blob := blob.init(data)
		database.store(&db, &blob)

		ent := entry.init(path, blob.oid)
		append(&entries, ent)
	}

	t := tree.init(entries)
	database.store(&db, &t)

	parent, err1 := refs.read_head(&r)
	if err1 != nil {
		fmt.println(err1)
	}

	author := author.init(name, email, current_time)
	commit := commit.init(parent, t.oid, &author, message)

	database.store(&db, &commit)
	refs.update_head(&r, commit.oid) or_return

	fmt.println("[(root-commit)] ", commit.oid)

	for f in files {
		delete_string(f)
	}
	delete_dynamic_array(files)
	delete_dynamic_array(entries)

	return nil
}

parse_command_line :: proc() {
	args := os.args
	if len(args) < 2 {
		git_print_help()
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
