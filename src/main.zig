const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

fn loop(renderer: *c.SDL_Renderer) void {
    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_QUIT => {
                    quit = true;
                },
                else => {},
            }
        }

        draw(renderer);
        // update();
    }
}

// fn update(deltatime: f64) void {}

fn draw(renderer: *c.SDL_Renderer) void {
    _ = c.SDL_RenderClear(renderer);

    var rect: c.SDL_Rect = .{ .x = 250, .y = 150, .w = 200, .h = 200 };

    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    _ = c.SDL_RenderDrawRect(renderer, &rect);

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);

    _ = c.SDL_RenderPresent(renderer);
}

pub fn main() !void {
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    const screen = c.SDL_CreateWindow("Uni Fileexplorer", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 800, 600, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, 0) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    loop(renderer);
}
