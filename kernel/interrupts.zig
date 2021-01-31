extern fn inb(port: u16) u8;
extern fn outb(port: u16, byte: u8) void;

pub extern fn enable_irqs() void;
pub extern fn disable_irqs() void;

const PRIMARY_PIC_COMMAND = 0x20;
const PRIMARY_PIC_DATA = 0x21;
const CHILD_PIC_COMMAND = 0xA0;
const CHILD_PIC_DATA = 0xA1;

const END_OF_INTERRUPT = 0x20;

pub fn init() void {
    outb(PRIMARY_PIC_COMMAND, 0x11); // Reprogram
    outb(PRIMARY_PIC_DATA, 0x20); // interrupt 0x20
    outb(PRIMARY_PIC_DATA, 0x04); // child PIC one line 2
    outb(PRIMARY_PIC_DATA, 0x01); // 8086 mode
    outb(PRIMARY_PIC_DATA, 0xFF); // mask all interrupts
    outb(CHILD_PIC_COMMAND, 0x11); // Reprogram
    outb(CHILD_PIC_DATA, 0x28); // interrupt 0x28
    outb(CHILD_PIC_DATA, 0x02); // ?
    outb(CHILD_PIC_DATA, 0x01); // 8086 mode
    outb(CHILD_PIC_DATA, 0xFF); // mask all interrupts

    unmask(2); // cascade irq
}

pub fn mask(irq: u4) void {
    if (irq > 8) {
        const l = @intCast(u3, irq - 8);
        var new_mask = inb(CHILD_PIC_DATA);
        new_mask |= (@as(u8, 1) << l);
        outb(CHILD_PIC_DATA, new_mask);
    } else {
        const l = @intCast(u3, irq);
        var new_mask = inb(PRIMARY_PIC_DATA);
        new_mask |= (@as(u8, 1) << l);
        outb(PRIMARY_PIC_DATA, new_mask);
    }
}

pub fn unmask(irq: u4) void {
    if (irq > 8) {
        const l = @intCast(u3, irq - 8);
        var new_mask = inb(CHILD_PIC_DATA);
        new_mask &= ~(@as(u8, 1) << l);
        outb(CHILD_PIC_DATA, new_mask);
    } else {
        const l = @intCast(u3, irq);
        var new_mask = inb(PRIMARY_PIC_DATA);
        new_mask &= ~(@as(u8, 1) << l);
        outb(PRIMARY_PIC_DATA, new_mask);
    }
}

pub const Frame = extern struct {
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
