const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const curve = @import("./ui/curve.zig");

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
    // var rect: c.SDL_Rect = .{ .x = 250, .y = 150, .w = 200, .h = 200 };

    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    _ = c.SDL_RenderClear(renderer);
    //  _ = c.SDL_RenderDrawRect(renderer, &rect);

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);
    //curve.drawQuadraticBezierCurve(renderer, .{ 100.0, 500.0 }, .{ 400.0, 100.0 }, .{ 700.0, 500.0 }, 120);
    curve.drawCubicBezierCurve(renderer, .{ 100.0, 500.0 }, .{ 200.0, 100.0 }, .{ 600.0, 100.0 }, .{ 700.0, 500.0 }, 500);

    _ = c.SDL_RenderPresent(renderer);
    _ = c.SDL_Delay(16);
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    if (c.SDL_Init(c.SDL_INIT_VIDEO) != 0) {
        c.SDL_Log("Unable to initialize SDL: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    }
    defer c.SDL_Quit();

    // TTF THINGS
    const file = try std.fs.cwd().openFile("Roboto-Regular.ttf", .{});
    defer file.close();

    const file_size = (try file.metadata()).size();
    const font_data = try allocator.alloc(u8, file_size);
    defer allocator.free(font_data);

    _ = try file.readAll(font_data);

    const num_tables = std.mem.readInt(u16, font_data[4..6], .big);
    std.debug.print("Number of tables: {}\n", .{num_tables});

    const screen = c.SDL_CreateWindow("Uni Fileexplorer", c.SDL_WINDOWPOS_UNDEFINED, c.SDL_WINDOWPOS_UNDEFINED, 800, 600, c.SDL_WINDOW_OPENGL) orelse
        {
        c.SDL_Log("Unable to create window: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyWindow(screen);

    const renderer = c.SDL_CreateRenderer(screen, -1, c.SDL_RENDERER_ACCELERATED) orelse {
        c.SDL_Log("Unable to create renderer: %s", c.SDL_GetError());
        return error.SDLInitializationFailed;
    };
    defer c.SDL_DestroyRenderer(renderer);

    loop(renderer);
}
