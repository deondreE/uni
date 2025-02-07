const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

pub const Widget = struct {
    rect: c.SDL_Rect,
    render: fn (*c.SDL_Renderer, *Widget) void,
    next: *Widget,
};
