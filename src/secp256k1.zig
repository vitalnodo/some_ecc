const std = @import("std");
const testing = std.testing;
const curve = std.crypto.ecc.Secp256k1;
const py = @import("pydust");
const utils = @import("utils.zig");

pub const Scalar = py.class(struct {
    const Self = @This();
    scalar: curve.scalar.Scalar,

    fn give_scalar_or_reject_bytes(
        comptime len: usize,
        _bytes: py.PyBytes,
        _endian: py.PyString,
    ) !curve.scalar.Scalar {
        if (try _bytes.length() != len) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{len},
            );
        }
        const endian = try utils.give_endian_or_reject(_endian);
        const bytes = (try _bytes.asSlice())[0..32].*;
        const scalar = curve.scalar.Scalar.fromBytes(
            bytes,
            endian,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
        return scalar;
    }

    pub fn __init__(self: *@This()) void {
        self.scalar = curve.scalar.Scalar.random();
    }

    pub fn from_bytes(
        self: *Self,
        args: struct { _bytes: py.PyBytes, _endian: py.PyString },
    ) !*Self {
        py.incref(self);
        const scalar = try give_scalar_or_reject_bytes(
            32,
            args._bytes,
            args._endian,
        );
        self.* = .{
            .scalar = scalar,
        };
        return self;
    }

    pub fn from_bytes48(
        self: *Self,
        args: struct { _bytes: py.PyBytes, _endian: py.PyString },
    ) !*Self {
        py.incref(self);
        const scalar = try give_scalar_or_reject_bytes(
            48,
            args._bytes,
            args._endian,
        );
        self.* = .{
            .scalar = scalar,
        };
        return self;
    }

    pub fn from_bytes64(
        self: *Self,
        args: struct { _bytes: py.PyBytes, _endian: py.PyString },
    ) !*Self {
        py.incref(self);
        const scalar = try give_scalar_or_reject_bytes(
            64,
            args._bytes,
            args._endian,
        );
        self.* = .{
            .scalar = scalar,
        };
        return self;
    }

    pub fn to_bytes(
        self: *Self,
        args: struct { _endian: py.PyString },
    ) !py.PyBytes {
        const endian = try utils.give_endian_or_reject(args._endian);
        const bytes = self.scalar.toBytes(endian);
        return try py.PyBytes.create(&bytes);
    }

    pub fn __add__(self: *const Self, other: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.add(other.scalar) });
    }

    pub fn dbl(self: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.dbl() });
    }

    pub fn __eq__(self: *const Self, other: *const Self) !py.PyBool {
        return py.PyBool.create(self.scalar.equivalent(other.scalar));
    }

    pub fn __invert__(self: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.invert() });
    }

    pub fn is_odd(self: *const Self) !py.PyBool {
        return py.PyBool.create(self.scalar.isOdd());
    }

    // is_square

    pub fn is_zero(self: *const Self) !py.PyBool {
        return py.PyBool.create(self.scalar.isZero());
    }

    pub fn __mul__(self: *const Self, other: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.mul(other.scalar) });
    }

    pub fn __neg__(self: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.neg() });
    }

    pub fn random() !*Self {
        return py.init(Self, .{ .scalar = curve.scalar.Scalar.random() });
    }

    // pow

    pub fn sq(self: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.sq() });
    }

    // sqrt

    pub fn __sub__(self: *const Self, other: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.sub(other.scalar) });
    }

    pub fn add(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
        _endian: py.PyString,
    }) !py.PyBytes {
        if (try args.a.length() != 32 or try args.b.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const b_slice = (try args.b.asSlice())[0..32].*;
        const endian = try utils.give_endian_or_reject(args._endian);
        const res = curve.scalar.add(
            a_slice,
            b_slice,
            endian,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
        return py.PyBytes.create(&res);
    }

    pub fn mul(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
        _endian: py.PyString,
    }) !py.PyBytes {
        if (try args.a.length() != 32 or try args.b.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const b_slice = (try args.b.asSlice())[0..32].*;
        const endian = try utils.give_endian_or_reject(args._endian);
        const res = curve.scalar.mul(
            a_slice,
            b_slice,
            endian,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
        return py.PyBytes.create(&res);
    }

    pub fn mul_add(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
        c: py.PyBytes,
        _endian: py.PyString,
    }) !py.PyBytes {
        if (try args.a.length() != 32 or try args.b.length() != 32 or try args.c.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const b_slice = (try args.b.asSlice())[0..32].*;
        const c_slice = (try args.c.asSlice())[0..32].*;
        const endian = try utils.give_endian_or_reject(args._endian);
        const res = curve.scalar.mulAdd(
            a_slice,
            b_slice,
            c_slice,
            endian,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
        return py.PyBytes.create(&res);
    }

    pub fn neg(args: struct {
        a: py.PyBytes,
        _endian: py.PyString,
    }) !py.PyBytes {
        if (try args.a.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const endian = try utils.give_endian_or_reject(args._endian);
        const res = curve.scalar.neg(
            a_slice,
            endian,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
        return py.PyBytes.create(&res);
    }

    pub fn reduce48(args: struct {
        a: py.PyBytes,
        _endian: py.PyString,
    }) !py.PyBytes {
        if (try args.a.length() != 48) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{48},
            );
        }
        const a_slice = (try args.a.asSlice())[0..48].*;
        const endian = try utils.give_endian_or_reject(args._endian);
        const res = curve.scalar.reduce48(
            a_slice,
            endian,
        );
        return py.PyBytes.create(&res);
    }

    // pub fn reduce64(args: struct {
    //     a: py.PyBytes,
    //     _endian: py.PyString,
    // }) !py.PyBytes {
    //     if (try args.a.length() != 64) {
    //         return py.ValueError.raiseComptimeFmt(
    //             utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
    //             .{64},
    //         );
    //     }
    //     const a_slice = (try args.a.asSlice())[0..64].*;
    //     const endian = try utils.give_endian_or_reject(args._endian);
    //     const res = curve.scalar.reduce64(
    //         a_slice,
    //         endian,
    //     );
    //     return py.PyBytes.create(&res);
    // }

    pub fn reject_noncanonical(args: struct {
        a: py.PyBytes,
        _endian: py.PyString,
    }) !void {
        if (try args.a.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const endian = try utils.give_endian_or_reject(args._endian);
        _ = curve.scalar.rejectNonCanonical(
            a_slice,
            endian,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
    }

    pub fn sub(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
        _endian: py.PyString,
    }) !py.PyBytes {
        if (try args.a.length() != 32 or try args.b.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const b_slice = (try args.b.asSlice())[0..32].*;
        const endian = try utils.give_endian_or_reject(args._endian);
        const res = curve.scalar.sub(
            a_slice,
            b_slice,
            endian,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
        return py.PyBytes.create(&res);
    }

    pub fn zero() !*Self {
        return py.init(Self, .{ .scalar = curve.scalar.Scalar.zero });
    }

    pub fn one() !*Self {
        return py.init(Self, .{ .scalar = curve.scalar.Scalar.one });
    }
});

pub const BasePoint = py.class(struct {
    pub const actual = curve.basePoint;

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
