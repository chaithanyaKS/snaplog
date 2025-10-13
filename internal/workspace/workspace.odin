package workspace

import os "core:os/os2"
import "core:slice"
import "core:strings"

IGNORE :: []string{".", "..", ".git", ".snap", "snaplog"}

Workspace :: struct {
	path_name: string,
}

init :: proc(root_path: string) -> (ws: Workspace) {
	ws.path_name = root_path
	return
}

list_files :: proc(ws: ^Workspace, files_list: ^[dynamic]string) -> (err: os.Error) {
	fd := os.open(ws.path_name) or_return
	defer os.close(fd)
	file_info := os.read_dir(fd, 0, context.temp_allocator) or_return

	for f in file_info {
		if !slice.contains(IGNORE, f.name) && f.type == .Regular {
			name := strings.clone(f.name) or_return
			append(files_list, name) or_return
		}
	}

	return
}

read_file :: proc(ws: ^Workspace, path: string) -> (data: []byte, err: os.Error) {
	new_path := os.join_path([]string{ws.path_name, path}, context.temp_allocator) or_return
	data = os.read_entire_file_from_path(new_path, context.temp_allocator) or_return

	return
}
