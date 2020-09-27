const std = @import("std");

export fn kernel_main() void {
    print("Hello World from an all-zig kernel\r\n", .{});
    // enable_irqs();
    unreachable;
}

pub fn panic(msg: []const u8, trace: ?*std.builtin.StackTrace) noreturn {
    print("panic: {}\r\n", .{msg});
    while (true) {}
}

export fn c_interrupt_shim(frame: *InterruptFrame) void {
    print("{}", .{*InterruptFrame});
}

// =================================

extern fn inb(port: u16) u8;
extern fn outb(port: u16, byte: u8) void;

extern fn enable_irqs() void;
extern fn disable_irqs() void;

const UART_DATA = 0;
const UART_INTERRUPT_ENABLE = 1;

const UART_BAUD_LOW = 0;
const UART_BAUD_HIGH = 1;
const UART_FIFO_CTRL = 2;
const UART_LINE_CTRL = 3;
const UART_MODEM_CTRL = 4;
const UART_LINE_STATUS = 5;
const UART_MODEM_STATUS = 6;

const SERIAL_PORT = 0x3f8;

fn serial_init() void {
    outb(SERIAL_PORT + UART_BAUD_HIGH, 0x00);
    outb(SERIAL_PORT + UART_LINE_CTRL, 0x80);
    outb(SERIAL_PORT + UART_BAUD_LOW, 0x03);
    outb(SERIAL_PORT + UART_BAUD_HIGH, 0x00);
    outb(SERIAL_PORT + UART_LINE_CTRL, 0x03);
    outb(SERIAL_PORT + UART_FIFO_CTRL, 0xC7);
    outb(SERIAL_PORT + UART_MODEM_CTRL, 0x0B);
}

fn serial_send(byte: u8) void {
    outb(SERIAL_PORT + UART_DATA, byte);
}

fn serial_send_slice(slice: []const u8) void {
    for (slice) |byte| {
        serial_send(byte);
    }
}

const InterruptFrame = extern struct {
    ds: u64,
    r15: u64,
    r14: u64,
    r13: u64,
    r12: u64,
    r11: u64,
    r10: u64,
    r9: u64,
    r8: u64,
    bp: u64,
    di: u64,
    si: u64,
    dx: u64,
    bx: u64,
    cx: u64,
    ax: u64,
    interrupt_number: u64,
    error_code: u64,
    ip: u64,
    cs: u64,
    flags: u64,
    sp: u64,
    ss: u64,
};

const SerialContext = struct {};
const SerialWriteError = error{};

fn serial_write(context: SerialContext, bytes: []const u8) SerialWriteError!usize {
    serial_send_slice(bytes);
    return bytes.len;
}

const SerialOutput = std.io.Writer(SerialContext, SerialWriteError, serial_write);

fn print(comptime fmt: []const u8, args: anytype) void {
    const output: SerialOutput = undefined;
    output.print(fmt, args) catch return;
}
