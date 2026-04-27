# Dozy - User Documentation

## License

dozy is under [MIT License](../LICENSE).

## Prerequisites

* Zig (version: v0.16.0)
* Cmake (for SDL)

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
const std = @import("std");
const dozy = @import("dozy");

pub fn build(b: *std.Build) void {
    // ...

    // add dozy as a dependency
    const dozy_dep = b.dependency("dozy", .{
        .target = target,
        .optimize = optimize,
    });
    const dozy_mod = dozy_dep.module("dozy");

    const game_mod = b.addModule("game", .{ 
        // ...
        .imports = &.{
            // game mod contains all game logic, so
            // the import to dozy needs to be setup
            .{ .name = "dozy", .module = dozy_mod },

            // ...
        }
    });

    const game_exe = b.addExecutable(.{
        .name = "entry",
        .root_module = b.createModule(.{
            // ...
            .imports = &.{
                // game entry just calls the dozy entry logic,
                // so it needs the import to dozy too
                .{ .name = "dozy", .module = dozy_mod },

                // ...
            },
        }),
    });

    // dozy uses external libraries for some of the features,
    // which also needs to be built, their artifacts linked
    // and copied to the correct location
    const dozy_external_steps = dozy.addExternalLibrariesSteps(b, dozy_dep);

    // ensure that the external libraries are built before the
    // game executable is compiled and linked against the libraries
    dozy.linkExternalLibrariesForExe(game_exe, dozy_external_steps);
    // copies all external dynamic library artifacts used by dozy
    // to the install directory
    dozy.installExternalLibraries(b, dozy_external_steps);

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

## Including license notices in projects

dozy and its dependencies usually have license notices. To cover all license notices, grep all files in this repo that has `LICENSE`, `OFL` etc in its name.
