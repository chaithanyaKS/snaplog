package author

import "core:fmt"
import "core:time"

Author :: struct {
	name:  string,
	email: string,
	time:  i64,
}

init :: proc(name: string, email: string, time: i64) -> (author: Author) {
	author.name = name
	author.email = email
	author.time = time

	return
}

to_string :: proc(a: ^Author) -> string {
	return fmt.tprintf("%s <%s> %d", a.name, a.email, a.time)
}
