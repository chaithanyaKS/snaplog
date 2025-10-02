package database

import "../blob/"
import "core:crypto/legacy/keccak"
import "core:encoding/hex"
import "core:hash"
import "core:math/rand"
import "core:path/filepath"

import "core:crypto/legacy/sha1"
import "core:fmt"
import os "core:os/os2"
import "core:strings"

import "vendor:zlib"

TEMP_CHARS := [?]u8 {
	'0',
	'1',
	'2',
	'3',
	'4',
	'5',
	'6',
	'7',
	'8',
	'9',
	'A',
	'B',
	'C',
	'D',
	'E',
	'F',
	'G',
	'H',
	'I',
	'J',
	'K',
	'L',
	'M',
	'N',
	'O',
	'P',
	'Q',
	'R',
	'S',
	'T',
	'U',
	'V',
	'W',
	'X',
	'Y',
	'Z',
	'a',
	'b',
	'c',
	'd',
	'e',
	'f',
	'g',
	'h',
	'i',
	'j',
	'k',
	'l',
	'm',
	'n',
	'o',
	'p',
	'q',
	'r',
	's',
	't',
	'u',
	'v',
	'w',
	'x',
	'y',
	'z',
}

Database :: struct {
	db_path: string,
}

init :: proc(db_path: string) -> (db: Database) {
	db.db_path = db_path
	return
}

store :: proc(db: ^Database, blb: ^blob.Blob) {
	sb: strings.Builder
	content := fmt.sbprintf(&sb, "%s %d\x00%s", blb.type, len(blb.data), blb.data)
	blb.oid = generate_hexdigest(transmute([]byte)content)
	write_object(db, blb.oid, content)
}

@(private)
write_object :: proc(db: ^Database, oid: string, data: string) {
	object_path := filepath.join([]string{db.db_path, oid[:2], oid[2:]})
	dirname := filepath.dir(object_path)
	temp_file_name := generate_temp_name()
	temp_path := filepath.join([]string{dirname, temp_file_name})

	if !os.exists(dirname) {
		fmt.println("creating dir: ", dirname)
		os.make_directory(dirname)
	}

	fd, err := os.open(temp_path, {.Read, .Write, .Create, .Excl})
	if err != nil {
		fmt.println("error while opening file ", err)
		return
	}
	defer os.close(fd)
	compressed_data := compress_data(data)
	_, err = os.write(fd, compressed_data)
	if err != nil {
		fmt.println("Error in writing data")
	}

	err = os.rename(temp_path, object_path)

	if err != nil {
		fmt.println("Error in renaming file")
	}
}

@(private)
generate_temp_name :: proc() -> string {
	builder: strings.Builder
	strings.write_string(&builder, "temp_obj_#")
	for _ in 0 ..= 6 {
		ch := rand.choice(TEMP_CHARS[:])
		strings.write_byte(&builder, ch)
	}

	return strings.to_string(builder)
}

@(private)
compress_data :: proc(data: string) -> []byte {
	CHUNK_SIZE :: 16384
	z_stream: zlib.z_stream
	ret := zlib.deflateInit(&z_stream, zlib.BEST_SPEED)
	if ret != zlib.OK {
		fmt.eprintln("Error in initializing zlib defalte")
		return nil
	}
	defer zlib.deflateEnd(&z_stream)
	data_len := len(data)
	out_buf := make([]byte, data_len + 64)

	z_stream.next_in = raw_data(data)
	z_stream.avail_in = u32(data_len)
	z_stream.next_out = &out_buf[0]
	z_stream.avail_out = u32(len(out_buf))


	ret = zlib.deflate(&z_stream, zlib.FINISH)
	if ret != zlib.STREAM_END {
		fmt.println("stream not finished")
	}

	compressed_size := len(out_buf) - int(z_stream.avail_out)

	return out_buf[:compressed_size]
}

@(private)
generate_hexdigest :: proc(data: []byte) -> string {
	ctx: sha1.Context
	hash := make([]byte, 20)
	sha1.init(&ctx)
	sha1.update(&ctx, data)
	sha1.final(&ctx, hash)
	hexdigest := hex.encode(hash)

	return string(hexdigest)
}
