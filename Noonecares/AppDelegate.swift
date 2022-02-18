//
//  AppDelegate.swift
//  Noonecares
//
//  Created by Lesterrry on 17.07.2021.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let statusItem = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
    public static let popover = NSPopover()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        if let button = statusItem.button {
            // 'NoOneLogo' changed to 'noonelogo' in Assets
            button.image = NSImage(named:NSImage.Name("noonelogo"))
            button.action = #selector(togglePopover(_:))
        }
        AppDelegate.popover.contentViewController = MenuViewController.freshController()
    }
    
    @objc func togglePopover(_ sender: Any?) {
        if AppDelegate.popover.isShown {
        closePopover(sender: sender)
      } else {
        showPopover(sender: sender)
      }
    }

    func showPopover(sender: Any?) {
      if let button = statusItem.button {
        AppDelegate.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
      }
    }

    func closePopover(sender: Any?) {
        AppDelegate.popover.performClose(sender)
    }
}
