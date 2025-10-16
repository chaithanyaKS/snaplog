package internal

import os "core:os/os2"
SnapError :: enum u32 {
	MissingParent,
	NoPermission,
	StaleLock,
	LockDenied,
}

Error :: union {
	SnapError,
	os.Error,
}
