import os
import Cocoa
import Foundation

struct Window: CustomStringConvertible {
    let id: Int
    let name: String
    let frame: CGRect
    let pid: Int32
    var isFocused: Bool {
        return name.caseInsensitiveCompare("ReSize") == .orderedSame
    }

    var description: String {
        return "{ id: \(id), name: \(name), pid: \(pid) }"
    }
}

struct Point {
    let x: Double
    let y: Double
}

struct Size {
    let width: Double
    let height: Double
}

enum WindowFindError: Error {
    case cannotGetElementAttributes
    case getWindowList
    case setPositionFailed
    case setSizeFailed
}

class WindowFinder {
    static func all() throws -> [Window] {
        // let display = kCGNullWindowID
        let display = CGMainDisplayID()

        let options = CGWindowListOption(arrayLiteral: .excludeDesktopElements, .optionOnScreenOnly)
        let windowListInfo = CGWindowListCopyWindowInfo(options, display)
        guard let windowList = windowListInfo as? [[String: Any]] else {
            throw WindowFindError.getWindowList
        }
        return windowList.filter { $0["kCGWindowLayer"] as! Int == 0 }
            .map { Window(
                id: $0["kCGWindowNumber"] as! Int,
                name: $0["kCGWindowOwnerName"] as! String,
                frame: CGRect(
                    x: ($0["kCGWindowBounds"] as! [String: Any])["X"] as! CGFloat,
                    y: ($0["kCGWindowBounds"] as! [String: Any])["Y"] as! CGFloat,
                    width: ($0["kCGWindowBounds"] as! [String: Any])["Width"] as! CGFloat,
                    height: ($0["kCGWindowBounds"] as! [String: Any])["Height"] as! CGFloat
                ),
                pid: $0["kCGWindowOwnerPID"] as! Int32
            )}
    }
}

class WindowManager: NSViewController {
    func listAll() throws {
        let windows = try WindowFinder.all()
        for window in windows {
            print(window)
        }
    }

    func moveTo(windowId: Int, point: Point) throws {
        let windows = try WindowFinder.all()
        for window in windows {
           if window.id == windowId {
               let element = try WinUtil.toUIElement(window: window)
               let _ = try WinUtil.setNewOrigin(element: element, newOrigin: point)
           }
        }
    }

    func resize(windowId: Int, size: Size) throws {
        let windows = try WindowFinder.all()
        for window in windows {
           if window.id == windowId {
               let element = try WinUtil.toUIElement(window: window)
               let _ = try WinUtil.setNewSize(element: element, newSize: size)
           }
        }
    }
}

struct WinUtil {
    static func toUIElement(window: Window) throws -> AXUIElement {
        let appRef = AXUIElementCreateApplication(window.pid)
        var value: AnyObject?
        if AXUIElementCopyAttributeValue(appRef, kAXWindowsAttribute as CFString, &value) != .success {
            throw WindowFindError.cannotGetElementAttributes
        }
        let uiElements = value as! [AXUIElement]
        let element = uiElements.first!
        // Set timeout per element
        AXUIElementSetMessagingTimeout(element, 2.0)
        return element
    }

    static func setNewOrigin(element: AXUIElement, newOrigin: Point) throws -> Bool {
        // check if attribute is settable
        var settable: DarwinBoolean = false
        AXUIElementIsAttributeSettable(element, kAXPositionAttribute as CFString, &settable)
        if !settable.boolValue { return false }

        // set new origin
        var newOrigin = CGPoint(x: newOrigin.x, y: newOrigin.y)
        let position = AXValueCreate(AXValueType(rawValue: kAXValueCGPointType)!, &newOrigin)!
        if AXUIElementSetAttributeValue(element, kAXPositionAttribute as CFString, position) != .success {
            fputs("failed to set position\n", stderr)
            throw WindowFindError.setPositionFailed
        }
        return true
    }

    static func setNewSize(element: AXUIElement, newSize: Size) throws -> Bool {
        // check if attribute is settable
        var settable: DarwinBoolean = false
        AXUIElementIsAttributeSettable(element, kAXSizeAttribute as CFString, &settable)
        if !settable.boolValue { return false }

        // set new size
        var newSize = CGSize(width: newSize.width, height: newSize.height)
        let size = AXValueCreate(AXValueType(rawValue: kAXValueCGSizeType)!, &newSize)!
        if AXUIElementSetAttributeValue(element, kAXSizeAttribute as CFString, size) != .success {
            fputs("failed to set size\n", stderr)
            throw WindowFindError.setSizeFailed
        }
        return true
    }
}
