package lockfile

import "../../internal/"
import os "core:os/os2"
import "core:path/filepath"
import "core:strings"


Lockfile :: struct {
	file_path: string,
	lock_path: string,
	lock:      ^os.File,
}

init :: proc(file_path: string) -> (l: Lockfile) {
	l.file_path = file_path
	l.lock_path = strings.join([]string{l.file_path, "lock"}, ".", context.temp_allocator)

	return
}

hold_for_update :: proc(l: ^Lockfile) -> (bool, internal.Error) {
	err: os.Error

	if l.lock == nil {
		l.lock, err = os.open(l.lock_path, {.Read, .Write, .Excl, .Create})

		if err != nil {
			switch err {
			case .Exist:
				return false, nil
			case .ENOENT:
				return false, .MissingParent
			case .EACCES:
				return false, .NoPermission
			}
		}
	}

	return true, nil
}

write :: proc(l: ^Lockfile, data: string) -> internal.Error {
	error_on_stale_lock(l) or_return
	os.write_string(l.lock, data)
	return nil
}

commit :: proc(l: ^Lockfile) -> internal.Error {
	error_on_stale_lock(l) or_return
	os.close(l.lock)
	os.rename(l.lock_path, l.file_path)
	l.lock = nil

	return nil
}


@(private)
error_on_stale_lock :: proc(l: ^Lockfile) -> internal.Error {
	if l.lock == nil {
		return .StaleLock
	}
	return nil
}
