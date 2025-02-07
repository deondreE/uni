const std = @import("std");
const c = @cImport({
    @cInclude("SDL2/SDL.h");
});
const widget = @import("./widgets.zig");

pub const Layout = enum {
    Vertical,
    Horizontal,
};

pub const Container = struct {
    layout: Layout,
    children: []widget.Widget,

    const Self = @This();

    pub fn renderChildren(self: Self, renderer: *c.SDL_Renderer) void {
        var i: usize = 0;
        while (i < self.children.len) {
            const child = self.children[i];
            child.render(renderer, &child);
            i += 1;
        }
    }
};
