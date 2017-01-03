//
//  main.swift
//  Ookami
//
//  Created by Maka on 3/1/17.
//  Copyright © 2017 Mikunj Varsani. All rights reserved.
//

import UIKit

//Use MockAppDelegate if we are unit testing
//This is to avoid the initial view controller to have effects on the tests

final class MockAppDelegate: UIResponder, UIApplicationDelegate {}

private func appDelegateClassName() -> String {
    let isTesting = NSClassFromString("XCTestCase") != nil
    return
        NSStringFromClass(isTesting ? MockAppDelegate.self : AppDelegate.self)
}

UIApplicationMain(
    CommandLine.argc,
    UnsafeMutableRawPointer(CommandLine.unsafeArgv)
        .bindMemory(to: UnsafeMutablePointer<Int8>.self, capacity: Int(CommandLine.argc)),
    NSStringFromClass(UIApplication.self), appDelegateClassName()
)
