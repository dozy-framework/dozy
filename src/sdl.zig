const std = @import("std");

/// Direct access to SDL's C functions, constants, macros, etc.
pub const csdl = @cImport({
    // don't use SDL2 compat-layer functions, just use SDL3
    @cDefine("SDL_DISABLE_OLD_NAMES", {});

    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_revision.h"); // versioning

    // we are using Zig's main(), so don't let SDL overwrite main()
    @cDefine("SDL_MAIN_HANDLED", {});
    @cInclude("SDL3/SDL_main.h");
});

/// Representation of SDL library version number.
pub const SdlVersion = struct {
    major: i32,
    minor: i32,
    micro: i32,
};

/// Get the version number of the SDL that was compiled together
/// with dozy.
pub fn getSdlCompiledVersion() SdlVersion {
    return convertVersionNumberToSdlVersion(csdl.SDL_VERSION);
}

/// Get the version number of the SDL that is actually running
/// on the system (i.e. the actual dynamic library's version).
pub fn getSdlLinkedVersion() SdlVersion {
    return convertVersionNumberToSdlVersion(csdl.SDL_GetVersion());
}

fn convertVersionNumberToSdlVersion(number: c_int) SdlVersion {
    return .{
        .major = csdl.SDL_VERSIONNUM_MAJOR(number),
        .minor = csdl.SDL_VERSIONNUM_MINOR(number),
        .micro = csdl.SDL_VERSIONNUM_MICRO(number),
    };
}

test "number to sdl version conversion" {
    try std.testing.expectEqual(SdlVersion{
        .major = 1,
        .minor = 2,
        .micro = 3,
    }, convertVersionNumberToSdlVersion(1002003));
}

/// Check if there could be potential issues due to mismatch between
/// what SDL version was compiled with, and the acutal linked version.
///
/// Refer to https://wiki.libsdl.org/SDL3/README-versions.
pub fn isLinkedVersionCompatible(linked: SdlVersion, compiled: SdlVersion) bool {
    if (linked.major != compiled.major) {
        return false;
    }

    if (linked.minor < compiled.minor) {
        return false;
    }

    if (linked.minor == compiled.minor and linked.micro < compiled.micro) {
        return false;
    }

    return true;
}

test "linked version compatibility" {
    // same version number
    try std.testing.expect(isLinkedVersionCompatible(.{
        .major = 3,
        .minor = 1,
        .micro = 2,
    }, .{
        .major = 3,
        .minor = 1,
        .micro = 2,
    }));

    // major version number jumps are not acceptable
    try std.testing.expect(!isLinkedVersionCompatible(.{
        .major = 2,
        .minor = 0,
        .micro = 0,
    }, .{
        .major = 3,
        .minor = 0,
        .micro = 0,
    }));
    try std.testing.expect(!isLinkedVersionCompatible(.{
        .major = 4,
        .minor = 0,
        .micro = 0,
    }, .{
        .major = 3,
        .minor = 0,
        .micro = 0,
    }));

    // minor version cannot be lower
    try std.testing.expect(!isLinkedVersionCompatible(.{
        .major = 3,
        .minor = 3,
        .micro = 6,
    }, .{
        .major = 3,
        .minor = 4,
        .micro = 5,
    }));
    // ok if minor version is higher
    try std.testing.expect(isLinkedVersionCompatible(.{
        .major = 3,
        .minor = 5,
        .micro = 0,
    }, .{
        .major = 3,
        .minor = 4,
        .micro = 5,
    }));

    // if minor versions are the same, a lower micro number is not ok
    // ok if minor version is higher
    try std.testing.expect(!isLinkedVersionCompatible(.{
        .major = 3,
        .minor = 4,
        .micro = 0,
    }, .{
        .major = 3,
        .minor = 4,
        .micro = 5,
    }));
    // if minor versions are the same, a higher micro number is ok
    try std.testing.expect(isLinkedVersionCompatible(.{
        .major = 3,
        .minor = 4,
        .micro = 6,
    }, .{
        .major = 3,
        .minor = 4,
        .micro = 5,
    }));
}

/// Check whether SDL version indicates pre-release.
///
/// See https://wiki.libsdl.org/SDL3/README-versions for definition of pre-release.
pub fn isLinkedVersionPrerelease(linked_version: SdlVersion) bool {
    return @rem(linked_version.minor, 2) == 1 or @rem(linked_version.micro, 2) == 1;
}

test "version prerelease check" {
    // See https://wiki.libsdl.org/SDL3/README-versions for definition of pre-release.

    // does not affect major
    try std.testing.expect(!isLinkedVersionPrerelease(.{
        .major = 2,
        .minor = 0,
        .micro = 0,
    }));
    try std.testing.expect(!isLinkedVersionPrerelease(.{
        .major = 3,
        .minor = 0,
        .micro = 0,
    }));

    // minor and micro divisible by 2 = production
    try std.testing.expect(!isLinkedVersionPrerelease(.{
        .major = 3,
        .minor = 2,
        .micro = 2,
    }));
    // minor not divisible by 2 = pre-release
    try std.testing.expect(isLinkedVersionPrerelease(.{
        .major = 3,
        .minor = 1,
        .micro = 2,
    }));
    // micro not divisible by 2 = pre-release
    try std.testing.expect(isLinkedVersionPrerelease(.{
        .major = 3,
        .minor = 2,
        .micro = 1,
    }));
    // both minor and micro not divisible by 2 = pre-release
    try std.testing.expect(isLinkedVersionPrerelease(.{
        .major = 3,
        .minor = 1,
        .micro = 1,
    }));
}
