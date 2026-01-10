// The Swift Programming Language
// https://docs.swift.org/swift-book

import ArgumentParser
import AppKit
import Foundation

struct CliArgs: ParsableArguments {
    @Option(help: "The new window(s) width")
    var width: Double? = nil

    @Option(help: "The new window(s) height")
    var height: Double? = nil

    @Option(help: "The x coordinate to move the window to")
    var x: Double? = nil

    @Option(help: "The y coordinate to move the window to")
    var y: Double? = nil

    @Option(help: "The window id")
    var windowId: Int? = nil

    @Argument(help: "The action to execute")
    var action: Action
}

enum CliParseError: LocalizedError {
    case missingMandatoryOption(option: String, action: String)

    var errorDescription: String? {
        switch self {
            case .missingMandatoryOption(let option, let action):
            return "Missing mandatory option `\(option)` for action `\(action)`"
        }
    }
}

enum Action: String, CaseIterable, ExpressibleByArgument {
    case list
    case move
    case resize

    var help: ArgumentHelp? {
            switch self {
            case .list:
                return "List all windows"
            case .move:
                return "Move the window to the specified position (requires `posx` and `posx` options)"
            case .resize:
                return "Resize the window to the specified size (requires `width` and `height` options)"
            }
        }
}

@main
struct Windman {
    static func main() {
        do {
            try run()
        } catch(let e) {
            fputs("Error: \(e.localizedDescription)\n", stderr)
        }
    }

    @MainActor
    static func run() throws {
        let cliArgs = CliArgs.parseOrExit();
        let action = cliArgs.action;

        let wm = WindowManager();
        switch action {
        case .list:
            try wm.listAll()
        case .move:
            guard let windowId = cliArgs.windowId else { throw CliParseError.missingMandatoryOption(option: "windowId", action: action.rawValue) }
            guard let x = cliArgs.x else { throw CliParseError.missingMandatoryOption(option: "x", action: action.rawValue) }
            guard let y = cliArgs.y else { throw CliParseError.missingMandatoryOption(option: "y", action: action.rawValue) }
            try wm.moveTo(windowId: windowId, point: Point(x: x, y: y))
        case .resize:
            guard let windowId = cliArgs.windowId else { throw CliParseError.missingMandatoryOption(option: "windowId", action: action.rawValue) }
            guard let width = cliArgs.width else { throw CliParseError.missingMandatoryOption(option: "width", action: action.rawValue) }
            guard let height = cliArgs.height else { throw CliParseError.missingMandatoryOption(option: "height", action: action.rawValue) }
            try wm.resize(windowId: windowId, size: Size(width: width, height: height))
        }
    }
}
