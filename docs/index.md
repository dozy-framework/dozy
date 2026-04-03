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

3. Update your project's documentation to mention that future clones will require cloning the submodules as well (i.e. `git clone --recurse-submodules <your-repo>`).

## Minimal example

`main.zig`

```zig
const dozy = @import("dozy");

pub fn main() void {
    dozy.start();
}
```
