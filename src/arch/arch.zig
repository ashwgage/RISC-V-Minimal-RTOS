//! Architecture abstraction layer.
//!
//! This module selects the correct architecture implementation at compile time
//! and re-exports a unified interface for the rest of the kernel.

const builtin = @import("builtin");

/// Resolve the active architecture implementation at compile time.
const Arch = switch (builtin.cpu.arch) {
    .x86_64 => @import("./x86_64/arch.zig"),
    .aarch64 => @import("./arm/arch.zig"),
    .riscv64, .riscv32 => @import("./riscv/arch.zig"),
    else => @compileError("Unsupported architecture"),
};

// -----------------------------------------------------------------------------
// Low-level CPU / I/O operations
// -----------------------------------------------------------------------------

/// Write a byte to an I/O port.
pub const outb = Arch.outb;

/// Read a byte from an I/O port.
pub const inb = Arch.inb;

/// Disable interrupts.
pub const cli = Arch.cli;

/// Enable interrupts (restore).
pub const sti = Arch.sti;

/// Halt the CPU until the next interrupt.
pub const hlt = Arch.hlt;

// -----------------------------------------------------------------------------
// Memory-mapped I/O
// -----------------------------------------------------------------------------

/// VGA text mode buffer base address.
pub const VGA_TEXT_BUFFER = Arch.VGA_TEXT_BUFFER;

/// UART buffer base address.
pub const UART_BUFFER = Arch.UART_BUFFER;

// -----------------------------------------------------------------------------
// Port-mapped I/O (PS/2 Controller)
// -----------------------------------------------------------------------------

/// PS/2 controller data port (read/write).
pub const PS2_DATA_PORT = Arch.PS2_DATA_PORT;

/// PS2 controller status port (read).
pub const PS2_STATUS_PORT = Arch.PS2_STATUS_PORT;

/// PS2 controller command port (write).
pub const PS2_COMMAND_PORT = Arch.PS2_COMMAND_PORT;
