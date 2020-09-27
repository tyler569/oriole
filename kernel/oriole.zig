extern fn inb(port: u16) u8;
extern fn outb(port: u16, byte: u8) void;

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

export fn kernel_main() void {
    serial_send_slice("Hello World from an all-zig kernel\r\n");
}

export fn c_interrupt_shim() void {}
