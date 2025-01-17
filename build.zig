const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const bx_lib = b.addStaticLibrary(.{
        .name = "bx",
        .target = target,
        .optimize = optimize,
    });
    const bx_mod = bx_lib.root_module;
    bx_mod.addCSourceFiles(.{ .files = &src_files });
    bx_mod.link_libcpp = true;
    bx_mod.addCMacro("BX_CONFIG_DEBUG", "0"); // Release
    bx_mod.addIncludePath(b.path("include"));
    bx_mod.addIncludePath(b.path("3rdparty"));

    bx_lib.installHeadersDirectory(b.path("include"), ".", .{
        .include_extensions = &.{ ".h", ".inl" },
    });
    bx_lib.installHeadersDirectory(b.path("include/compat/mingw/"), ".", .{
        .include_extensions = &.{ ".h", ".inl" },
    });
    b.installArtifact(bx_lib);
}

const src_files = [_][]const u8{
    // "src/amalgamated.cpp",
    "src/commandline.cpp",
    "src/debug.cpp",
    "src/mutex.cpp",
    "src/file.cpp",
    "src/bx.cpp",
    "src/os.cpp",
    "src/easing.cpp",
    "src/bounds.cpp",
    "src/string.cpp",
    "src/allocator.cpp",
    "src/semaphore.cpp",
    "src/thread.cpp",
    "src/process.cpp",
    "src/math.cpp",
    "src/filepath.cpp",
    "src/hash.cpp",
    "src/dtoa.cpp",
    "src/settings.cpp",
    "src/timer.cpp",
    "src/crtnone.cpp",
    "src/sort.cpp",
    "src/url.cpp",
};
