const std = @import("std");
const interrupts = @import("interrupts.zig");
const serial = @import("serial.zig");

export fn kernel_main() void {
    interrupts.init();
    serial.init();
    print("Hello World from an all-zig kernel\r\n", .{});
    interrupts.unmask(4);
    interrupts.enable_irqs();

    while (true) {}
}

pub fn panic(msg: []const u8, trace: ?*std.builtin.StackTrace) noreturn {
    interrupts.disable_irqs();
    print("panic: {s}\r\n", .{msg});
    while (true) {}
}

export fn c_interrupt_shim(frame: *interrupts.Frame) void {
    print("{}", .{*interrupts.Frame});
}

// =================================

fn print(comptime fmt: []const u8, args: anytype) void {
    const output: serial.Output = undefined;
    output.print(fmt, args) catch return;
}
