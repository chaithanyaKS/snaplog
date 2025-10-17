package entry

import os "core:os/os2"

REGULAR_MODE :: "100644"
EXECUTABLE_MODE :: "100755"


Entry :: struct {
	name: string,
	oid:  string,
	mode: string,
}

init :: proc(name: string, oid: string, file_type: ^os.File_Type) -> (entry: Entry) {
	entry.name = name
	entry.oid = oid
	if file_type^ == .Regular {
		entry.mode = REGULAR_MODE
	} else {
		entry.mode = EXECUTABLE_MODE
	}
	return
}
