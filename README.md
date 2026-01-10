# Windman

Windman is a collection of win(dow) man(ager) utilities for MacOS written in
Swift.

## Why Windman, with so many other available tools in this space?

There are already excellent existing tools in this space, such as Rectangle,
Raycast window manager, and the tiling window manager Aerospace.
But when I tried to use them, I often found myself wanting some extra piece of
functionality that wasn't there, and potentially will never be there due to
limitations or adherence to a specific project vision.

I started this project to explore which window management functionality can be
achieved through MacOS APIs, with the goal to implement the infrastructure on
top of which I can build my own window management workflow.

At the time of writing, it's just a playground project consisting of very
basic functionality (e.g., list, move, and resize windows) exposed via a
command line utility.

It can be used from the command line directly, or through tools such as Raycast
by creating a command that invokes it and optionally binding it to a keyboard
shortcut.

## Why Swift?

I picked Swift since it's a native solution for MacOS. Even though I originally
wanted to do it in other programming languages (with Zig and Rust being the top
candidates), I couldn't find an option with available API bindings that are
feature complete, performant, and don't introduce too much complexity.

Furthermore, at the time of writing I believe that Swift in this context is the
most future-proof option available.
