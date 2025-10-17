package tree

import "../entry/"
import "core:encoding/hex"
import "core:fmt"
import "core:slice"
import "core:strings"

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
	sb := strings.builder_make(context.temp_allocator)

	slice.sort_by(t.entries[:], proc(a, b: entry.Entry) -> bool {
		return a.name < b.name
	})

	for ent in t.entries {
		decoded_value, ok := hex.decode(transmute([]byte)ent.oid, context.temp_allocator)
		if !ok {
			panic("error in decoding string in trees")
		}

		// mode SP name NUL sha1(20 raw bytes)
		_ = fmt.sbprintf(&sb, "%s %s\u0000", ent.mode, ent.name)
		strings.write_string(&sb, transmute(string)decoded_value)
	}

	str := strings.to_string(sb)
	res := fmt.tprintf("%s %d\u0000%s", t.type, len(str), str)

	return res

}
