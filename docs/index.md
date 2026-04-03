# Dozy - User Documentation

## Prerequisites

* Zig (version: v0.15.2)

## Setup dozy in your project

1. Clone dozy as a git submodule:

```sh
git submodule add git@github.com:dozy-framework/dozy.git
```

2. Specify dozy as a dependency in your `build.zig.zon`:

```zig
.{
    .dependencies = .{
        .dozy = .{
            .path = "./dozy",
        }
        // ...
    }
    // ...
}
```

3. In `build.zig`, inject your library to the modules that uses dozy. For example, if you have an entry exe and game lib, both are likely to need dozy as an import.

```zig
pub fn build(b: *std.Build) void {
    // ...

    const dozy_dep = b.dependency("dozy", .{
        .target = target,
        .optimize = optimize,
    });
    const dozy_mod = dozy_dep.module("dozy");

    const game_mod = b.addModule("game", .{ 
        // ...
        .imports = &.{
            .{ .name = "dozy", .module = dozy_mod },
            // ...
        }
    });

    const game_exe = b.addExecutable(.{
        .name = "entry",
        .root_module = b.createModule(.{
            // ...
            .imports = &.{
                .{ .name = "dozy", .module = dozy_mod },
                // ...
            },
        }),
    });

    // ...
}
```

4. (optional) Update your project's documentation to mention that future clones will require cloning the submodules as well (i.e. `git clone --recurse-submodules <your-repo>`).

## Minimal example

`main.zig`

```zig
const dozy = @import("dozy");

pub fn main() void {
    dozy.start();
}
```
