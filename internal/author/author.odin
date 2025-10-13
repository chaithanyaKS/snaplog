package author

import "core:fmt"
import "core:time"

Author :: struct {
	name:  string,
	email: string,
}

init :: proc(name: string, email: string) -> (author: Author) {
	author.name = name
	author.email = email

	return
}

to_string :: proc(a: ^Author) -> string {
	now := time.now()
	unix_time := time.to_unix_seconds(now)
	return fmt.tprintf("%s <%s> %d", a.name, a.email, unix_time)
}
