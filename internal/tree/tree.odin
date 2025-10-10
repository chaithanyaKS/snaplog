package tree

import "../entry/"
import "core:encoding/hex"
import "core:fmt"
import "core:slice"
import "core:sort"
import "core:strings"

MODE :: "100644"

Tree :: struct {
	entries: [dynamic]entry.Entry,
	oid:     string,
	type:    string,
}

init :: proc(ent: [dynamic]entry.Entry) -> (tree: Tree) {
	tree.entries = ent
	tree.type = "tree"

	return
}

to_string :: proc(t: ^Tree) -> string {
	sb := strings.builder_make()
	defer strings.builder_destroy(&sb)
	slice.sort_by(t.entries[:], proc(a, b: entry.Entry) -> bool {
		return a.name < b.name
	})

	for ent in t.entries {
		hashed_data := hex.encode(transmute([]byte)t.oid)
		data := fmt.sbprintf(&sb, "%s %s\u0000%s", MODE, ent.name, hashed_data)
		strings.write_string(&sb, data)
	}

	return strings.to_string(sb)

}
