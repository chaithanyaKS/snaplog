package author

import "core:fmt"
import "core:strings"
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
	buf := strings.builder_make()

	defer strings.builder_destroy(&buf)
	now := time.now()
	unix_time := time.to_unix_seconds(now)

	return fmt.sbprintf(&buf, "%s <%s> %d", a.name, a.email, unix_time)
}
