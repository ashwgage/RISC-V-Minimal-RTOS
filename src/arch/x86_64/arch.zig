//! x86_64 (IA-32e) architecture-specific definitions.


// -----------------------------------------------------------------------------
// Low-level I/O operations
// -----------------------------------------------------------------------------

/// Read a byte from an I/O port.
pub inline fn inb(port: u16) u8 {
    return asm volatile ("inb %[port], %[result]"
        : [result] "={al}" (-> u8),
        : [port] "N{dx}" (port),
    );
}

/// Write a byte to an I/O port.
pub inline fn outb(port: u16, value: u8) void {
    asm volatile ("outb %[value], %[port]"
        :
        : [value] "{al}" (value),
          [port] "N{dx}" (port),
    );
}


// -----------------------------------------------------------------------------
// CPU control instructions
// -----------------------------------------------------------------------------

/// Disable interrupts (clear interrupt flag).
pub inline fn cli() void {
    asm volatile ("cli");
}

/// Enable interrupts (set interrupt flag).
pub inline fn sti() void {
    asm volatile ("sti");
}

/// Halt the CPU until the next interrupt.
pub inline fn hlt() void {
    asm volatile ("hlt");
}


// -----------------------------------------------------------------------------
// Descriptor tables
// -----------------------------------------------------------------------------

/// Load the Global Descriptor Table (GDT).
pub inline fn lgdt(base: *const anyopaque, size: u16) void {
    /// Global Descriptor Table Register (GDTR) layout.
    const Gdtr = packed struct {
        length: u16,
        base: *const anyopaque,
    };

    var gdtr: Gdtr = .{
        .length = size,
        .base = base,
    };

    asm volatile ("lgdt %[gdtr]"
        :
        : [gdtr] "m" (gdtr),
    );
}


// -----------------------------------------------------------------------------
// Memory-mapped I/O
// -----------------------------------------------------------------------------

/// VGA text mode buffer base address.
pub const VGA_TEXT_BUFFER = 0xB8000;

/// UART base port (COM1).
pub const UART_BUFFER = 0x3F8;


// -----------------------------------------------------------------------------
// Port-mapped I/O (PS/2 Controller)
// -----------------------------------------------------------------------------

/// PS/2 controller data port (read/write).
pub const PS2_DATA_PORT = 0x60;

/// PS/2 controller status port (read).
pub const PS2_STATUS_PORT = 0x64;

/// PS/2 controller command port (write).
pub const PS2_COMMAND_PORT = 0x64;
