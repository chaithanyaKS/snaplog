package blob

import "core:fmt"
import "core:strings"
Blob :: struct {
	data: []byte,
	type: string,
	oid:  string,
}

init :: proc(data: []byte) -> (blb: Blob) {
	blb.data = data
	blb.type = "blob"
	return
}

to_string :: proc(blb: ^Blob) -> string {
	sb: strings.Builder
	defer strings.builder_destroy(&sb)
	return fmt.sbprintf(&sb, "%s %d\x00%s", blb.type, len(blb.data), blb.data)
}
