package entry

Entry :: struct {
	name: string,
	oid:  string,
}

init :: proc(name: string, oid: string) -> (entry: Entry) {
	entry.name = name
	entry.oid = oid
	return
}
