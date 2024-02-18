const std = @import("std");
const testing = std.testing;
const secp256k1 = std.crypto.ecc.Secp256k1;
const py = @import("pydust");

pub const BasePoint = py.class(struct {
    pub const actual = secp256k1.basePoint;

    pub fn affine_coordinates() !py.PyTuple {
        const x_bytes: py.PyBytes = try py.PyBytes.create(
            &actual.x.toBytes(.Big),
        );
        const y_bytes: py.PyBytes = try py.PyBytes.create(
            &actual.y.toBytes(.Big),
        );
        const int: py.PyLong = try py.PyLong.create(0);
        const x = try int.obj.call(
            py.PyLong,
            "from_bytes",
            .{x_bytes},
            .{},
        );
        const y = try int.obj.call(
            py.PyLong,
            "from_bytes",
            .{y_bytes},
            .{},
        );
        return try py.PyTuple.create(.{ x, y });
    }
});

comptime {
    py.rootmodule(@This());
}
