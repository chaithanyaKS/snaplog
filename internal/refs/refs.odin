package refs

import "../../internal/"
import "../lockfile/"
import "core:fmt"
import os "core:os/os2"

Refs :: struct {
	pathname: string,
}


new :: proc(pathname: string) -> (ref: Refs) {
	ref.pathname = pathname
	return
}


update_head :: proc(r: ^Refs, oid: string) -> internal.Error {
	head_path := os.join_path([]string{r.pathname, "HEAD"}, context.temp_allocator) or_return
	lf := lockfile.init(head_path)

	lockfile.hold_for_update(&lf) or_return

	lockfile.write(&lf, oid) or_return
	lockfile.write(&lf, "\n") or_return
	lockfile.commit(&lf) or_return

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
