package commit

import "../author/"
import "core:fmt"
import "core:strings"

Commit :: struct {
	oid:      string,
	tree_oid: string,
	author:   ^author.Author,
	message:  string,
	type:     string,
}

init :: proc(tree_oid: string, author: ^author.Author, message: string) -> (commit: Commit) {
	commit.tree_oid = tree_oid
	commit.author = author
	commit.message = message
	commit.type = "commit"

	return
}

to_string :: proc(c: ^Commit) -> string {
	buf := strings.builder_make()
	sb := strings.builder_make()
	defer strings.builder_destroy(&buf)
	defer strings.builder_destroy(&sb)

	author_str := author.to_string(c.author)
	commit_data := fmt.sbprintf(
		&buf,
		"tree %s\nauthor %s\ncommiter %s\n\n%s",
		c.tree_oid,
		author_str,
		author_str,
		c.message,
	)

	return fmt.sbprintf(&sb, "%s %d\u0000%s", c.type, len(commit_data), commit_data)
}
