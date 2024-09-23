const std = @import("std");
const Vector = @import("vector.zig").Vector;

pub const VectorStore = struct {
    allocator: std.mem.Allocator,
    vectors: std.ArrayList(Vector),
    dims: usize,

    pub fn init(allocator: std.mem.Allocator, dims: usize) VectorStore {
        return .{
            .allocator = allocator,
            .vectors = std.ArrayList(Vector).init(allocator),
            .dims = dims,
        };
    }

    pub fn deinit(self: *VectorStore) void {
        for (self.vectors.items) |*vector| {
            vector.deinit(self.allocator);
        }
        self.vectors.deinit();
    }

    pub fn loadVector(self: *VectorStore, data: []const f32) !void {
        try self.checkDims(data);
        const vector = try Vector.init(self.allocator, data);
        try self.vectors.append(vector);
    }

    pub fn loadVectors(self: *VectorStore, data: []const [*]const f32) !void {
        for (data) |vector| {
            const slice = vector[0..self.dims];
            try self.loadVector(slice);
        }
    }

    pub fn checkDims(self: *VectorStore, data: []const f32) !void {
        if (data.len != self.dims) {
            return error.DimensionMismatch;
        }
    }

    pub fn compareFn(_: void, a: [2]f32, b: [2]f32) std.math.Order {
        return std.math.order(b[0], a[0]);
    }

    pub fn pickSmallest(self: *VectorStore, a: usize, b: usize) usize {
        _ = self; // autofix
        return if (a < b) a else b;
    }

    pub fn search(self: *VectorStore, query: Vector, top_k: usize) ![][]f32 {
        var queue = std.PriorityQueue([2]f32, void, compareFn).init(self.allocator, {});
        defer queue.deinit();

        for (self.vectors.items, 0..) |vector, i| {
            const distance = vector.cosineDistance(query);
            try queue.add([2]f32{ distance, @floatFromInt(i) });
        }

        const result_len: usize = self.pickSmallest(top_k, queue.items.len);
        var result = try self.allocator.alloc([]f32, result_len);

        var i: usize = result_len;
        while (i > 0) : (i -= 1) {
            const item = queue.remove();
            const vector_index: usize = @intFromFloat(item[1]);
            const vector = self.vectors.items[vector_index];
            result[i - 1] = vector.data;
        }

        return result;
    }
};

// WIP C-compatible API
export fn vector_store_init(dims: usize) ?*VectorStore {
    const allocator = std.heap.c_allocator;
    const store = allocator.create(VectorStore) catch return null;
    store.* = VectorStore.init(allocator, dims);
    return store;
}

export fn vector_store_deinit(store: *VectorStore) void {
    store.deinit();
    std.heap.c_allocator.destroy(store);
}

export fn vector_store_load_vector(store: *VectorStore, data: [*]const f32) bool {
    const slice = data[0..store.dims];
    store.loadVector(slice) catch return false;
    return true;
}

export fn vector_store_load_vectors(store: *VectorStore, data: [*][*]const f32) bool {
    const slice = data[0..store.dims];
    store.loadVectors(slice) catch return false;
    return true;
}

export fn vector_store_search(store: *VectorStore, query: [*]const f32, top_k: usize) ?[*][*]f32 {
    const slice = query[0..store.dims];
    var query_vector = Vector.init(std.heap.c_allocator, slice) catch return null;
    defer query_vector.deinit(std.heap.c_allocator);

    const result = store.search(query_vector, top_k) catch return null;

    for (result) |*vector| {
        std.debug.print("{d}\n", .{vector});
    }

    const result_ptr = std.heap.c_allocator.alloc([*]f32, result.len) catch return null;
    for (result, 0..) |vector, i| {
        result_ptr[i] = vector.ptr;
    }
    return result_ptr.ptr;
}
