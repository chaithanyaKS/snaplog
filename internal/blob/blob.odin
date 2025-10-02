package blob

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
