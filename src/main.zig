const std = @import("std");
const VectorStore = @import("vector_store.zig").VectorStore;
const Vector = @import("vector.zig").Vector;

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    var vector_store = VectorStore.init(allocator, 3);
    defer vector_store.deinit();
    std.debug.print("Initialized VectorStore\n", .{});

    try vector_store.loadVector(&[_]f32{ 0.1, 0.2, 0.3 });
    std.debug.print("Loaded vector 1\n", .{});
    try vector_store.loadVector(&[_]f32{ 0.4, 0.5, 0.6 });
    std.debug.print("Loaded vector 2\n", .{});
    try vector_store.loadVector(&[_]f32{ 0.7, 0.8, 0.9 });
    std.debug.print("Loaded vector 3\n", .{});

    var query = try Vector.init(allocator, &[_]f32{ 0.35, 0.45, 0.55 });
    defer query.deinit(allocator);
    std.debug.print("Initialized Query Vector\n", .{});

    const top_k = 3;
    std.debug.print("Performing search with top_k={}\n", .{top_k});
    const results = try vector_store.search(query, top_k);
    defer allocator.free(results);

    std.debug.print("Search Results: {any}\n", .{results});
}
