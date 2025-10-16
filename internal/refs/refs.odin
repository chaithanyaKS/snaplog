package refs

import "core:fmt"
import os "core:os/os2"

Refs :: struct {
	pathname: string,
}

new :: proc(pathname: string) -> (ref: Refs) {
	ref.pathname = pathname
	return
}


update_head :: proc(r: ^Refs, oid: string) -> os.Error {
	head_path := os.join_path([]string{r.pathname, "HEAD"}, context.temp_allocator) or_return
	fd := os.open(head_path, {.Write, .Create}) or_return
	defer os.close(fd)

	os.write_string(fd, oid)

	return nil
}

read_head :: proc(r: ^Refs) -> (data: string, err: os.Error) {
	head_path := os.join_path([]string{r.pathname, "HEAD"}, context.temp_allocator) or_return
	if !os.exists(head_path) {
		return "", nil
	}
	file_data := os.read_entire_file_from_path(head_path, context.temp_allocator) or_return
	return string(file_data), nil
}
