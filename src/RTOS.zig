//! Root module for RISC-V-Minimal-RTOS
//!
//! A minimal Real-Time Operating System (RTOS) for embedded applications,
//! with targets for x86_64, RISC-V (RV32I, RV64I), and ARM, written in Zig.
//!
//! ## Modules
//! - `arch`: Architecture-specific code
//! - `drivers`: Peripheral drivers
//! - `kernel`: Kernel initialization and core logic
//! - `lib`: Utility functionality
//! - `services`: RTOS services
//! - `syscalls`: System call handling

const std = @import("std");

pub const arch = @import("arch/arch.zig");
pub const drivers = @import("drivers/drivers.zig");
pub const kernel = @import("kernel/kernel.zig");
pub const lib = @import("lib/lib.zig");
pub const sc = @import("drivers/keyboard/scancode.zig");

/// Trap/exception entry point.
///
/// Invoked whenever an exception occurs or an interrupt is delivered.
pub export fn trap() callconv(.C) noreturn {
    arch.cli();
    arch.hlt();

    while (true) {}
}

/// Kernel entry point invoked by the boot CPU (hart) after boot code finishes.
pub export fn kmain() callconv(.C) noreturn {
    main();

    while (true) {}
}

pub fn main() void {
    // Initialize architecture-specific components.
    // arch.initIrqController();

    // Initialize the global IRQ registry.
    // kernel.irq.initGlobalRegistry(&arch.irq_controller);

    // Enable interrupts.
    // arch.sti();

    // Register IRQ handlers.
    // _ = kernel.irq.registerHandler(1, keyboardIrqHandler);

    // Initialize VGA text driver.
    var vga_text_driver = drivers.vga.VgaTextDriver.init(drivers.vga.VGA_TEXT_BUFFER);
    vga_text_driver.clear();

    // Print a welcome message.
    vga_text_driver.setColor(drivers.vga.VgaTextColor.new(.VGA_COLOR_WHITE, .VGA_COLOR_BLACK));
    vga_text_driver.putStr("RISC-V-Minimal-RTOS VGA Text Driver Demo\n");
    vga_text_driver.putStr("----------------------------------------\n\n");

    // Demonstrate alternating colors.
    var i: usize = 0;
    while (i < 30) {
        if (i % 2 == 0) {
            vga_text_driver.setColor(drivers.vga.VgaTextColor.new(.VGA_COLOR_LIGHT_RED, .VGA_COLOR_BLACK));
            vga_text_driver.println("Hello, {s} world!", .{"red"});
        } else {
            vga_text_driver.setColor(drivers.vga.VgaTextColor.new(.VGA_COLOR_LIGHT_GREEN, .VGA_COLOR_BLACK));
            vga_text_driver.println("Hello, {s} world!", .{"green"});
        }
        i += 1;
    }

    vga_text_driver.scroll();
    vga_text_driver.println("{c}", .{'a'});
    vga_text_driver.println("{c}", .{'Q'});
    vga_text_driver.println("{c}", .{@as(u8, @truncate(256 + '9'))});
    vga_text_driver.println("{s}", .{"test string"});
    vga_text_driver.println("foo{s}bar", .{"blah"});
    vga_text_driver.println("{d}", .{@as(i32, std.math.minInt(i32))});
    vga_text_driver.println("{d}", .{std.math.maxInt(i32)});

    // vga_text_driver.println("{u}", .{@as(u32, 0)});
    // vga_text_driver.println("{d}", .{std.math.maxInt(u32)});
    // vga_text_driver.println("{x}", .{0xDEADbeef});
    // vga_text_driver.println("{p}", .{@as([*]u8, @ptrFromInt(std.math.maxInt(usize)))});
    // vga_text_driver.println("{hd}", .{@as(i16, -32768)});
    // vga_text_driver.println("{hd}", .{@as(i16, 32767)});
    // vga_text_driver.println("{hu}", .{@as(u16, 65535)});
    // vga_text_driver.println("{ld}", .{std.math.minInt(isize)});
    // vga_text_driver.println("{ld}", .{std.math.maxInt(isize)});
    // vga_text_driver.println("{lu}", .{std.math.maxInt(usize)});
    // vga_text_driver.println("{qd}", .{std.math.minInt(i64)});
    // vga_text_driver.println("{qd}", .{std.math.maxInt(i64)});
    // vga_text_driver.println("{qu}", .{std.math.maxInt(u64)});

    // Initialize PS/2 driver.
    var ps2_driver = drivers.ps2.Ps2Driver.init(
        drivers.ps2.PS2_DATA_PORT,
        drivers.ps2.PS2_STATUS_PORT,
        drivers.ps2.PS2_COMMAND_PORT,
    );

    // Initialize keyboard driver.
    const keyboard_driver = drivers.keyboard.KeyboardDriver.init(&ps2_driver, &vga_text_driver);
    if (keyboard_driver) |driver| {
        while (true) {
            const char = driver.getChar();
            if (char.char != null) {
                vga_text_driver.printk("{c}", .{char.char.?});
            }

            // else {
            //     vga_text_driver.println("\nScancode: 0x{X:0>2}", .{char.byte});
            // }
            // if (char.char != null) {
            //     vga_text_driver.println("Scancode: 0x{X:0>2}, Char: '{c}'", .{ char.byte, char.char.? });
            // } else {
            //     vga_text_driver.println("Scancode: 0x{X:0>2}", .{char.byte});
            // }
        }
    } else {
        vga_text_driver.println("Keyboard initialization failed!", .{});
        while (true) {}
    }
}

/// Example IRQ handler for keyboard.
fn keyboardIrqHandler(irq_num: u32) void {
    _ = irq_num;

    // Handle keyboard interrupt.
    // const scancode = arch.inb(drivers.ps2.PS2_DATA_PORT);
    // Process the scancode...
}
