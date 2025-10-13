package database

import "../blob/"
import "../commit/"
import "../tree/"
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

TEMP_CHARS := [?]byte {
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

store_tree :: proc(db: ^Database, t: ^tree.Tree) {
	content := tree.to_string(t)
	t.oid = generate_hexdigest(transmute([]byte)content)
	write_object(db, t.oid, content)
	fmt.println("tree ", t.oid)
}


store_blob :: proc(db: ^Database, blb: ^blob.Blob) {
	content := blob.to_string(blb)
	blb.oid = generate_hexdigest(transmute([]byte)content)
	write_object(db, blb.oid, content)
	fmt.println("Blob ", blb.oid)
}

store_commit :: proc(db: ^Database, c: ^commit.Commit) {
	content := commit.to_string(c)
	c.oid = generate_hexdigest(transmute([]byte)content)
	write_object(db, c.oid, content)
	fmt.println("commit ", c.oid)
}

store :: proc {
	store_tree,
	store_blob,
	store_commit,
}

@(private)
write_object :: proc(db: ^Database, oid: string, data: string) {
	object_path, o_err := os.join_path([]string{db.db_path, oid[:2], oid[2:]}, context.temp_allocator)
	if o_err != nil {
		fmt.println("error in creating object path", o_err)
	}
	dirname := filepath.dir(object_path, context.temp_allocator)
	temp_file_name := generate_temp_name()
	temp_path, t_err := os.join_path([]string{dirname, temp_file_name}, context.temp_allocator)

	if t_err != nil {
		fmt.println("error in creating temp_path", t_err)
	}

	if !os.exists(dirname) {
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
		fmt.println("Error in writing data", err)
	}

	err = os.rename(temp_path, object_path)

	if err != nil {
		fmt.println("Error in renaming file", err)
	}
}

@(private)
generate_temp_name :: proc() -> string {
	builder := strings.builder_make()
	defer strings.builder_destroy(&builder)
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
	out_buf := make([]byte, data_len + 64, context.temp_allocator)

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
	hash := make([]byte, 20, context.temp_allocator)
	sha1.init(&ctx)
	sha1.update(&ctx, data)
	sha1.final(&ctx, hash)
	hexdigest := hex.encode(hash, context.temp_allocator)

	return string(hexdigest)
}
