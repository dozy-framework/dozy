const std = @import("std");

pub const AddExternalLibrariesStepsResult = struct {
    artifact_path: std.Build.LazyPath,
    external_build_step: *std.Build.Step,
    external_install_step: *std.Build.Step,
};

/// Setup the steps required for building the external libraries
pub fn addExternalLibrariesSteps(b: *std.Build, dep: *std.Build.Dependency) AddExternalLibrariesStepsResult {
    return addExternalLibrariesStepsCommon(b, dep);
}

const CommonResolver = struct {
    fn resolve(b: *std.Build, dep: ?*std.Build.Dependency, path: []const u8) std.Build.LazyPath {
        if (dep) |d| {
            return d.path(path);
        } else {
            return b.path(path);
        }
    }
};

/// This method is needed because our tests also need these external
/// libraries, but they don't use `dep`, unlike normal game executable,
/// which would just be calling `addExternalLibrariesSteps()` normally.
fn addExternalLibrariesStepsCommon(b: *std.Build, dep: ?*std.Build.Dependency) AddExternalLibrariesStepsResult {
    const source_dir = CommonResolver.resolve(b, dep, "external/SDL");
    const build_dir = CommonResolver.resolve(b, dep, "cmake-out/sdl");
    // TODO: use optimize?
    const artifact_dir = CommonResolver.resolve(b, dep, "cmake-out/sdl/Debug");
    const sdl3_artifact_file = CommonResolver.resolve(b, dep, "cmake-out/sdl/Debug/SDL3.dll");

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

    const install_run = b.addInstallFileWithDir(sdl3_artifact_file, .prefix, "bin/SDL3.dll");

    install_run.step.dependOn(&build_run.step);

    const external_build_step = b.step("external_build_step", "Dozy external build step");
    external_build_step.dependOn(&build_run.step);

    const external_install_step = b.step("external_instalL_step", "Dozy external install step");
    external_install_step.dependOn(&install_run.step);

    return .{
        .artifact_path = artifact_dir,
        .external_build_step = external_build_step,
        .external_install_step = external_install_step,
    };
}

/// Copies all external dynamic library artifacts used by dozy
/// to the install directory.
pub fn installExternalLibraries(b: *std.Build, dozy_external_steps: AddExternalLibrariesStepsResult) void {
    b.getInstallStep().dependOn(dozy_external_steps.external_install_step);
}

/// Ensure that the external libraries are built before the
/// game executable is compiled and linked against the libraries.
pub fn linkExternalLibrariesForExe(game_exe: *std.Build.Step.Compile, dozy_external_steps: AddExternalLibrariesStepsResult) void {
    game_exe.step.dependOn(dozy_external_steps.external_build_step);

    game_exe.addLibraryPath(dozy_external_steps.artifact_path);
    game_exe.linkSystemLibrary("SDL3");
    game_exe.linkLibC();
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

    const include_dir = b.path("external/SDL/include");
    mod.addIncludePath(include_dir);

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);

    // our tests are technically also executables, so they also
    // needed the external dependencies to be built and linked
    // just like a normal game executable
    const dozy_external_steps = addExternalLibrariesStepsCommon(b, null);

    linkExternalLibrariesForExe(mod_tests, dozy_external_steps);
    // normally, we will use `installExternalLibraries()` here. However zig test
    // executables are output at `/.zig-cache` instead of `/zig-out`, AND we
    // aren't given the location of the test exe's directory, so the logic of
    // `installExternalLibraries()` won't work here. Instead, let's just add
    // the cmake output folder to PATH
    run_mod_tests.addPathDir(dozy_external_steps.artifact_path.getPath(b));

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);
}
