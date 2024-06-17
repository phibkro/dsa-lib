const std = @import("std");
const testing = std.testing;

/// LIFO (Last In First Out)
///
/// Adds items to the top of the stack
///
/// Removes items from the top of the stack
pub fn Stack(comptime T: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            value: T,
            next: ?*Node,
        };
        allocator: std.mem.Allocator,
        top: ?*Node,

        /// Returns an empty stack
        pub fn init(allocator: std.mem.Allocator) This {
            return This{
                .allocator = allocator,
                .top = null,
            };
        }

        /// Adds an item to the top of the stack
        pub fn push(this: *This, value: T) !void {
            const node = try this.allocator.create(Node);
            node.* = .{
                .value = value,
                .next = null,
            };
            if (this.top) |top| {
                node.next = top;
            }
            this.top = node;
        }

        /// Removes the item from the top of the stack and returns its value
        pub fn pop(this: *This) ?T {
            const top = this.top orelse return null;
            defer this.allocator.destroy(top);
            if (top.next) |next| {
                this.top = next;
            } else {
                this.top = null;
            }
            return top.value;
        }
    };
}

test "Stack" {
    var int_stack = Stack(i32).init(testing.allocator);

    // Stack should initialize empty
    try testing.expectEqual(int_stack.pop(), null);

    try int_stack.push(7);
    try int_stack.push(21);
    try int_stack.push(147);

    try testing.expectEqual(int_stack.pop(), 147);
    try testing.expectEqual(int_stack.pop(), 21);

    try int_stack.push(69);
    try testing.expectEqual(int_stack.pop(), 69);

    try testing.expectEqual(int_stack.pop(), 7);
    try testing.expectEqual(int_stack.pop(), null);
}
