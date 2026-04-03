const std = @import("std");

pub fn start() void {
    std.log.info("Hello from dozy!", .{});

    // TODO: actual implementation
}

// TODO: add actual tests
test "dummy test" {
    try std.testing.expect(3 + 7 == 10);
}
