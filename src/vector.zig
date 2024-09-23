const std = @import("std");

pub const Vector = struct {
    data: []f32,

    pub fn init(allocator: std.mem.Allocator, data: []const f32) !Vector {
        const size = data.len;
        const vec_data = try allocator.alloc(f32, size);
        @memcpy(vec_data, data);
        return Vector{ .data = vec_data };
    }

    pub fn deinit(self: Vector, allocator: std.mem.Allocator) void {
        allocator.free(self.data);
    }

    pub fn dot(self: Vector, other: Vector) f32 {
        var result: f32 = 0.0;
        for (self.data, 0..) |x, i| {
            result += x * other.data[i];
        }
        return result;
    }

    pub fn norm(self: Vector) f32 {
        var result: f32 = 0.0;
        for (self.data) |x| {
            result += x * x;
        }
        return std.math.sqrt(result);
    }

    pub fn cosineDistance(self: Vector, other: Vector) f32 {
        const dot_product = self.dot(other);
        const norm_self = self.norm();
        const norm_other = other.norm();
        return 1.0 - (dot_product / (norm_self * norm_other));
    }
};
