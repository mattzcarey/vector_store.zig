const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "vector_store",
        .root_source_file = b.path("src/vector_store.zig"),
        .target = target,
        .optimize = optimize,
        .link_libc = true,
    });
    b.installArtifact(lib);

    const exe = b.addExecutable(.{
        .name = "run_main",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_cmd = b.addRunArtifact(exe);
    b.step("run_main", "Run the main executable").dependOn(&run_cmd.step);
    b.default_step.dependOn(&run_cmd.step);
}
