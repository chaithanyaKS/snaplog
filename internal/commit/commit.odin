package commit

import "../author/"
import "core:fmt"

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
	author_str := author.to_string(c.author)
	commit_data := fmt.tprintf(
		"tree %s\nauthor %s\ncommiter %s\n\n%s\n",
		c.tree_oid,
		author_str,
		author_str,
		c.message,
	)
	str := fmt.tprintf("%s %d\u0000%s", c.type, len(commit_data), commit_data)

	return str
}
