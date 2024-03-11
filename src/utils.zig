const std = @import("std");
const py = @import("pydust");
const Endian = std.builtin.Endian;

pub const ERROR_INCORRECT_LENGTH_OF_BYTES = "One should provide {d} bytes.";
pub const ERROR_UNKNOWN_ENDIAN = "One should specify either big or little endian.";
pub const ERROR_NON_CANONICAL = "One should provide canonical bytes.";
pub const ERROR_IDENTITY_ELEMENT = "The result is the identity element.";
pub const ERROR_ENCODING = "The provided bytes are not in Sec1 encoding.";
pub const ERROR_NOT_SQUARE = "The provided bytes are not square.";
pub const ERROR_WEAKPUBLICKEY = "ERROR_WEAKPUBLICKEY";

pub fn string_to_endian(string: []const u8) !Endian {
    if (std.mem.eql(u8, string, "big")) {
        return .Big;
    }
    if (std.mem.eql(u8, string, "little")) {
        return .Little;
    }
    return error.UnknownEndian;
}

pub fn give_endian_or_reject(_endian: py.PyString) !Endian {
    const _endian_str = try _endian.asSlice();
    const endian = string_to_endian(_endian_str) catch |err| switch (err) {
        error.UnknownEndian => {
            return py.ValueError.raise(ERROR_UNKNOWN_ENDIAN);
        },
    };
    return endian;
}
