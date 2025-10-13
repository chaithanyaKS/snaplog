package blob

import "core:fmt"

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
	str := fmt.tprintf("%s %d\u0000%s", blb.type, len(blb.data), blb.data)
	return str
}
