package commit

import "../author/"
import "core:fmt"
import "core:strings"

Commit :: struct {
	parent:   string,
	oid:      string,
	tree_oid: string,
	author:   ^author.Author,
	message:  string,
	type:     string,
}

init :: proc(parent: string, tree_oid: string, author: ^author.Author, message: string) -> (commit: Commit) {
	commit.parent = parent
	commit.tree_oid = tree_oid
	commit.author = author
	commit.message = message
	commit.type = "commit"

	return
}

to_string :: proc(c: ^Commit) -> string {
	sb := strings.builder_make(context.temp_allocator)
	author_str := author.to_string(c.author)
	_ = fmt.sbprintf(&sb, "tree %s\n", c.tree_oid)
	if c.parent != "" {
		strings.write_string(&sb, fmt.tprintf("parent %s\n", c.parent))
	}
	_ = fmt.sbprintf(&sb, "author %s\ncommiter %s\n\n%s\n", author_str, author_str, c.message)

	commit_data := strings.to_string(sb)
	str := fmt.tprintf("%s %d\u0000%s", c.type, len(commit_data), commit_data)

	return str
}
