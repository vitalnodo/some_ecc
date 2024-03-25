const std = @import("std");
const testing = std.testing;
const curve = std.crypto.ecc.Edwards25519;
const py = @import("pydust");
const utils = @import("utils.zig");

pub const Scalar = py.class(struct {
    const Self = @This();
    scalar: curve.scalar.Scalar,

    fn give_scalar_or_reject_bytes(
        comptime len: usize,
        _bytes: py.PyBytes,
    ) !curve.scalar.Scalar {
        if (try _bytes.length() != len) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{len},
            );
        }
        const bytes = (try _bytes.asSlice())[0..len].*;
        const f = blk: {
            switch (len) {
                32 => break :blk curve.scalar.Scalar.fromBytes,
                64 => break :blk curve.scalar.Scalar.fromBytes64,
                else => unreachable,
            }
        };
        const scalar = f(bytes);
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
        );
        self.* = .{
            .scalar = scalar,
        };
        return self;
    }

    pub fn to_bytes(
        self: *Self,
    ) !py.PyBytes {
        const bytes = self.scalar.toBytes();
        return try py.PyBytes.create(&bytes);
    }

    pub fn __invert__(self: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.invert() });
    }

    pub fn is_zero(self: *const Self) !py.PyBool {
        return py.PyBool.create(self.scalar.isZero());
    }

    pub fn __mul__(self: *const Self, other: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.mul(other.scalar) });
    }

    pub fn random() !*Self {
        return py.init(Self, .{ .scalar = curve.scalar.Scalar.random() });
    }

    pub fn sq(self: *const Self) !*Self {
        return py.init(Self, .{ .scalar = self.scalar.sq() });
    }

    pub fn add(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 32 or try args.b.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const b_slice = (try args.b.asSlice())[0..32].*;
        const res = curve.scalar.add(
            a_slice,
            b_slice,
        );
        return py.PyBytes.create(&res);
    }

    pub fn clamp(args: struct {
        a: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        var a_slice = (try args.a.asSlice())[0..32].*;
        curve.scalar.clamp(
            &a_slice,
        );
        return py.PyBytes.create(&a_slice);
    }

    pub fn mul(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 32 or try args.b.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const b_slice = (try args.b.asSlice())[0..32].*;
        const res = curve.scalar.mul(
            a_slice,
            b_slice,
        );
        return py.PyBytes.create(&res);
    }

    pub fn mul8(args: struct {
        a: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const res = curve.scalar.mul8(
            a_slice,
        );
        return py.PyBytes.create(&res);
    }

    pub fn mul_add(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
        c: py.PyBytes,
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
        const res = curve.scalar.mulAdd(
            a_slice,
            b_slice,
            c_slice,
        );
        return py.PyBytes.create(&res);
    }

    pub fn neg(args: struct {
        a: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const res = curve.scalar.neg(
            a_slice,
        );
        return py.PyBytes.create(&res);
    }

    pub fn reduce(args: struct {
        a: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const res = curve.scalar.reduce(
            a_slice,
        );
        return py.PyBytes.create(&res);
    }

    pub fn reduce64(args: struct {
        a: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 64) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{64},
            );
        }
        const a_slice = (try args.a.asSlice())[0..64].*;
        const res = curve.scalar.reduce64(
            a_slice,
        );
        return py.PyBytes.create(&res);
    }

    pub fn reject_noncanonical(args: struct {
        a: py.PyBytes,
    }) !void {
        if (try args.a.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        _ = curve.scalar.rejectNonCanonical(
            a_slice,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ValueError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
    }

    pub fn sub(args: struct {
        a: py.PyBytes,
        b: py.PyBytes,
    }) !py.PyBytes {
        if (try args.a.length() != 32 or try args.b.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const a_slice = (try args.a.asSlice())[0..32].*;
        const b_slice = (try args.b.asSlice())[0..32].*;
        const res = curve.scalar.sub(
            a_slice,
            b_slice,
        );
        return py.PyBytes.create(&res);
    }
});

pub const Point = py.class(struct {
    const Self = @This();
    actual: curve,

    pub fn __add__(self: *const Self, other: *const Self) !*Self {
        return py.init(Self, .{
            .actual = self.actual.add(other.actual),
        });
    }

    pub fn clamped_mul(self: *const Self, args: struct {
        _bytes: py.PyBytes,
    }) !*Self {
        const scalar = (try args._bytes.asSlice())[0..32].*;
        const res = self.actual.clampedMul(
            scalar,
        ) catch |err| switch (err) {
            error.IdentityElement => {
                return py.ArithmeticError.raise(utils.ERROR_IDENTITY_ELEMENT);
            },
            error.WeakPublicKey => {
                return py.ArithmeticError.raise(utils.ERROR_WEAKPUBLICKEY);
            },
        };
        return py.init(Self, .{
            .actual = res,
        });
    }

    pub fn clear_cofactor(self: *const Self) !*Self {
        return py.init(Self, .{
            .actual = self.actual.clearCofactor(),
        });
    }

    pub fn dbl(self: *const Self) !*Self {
        return py.init(Self, .{
            .actual = self.actual.dbl(),
        });
    }

    // elligator2

    pub fn from_bytes(args: struct { s: py.PyBytes }) !*Self {
        const res = curve.fromBytes(
            (try args.s.asSlice())[0..32].*,
        ) catch |err| switch (err) {
            error.InvalidEncoding => {
                return py.ValueError.raise(utils.ERROR_ENCODING);
            },
        };
        return py.init(Self, .{ .actual = res });
    }

    pub fn from_hash(args: struct { s: py.PyBytes }) !*Self {
        if (try args.s.length() != 64) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{64},
            );
        }
        const res = curve.fromHash(
            (try args.s.asSlice())[0..64].*,
        );
        return py.init(Self, .{ .actual = res });
    }

    pub fn mul(
        self: *const Self,
        args: struct { s: py.PyBytes },
    ) !*Self {
        if (try args.s.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const s_slice = (try args.s.asSlice())[0..32].*;
        const res = self.actual.mul(
            s_slice,
        ) catch |err| switch (err) {
            error.IdentityElement => {
                return py.ArithmeticError.raise(utils.ERROR_IDENTITY_ELEMENT);
            },
            error.WeakPublicKey => {
                return py.ArithmeticError.raise(utils.ERROR_WEAKPUBLICKEY);
            },
        };
        return py.init(Self, .{ .actual = res });
    }

    pub fn mul_double_base_public(p1: *const Self, args: struct {
        p2: *const Self,
        s1_: py.PyBytes,
        s2_: py.PyBytes,
    }) !*Self {
        if (try args.s1_.length() != 32 or try args.s2_.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const s1_slice = (try args.s1_.asSlice())[0..32].*;
        const s2_slice = (try args.s2_.asSlice())[0..32].*;
        const res = curve.mulDoubleBasePublic(
            p1.actual,
            s1_slice,
            args.p2.actual,
            s2_slice,
        ) catch |err| switch (err) {
            error.IdentityElement => {
                return py.ArithmeticError.raise(utils.ERROR_IDENTITY_ELEMENT);
            },
            error.WeakPublicKey => {
                return py.ArithmeticError.raise(utils.ERROR_WEAKPUBLICKEY);
            },
        };
        return py.init(Self, .{ .actual = res });
    }

    // mulMulti

    pub fn mul_public(
        self: *const Self,
        args: struct { s: py.PyBytes },
    ) !*Self {
        if (try args.s.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        const s_slice = (try args.s.asSlice())[0..32].*;
        const res = self.actual.mulPublic(
            s_slice,
        ) catch |err| switch (err) {
            error.IdentityElement => {
                return py.ArithmeticError.raise(utils.ERROR_IDENTITY_ELEMENT);
            },
            error.WeakPublicKey => {
                return py.ArithmeticError.raise(utils.ERROR_WEAKPUBLICKEY);
            },
        };
        return py.init(Self, .{ .actual = res });
    }

    pub fn __neg__(self: *const Self) !*Self {
        return py.init(Self, .{ .actual = self.actual.neg() });
    }

    pub fn reject_identity(self: *const Self) !void {
        _ = self.actual.rejectIdentity() catch |err| switch (err) {
            error.IdentityElement => {
                return py.ArithmeticError.raise(utils.ERROR_IDENTITY_ELEMENT);
            },
        };
    }

    pub fn reject_low_order(self: *const Self) !void {
        _ = self.actual.rejectLowOrder() catch |err| switch (err) {
            error.WeakPublicKey => {
                return py.ArithmeticError.raise(utils.ERROR_WEAKPUBLICKEY);
            },
        };
    }

    pub fn reject_noncanonical(args: struct { s: py.PyBytes }) !void {
        if (try args.s.length() != 32) {
            return py.ValueError.raiseComptimeFmt(
                utils.ERROR_INCORRECT_LENGTH_OF_BYTES,
                .{32},
            );
        }
        _ = curve.rejectNonCanonical(
            (try args.s.asSlice())[0..32].*,
        ) catch |err| switch (err) {
            error.NonCanonical => {
                return py.ArithmeticError.raise(utils.ERROR_NON_CANONICAL);
            },
        };
    }

    pub fn __sub__(self: *const Self, other: *const Self) !*Self {
        return py.init(Self, .{
            .actual = self.actual.sub(other.actual),
        });
    }

    pub fn to_bytes(self: *const Self) !py.PyBytes {
        return py.PyBytes.create(&self.actual.toBytes());
    }
});

pub const BasePoint = py.class(struct {
    const Self = @This();
    point: Point,

    pub fn __init__(self: *Self) !void {
        self.* = .{
            .point = .{ .actual = curve.basePoint },
        };
    }
});

comptime {
    py.rootmodule(@This());
}
