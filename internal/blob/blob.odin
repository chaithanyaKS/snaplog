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
	sb := strings.builder_make()
	defer strings.builder_destroy(&sb)

	str := fmt.sbprintf(&sb, "%s %d %s", blb.type, len(blb.data), blb.data)
	fmt.println(str)

	return str
}
