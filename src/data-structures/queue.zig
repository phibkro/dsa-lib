const std = @import("std");
const testing = std.testing;

/// FIFO (First In First Out)
///
/// Adds items at the end of the queue
///
/// Removes items at the start of the queue
pub fn Queue(comptime T: type) type {
    return struct {
        const This = @This();
        const Node = struct {
            value: T,
            next: ?*Node,
        };
        allocator: std.mem.Allocator,
        start: ?*Node,
        end: ?*Node,

        /// Returns an empty queue
        pub fn init(allocator: std.mem.Allocator) This {
            return This{
                .allocator = allocator,
                .start = null,
                .end = null,
            };
        }

        /// Adds an item to the end of the queue
        pub fn enqueue(this: *This, value: T) !void {
            const node = try this.allocator.create(Node);
            node.* = .{ .value = value, .next = null };
            if (this.end) |end| {
                end.next = node;
            } else {
                this.start = node;
            }
            this.end = node;
        }

        /// Removes the item at the start of the queue and returns the result
        pub fn dequeue(this: *This) ?T {
            const start = this.start orelse return null;
            defer this.allocator.destroy(start);
            if (start.next) |next|
                this.start = next
            else {
                this.start = null;
                this.end = null;
            }
            return start.value;
        }
    };
}

test "queue" {
    var int_queue = Queue(i32).init(testing.allocator);

    try int_queue.enqueue(25);
    try int_queue.enqueue(50);
    try int_queue.enqueue(75);
    try int_queue.enqueue(100);

    try testing.expectEqual(int_queue.dequeue(), 25);
    try testing.expectEqual(int_queue.dequeue(), 50);
    try testing.expectEqual(int_queue.dequeue(), 75);
    try testing.expectEqual(int_queue.dequeue(), 100);
    try testing.expectEqual(int_queue.dequeue(), null);

    try int_queue.enqueue(5);
    try testing.expectEqual(int_queue.dequeue(), 5);
    try testing.expectEqual(int_queue.dequeue(), null);
}
