const std = @import("std");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("bx", .{
        .target = target,
        .optimize = optimize,
    });
    const lib = b.addStaticLibrary(.{
        .name = "bx",
        .root_module = mod,
    });

    const t = target.result;
    const is_debug = mod.optimize == .Debug;

    mod.addCSourceFiles(.{
        .flags = &cpp_flags,
        .files = &cpp_src,
    });
    mod.link_libcpp = true;

    mod.addCMacro("__STDC_LIMIT_MACROS", "");
    mod.addCMacro("__STDC_FORMAT_MACROS", "");
    mod.addCMacro("__STDC_CONSTANT_MACROS", "");
    mod.addCMacro(if (is_debug) "_DEBUG" else "NDEBUG", "");
    mod.addCMacro("BX_CONFIG_DEBUG", if (is_debug) "1" else "0");

    mod.addIncludePath(b.path("include"));
    mod.addIncludePath(b.path("3rdparty"));
    switch (t.os.tag) {
        .windows => {
            mod.addCMacro("WIN32", "1");
            switch (t.abi) {
                .gnu => {
                    mod.addIncludePath(b.path("include/compat/mingw"));
                    mod.addCMacro("MINGW_HAS_SECURE_API", "1");
                },
                .msvc => mod.addIncludePath(b.path("include/compat/msvc")),
                else => {},
            }
        },
        .linux => mod.addIncludePath(b.path("include/compat/linux")),
        .macos => mod.addIncludePath(b.path("include/compat/osx")),
        .freebsd => mod.addIncludePath(b.path("include/compat/freebsd")),
        .ios => mod.addIncludePath(b.path("include/compat/ios")),
        else => {},
    }

    lib.installHeadersDirectory(b.path("include"), ".", .{
        .include_extensions = &.{ ".h", ".inl" },
    });
    b.installArtifact(lib);
}

const cpp_flags = [_][]const u8{
    "-std=c++17",
    "-fno-sanitize=undefined",
};

const cpp_src = [_][]const u8{
    "src/amalgamated.cpp",
};
