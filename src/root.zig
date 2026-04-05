const std = @import("std");
const sdl = @import("external/sdl.zig").sdl;

pub fn start() void {
    std.log.info("Hello from dozy!", .{});

    // TODO: actual implementation
    if (sdl.SDL_Init(sdl.SDL_INIT_VIDEO)) {
        std.log.info("SDL init successful!", .{});
        sdl.SDL_Quit();
    } else {
        std.log.err("SDL init failed! Message: {s}", .{sdl.SDL_GetError()});
    }
}

// TODO: add actual tests
test "dummy test" {
    try std.testing.expect(3 + 7 == 10);
}
