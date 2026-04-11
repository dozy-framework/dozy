const std = @import("std");
const sdl = @import("sdl.zig");

pub fn start() void {
    reportVersions();
}

fn reportVersions() void {
    // TODO: report dozy's version
    std.log.info("dozy version: unknown", .{});

    const compiled_version = sdl.getSdlCompiledVersion();
    std.log.info("SDL compiled version: {d}.{d}.{d}", .{ compiled_version.major, compiled_version.minor, compiled_version.micro });

    const linked_version = sdl.getSdlLinkedVersion();
    std.log.info("SDL linked (running) version: {d}.{d}.{d}", .{ linked_version.major, linked_version.minor, linked_version.micro });

    if (!std.meta.eql(linked_version, compiled_version)) {
        if (!sdl.isLinkedVersionCompatible(linked_version, compiled_version)) {
            std.log.warn("SDL linked (running) version is incompatible with compiled version. This may cause unexpected issues.", .{});
        } else {
            std.log.info("SDL linked (running) version and compiled version mismatch, but should be ok, see https://wiki.libsdl.org/SDL3/README-versions", .{});
        }
    }

    if (sdl.isLinkedVersionPrerelease(linked_version)) {
        std.log.warn("SDL linked (running) version is pre-release, use with caution. See: https://wiki.libsdl.org/SDL3/README-versions", .{});
    }
}

test {
    // ensure that tests inside what we imported are also being run
    std.testing.refAllDeclsRecursive(@This());
}
