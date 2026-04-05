pub const sdl = @cImport({
    // don't use SDL2 compat-layer functions, just use SDL3
    @cDefine("SDL_DISABLE_OLD_NAMES", {});

    @cInclude("SDL3/SDL.h");
    @cInclude("SDL3/SDL_revision.h"); // versioning

    // we are using Zig's main(), so don't let SDL overwrite main()
    @cDefine("SDL_MAIN_HANDLED", {});
    @cInclude("SDL3/SDL_main.h");
});
