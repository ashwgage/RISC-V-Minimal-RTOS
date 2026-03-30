//! Architecture-independent IRQ handler abstraction.

const arch = @import("../arch/arch.zig");

/// IRQ handler function type.
pub const IrqHandlerFn = *const fn (irq_num: u32) void;

/// IRQ pending-query function type.
pub const IrqPendingFn = *const fn (irq_num: u32) bool;

/// IRQ controller interface.
pub const IrqController = struct {
    /// Enable a specific IRQ.
    enableFn: IrqHandlerFn,
    /// Disable a specific IRQ.
    disableFn: IrqHandlerFn,
    /// Acknowledge an IRQ.
    acknowledgeFn: IrqHandlerFn,
    /// Check whether an IRQ is pending.
    isPendingFn: IrqPendingFn,

    /// Enable a specific IRQ.
    pub fn enable(self: *const IrqController, irq_num: u32) void {
        self.enableFn(irq_num);
    }

    /// Disable a specific IRQ.
    pub fn disable(self: *const IrqController, irq_num: u32) void {
        self.disableFn(irq_num);
    }

    /// Acknowledge an IRQ.
    pub fn acknowledge(self: *const IrqController, irq_num: u32) void {
        self.acknowledgeFn(irq_num);
    }

    /// Check whether an IRQ is pending.
    pub fn isPending(self: *const IrqController, irq_num: u32) bool {
        return self.isPendingFn(irq_num);
    }
};

/// IRQ handler registry.
pub const IrqRegistry = struct {
    /// Maximum number of supported IRQ lines.
    const max_irqs = 256;

    /// Registered IRQ handlers.
    handlers: [max_irqs]?IrqHandlerFn = [_]?IrqHandlerFn{null} ** max_irqs,
    /// Backing IRQ controller.
    controller: *const IrqController,

    /// Initialize the IRQ registry.
    pub fn init(controller: *const IrqController) IrqRegistry {
        return .{
            .controller = controller,
        };
    }

    /// Register an IRQ handler.
    pub fn register(self: *IrqRegistry, irq_num: u32, handler: IrqHandlerFn) bool {
        if (irq_num >= max_irqs) return false;

        self.handlers[irq_num] = handler;
        self.controller.enable(irq_num);
        return true;
    }

    /// Unregister an IRQ handler.
    pub fn unregister(self: *IrqRegistry, irq_num: u32) bool {
        if (irq_num >= max_irqs) return false;

        self.handlers[irq_num] = null;
        self.controller.disable(irq_num);
        return true;
    }

    /// Dispatch an IRQ to its registered handler.
    pub fn dispatch(self: *IrqRegistry, irq_num: u32) void {
        if (irq_num >= max_irqs) return;

        if (self.handlers[irq_num]) |handler| {
            handler(irq_num);
            self.controller.acknowledge(irq_num);
        }
    }
};

/// Global IRQ registry.
var global_irq_registry: ?IrqRegistry = null;

/// Initialize the global IRQ registry.
pub fn initGlobalRegistry(controller: *const IrqController) void {
    global_irq_registry = IrqRegistry.init(controller);
}

/// Get the global IRQ registry.
pub fn getGlobalRegistry() ?*IrqRegistry {
    if (global_irq_registry) |*registry| {
        return registry;
    }
    return null;
}

/// Register an IRQ handler in the global registry.
pub fn registerHandler(irq_num: u32, handler: IrqHandlerFn) bool {
    if (getGlobalRegistry()) |registry| {
        return registry.register(irq_num, handler);
    }
    return false;
}

/// Unregister an IRQ handler from the global registry.
pub fn unregisterHandler(irq_num: u32) bool {
    if (getGlobalRegistry()) |registry| {
        return registry.unregister(irq_num);
    }
    return false;
}

/// Dispatch an IRQ using the global registry.
pub fn dispatchIrq(irq_num: u32) void {
    if (getGlobalRegistry()) |registry| {
        registry.dispatch(irq_num);
    }
}
