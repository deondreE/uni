const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const w = @import("./ui/widgets.zig");
const layout = @import("./ui/layout.zig");
// const curve = @import("./ui/curve.zig");

fn loop(renderer: *c.SDL_Renderer) void {
    var quit = false;
    while (!quit) {
        var event: c.SDL_Event = undefined;
        while (c.SDL_PollEvent(&event) != 0) {
            switch (event.type) {
                c.SDL_WINDOWEVENT => {
                    if (event.window.type == c.SDL_WINDOWEVENT_SIZE_CHANGED) {
                        const new_width = event.window.data1;
                        const new_height = event.window.data2;
                        std.debug.print("Window resized to {}x{}\n", .{ new_width, new_height });
                    }
                },
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
    const WINDOW_WIDTH = 800;
    const WINDOW_HEIGHT = 600;
    const RECT_WIDTH: usize = 25;
    const RECT_HEIGHT: usize = 25;
    const SPACING_X: usize = 10;
    const SPACING_Y: usize = 10;
    const GRID_COLS = WINDOW_WIDTH / RECT_WIDTH;
    const GRID_ROWS = WINDOW_HEIGHT / RECT_HEIGHT;
    // var rect: c.SDL_Rect = .{ .x = 250, .y = 150, .w = 200, .h = 200 };

    _ = c.SDL_SetRenderDrawColor(renderer, 255, 255, 255, 255);
    _ = c.SDL_RenderClear(renderer);
    //  _ = c.SDL_RenderDrawRect(renderer, &rect);

    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 0, 255);

    //curve.drawQuadraticBezierCurve(renderer, .{ 100.0, 500.0 }, .{ 400.0, 100.0 }, .{ 700.0, 500.0 }, 120);
    // curve.drawCubicBezierCurve(renderer, .{ 100.0, 500.0 }, .{ 200.0, 100.0 }, .{ 600.0, 100.0 }, .{ 700.0, 500.0 }, 500);

    for (0..GRID_COLS) |row| {
        for (0..GRID_ROWS) |col| {
            const rect = c.SDL_Rect{
                .x = @intCast(col * (RECT_WIDTH + SPACING_X)),
                .y = @intCast(row * (RECT_HEIGHT + SPACING_Y)),
                .w = RECT_WIDTH,
                .h = RECT_HEIGHT,
            };
            //std.debug.print("Rect at col: {}, row: {} -> x: {}, y: {}\n", .{ col, row, rect.x, rect.y });
            _ = c.SDL_RenderFillRect(renderer, &rect);
        }
    }

    _ = c.SDL_RenderPresent(renderer);
    _ = c.SDL_Delay(1000 / 60);
}

fn renderButton(renderer: *c.SDL_Renderer, widget: *w.Widget) void {
    // Set color for the button (e.g., blue)
    _ = c.SDL_SetRenderDrawColor(renderer, 0, 0, 255, 255);
    _ = c.SDL_RenderFillRect(renderer, &widget.rect);
}

fn createButton(x: i32, y: i32, wi: i32, h: i32) w.Widget {
    return w.Widget{
        .rect = c.SDL_Rect{ .x = x, .y = y, .w = wi, .h = h },
        .render = renderButton,
        .next = null,
    };
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
