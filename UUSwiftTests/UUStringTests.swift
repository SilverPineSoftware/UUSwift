//
//  UUStringTests.swift
//  UUSwiftTests
//
//  Created by Ryan DeVore on 7/11/19.
//  Copyright © 2019 Silverpine Software. All rights reserved.
//

import XCTest
import UUSwift

class UUStringTests: XCTestCase
{
    override func setUp()
    {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func test_0000_uuToCamelCase()
    {
        let td = [
            ("foo", "foo"),
            ("foo_bar", "fooBar"),
            ("foo_bar_baz", "fooBarBaz"),
            ("foo_", "foo")
        ]
        
        for input in td
        {
            let result = input.0.uuToCamelCase()
            print("Input: \(input.0) --> \(result)")
            XCTAssertEqual(result, input.1)
        }
    }
    
    func test_0001_uuToSnakeCase()
    {
        let td = [
            ("foo", "foo"),
            ("fooBar", "foo_bar"),
            ("fooBarBaz", "foo_bar_baz"),
            ("Foo", "_foo"),
            ("FBar", "_f_bar")
        ]
        
        for input in td
        {
            let result = input.0.uuToSnakeCase()
            print("Input: \(input.0) --> \(result)")
            XCTAssertEqual(result, input.1)
        }
    }
    
}
