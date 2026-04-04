const std = @import("std");

pub const SetupExternalLibrariesResult = struct {
    external_build_step: *std.Build.Step,
    external_install_step: *std.Build.Step,
};

pub fn setupExternalLibraries(b: *std.Build, dep: *std.Build.Dependency) SetupExternalLibrariesResult {
    const source_dir = dep.path("external/SDL");
    const build_dir = dep.path("cmake-out/sdl");

    const configure_run = b.addSystemCommand(&.{
        "cmake",
        "-B",
        build_dir.getPath(b),
        "-S",
        source_dir.getPath(b),
    });

    const build_run = b.addSystemCommand(&.{
        "cmake",
        "--build",
        build_dir.getPath(b),
        "-j", // build in parallel
    });

    build_run.step.dependOn(&configure_run.step);

    const install_run = b.addInstallFileWithDir(dep.path("cmake-out/sdl/Debug/SDL3.dll"), .prefix, "bin/SDL3.dll");

    install_run.step.dependOn(&build_run.step);

    const external_build_step = b.step("external_build_step", "Dozy external build step");
    external_build_step.dependOn(&build_run.step);

    const external_install_step = b.step("external_instalL_step", "Dozy external install step");
    external_install_step.dependOn(&install_run.step);

    return .{
        .external_build_step = external_build_step,
        .external_install_step = external_install_step,
    };
}

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    // TODO: `optimize` to be used when building SDL
    _ = b.standardOptimizeOption(.{});

    const mod = b.addModule("dozy", .{
        .root_source_file = b.path("src/root.zig"),
        // needed only for tests
        .target = target,
    });

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
