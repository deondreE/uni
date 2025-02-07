const c = @cImport({
    @cInclude("SDL2/SDL.h");
});

/// Draws a quadratic Bézier curve using SDL2's renderer.
/// The function computes the points along the curve using the quadratic Bézier curve formula:
///
/// `B(t) = (1 - t)^2 * P0 + 2 * (1 - t) * t * P1 + t^2 * P2`
pub fn drawQuadraticBezierCurve(renderer: *c.SDL_Renderer, p0: [2]f32, p1: [2]f32, p2: [2]f32, steps: usize) void {
    var t: f32 = 0.0;
    const dt: f32 = 1.0 / @as(f32, @floatFromInt(steps));

    var prev_x = p0[0];
    var prev_y = p0[1];

    var i: usize = 0;
    while (i <= steps) : (i += 1) {
        const u: f32 = 1.0 - t;
        const tt: f32 = t * t;
        const uu: f32 = u * u;

        const x: f32 = uu * p0[0] + 2.0 * u * t * p1[0] + tt * p2[0];
        const y: f32 = uu * p0[1] + 2.0 * u * t * p1[1] + tt * p2[1];

        // Use sub-pixel precision to avoid pixelated lines
        const final_x = @as(f32, x + 0.5); // rounding to nearest integer
        const final_y = @as(f32, y + 0.5);

        _ = c.SDL_RenderDrawLine(renderer, @intFromFloat(prev_x), @intFromFloat(prev_y), @intFromFloat(final_x), @intFromFloat(final_y));

        prev_x = final_x;
        prev_y = final_y;
        t += dt;
    }
}

/// Draws a cubic Bézier curve using SDL2's renderer.
///
/// The function computes the points along the cubic Bézier curve using the following formula:
///
/// ` B(t) = (1 - t)^3 * P0 + 3 * (1 - t)^2 * t * P1 + 3 * (1 - t) * t^2 * P2 + t^3 * P3 `
pub fn drawCubicBezierCurve(renderer: *c.SDL_Renderer, p0: [2]f32, p1: [2]f32, p2: [2]f32, p3: [2]f32, steps: usize) void {
    var t: f32 = 0.0;
    const dt: f32 = 1.0 / @as(f32, @floatFromInt(steps));

    var prev_x = p0[0];
    var prev_y = p0[1];

    var i: usize = 0;
    while (i <= steps) : (i += 1) {
        const u: f32 = 1.0 - t;
        const tt: f32 = t * t;
        const uu: f32 = u * u;
        const ttt: f32 = tt * t;
        const uuu: f32 = uu * u;

        const x: f32 = uuu * p0[0] + 3.0 * uu * t * p1[0] + 3.0 * u * tt * p2[0] + ttt * p3[0];
        const y: f32 = uuu * p0[1] + 3.0 * uu * t * p1[1] + 3.0 * u * tt * p2[1] + ttt * p3[1];

        // Use sub-pixel precision to avoid pixelated lines
        const final_x = @as(f32, x + 0.5); // rounding to nearest integer
        const final_y = @as(f32, y + 0.5);

        // Draw the line segment using SDL_RenderDrawLine
        _ = c.SDL_RenderDrawLine(renderer, @intFromFloat(prev_x), @intFromFloat(prev_y), @intFromFloat(final_x), @intFromFloat(final_y));

        prev_x = final_x;
        prev_y = final_y;
        t += dt;
    }
}
