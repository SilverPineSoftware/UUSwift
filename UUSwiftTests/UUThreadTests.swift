//
//  UUThreadTests.swift
//  UUSwiftTests
//
//  Created by Ryan DeVore on 7/18/19.
//  Copyright © 2019 Silverpine Software. All rights reserved.
//

import XCTest
@testable import UUSwift

class UUThreadTests: XCTestCase
{
    func testThreadSafeArray()
    {
        let a: UUThreadSafeArray<String> = UUThreadSafeArray()
        //var a: [String] = [] // Using a native object will lead to crashes and unexpected behavior
        a.append("foo")
        a.append("bar")
        a.append("baz")
        
        var count = a.count
        XCTAssertEqual(count, 3)
        
        let last = a.removeLast()
        XCTAssertNotNil(last)
        XCTAssertEqual("baz", last)
        
        let queue = DispatchQueue(label: "UUThreadUnitTest", qos: .default, attributes: .concurrent)
        
        a.removeAll()
        
        var expList: [XCTestExpectation] = []
        
        let iterations = 10
        for i in 0..<iterations
        {
            let exp = UUExpectationForMethod(tag: "\(i)")
            expList.append(exp)
            
            queue.async
            {
                a.append("\(i)")
                exp.fulfill()
            }
        }
        
        UUWaitForExpectations()
        
        print("\(a)")
        count = a.count
        XCTAssertEqual(count, iterations)
    }

    func testThreadSafeDictionary()
    {
        let d: UUThreadSafeDictionary<String,String> = UUThreadSafeDictionary()
        //var d: [String:String] = [:] // Using a native object will lead to crashes and unexpected behavior
        d["foo"] = "bar"
        d["baz"] = "foo"
        
        var count = d.count
        XCTAssertEqual(count, 2)
        
        let lookup = d["foo"]
        XCTAssertNotNil(lookup)
        XCTAssertEqual("bar", lookup)
        
        let queue = DispatchQueue(label: "UUThreadUnitTest", qos: .default, attributes: .concurrent)
        
        d.removeAll()
        
        var expList: [XCTestExpectation] = []
        
        let iterations = 10
        for i in 0..<iterations
        {
            let exp = UUExpectationForMethod(tag: "\(i)")
            expList.append(exp)
            
            queue.async
            {
                d["key_\(i)"] = "val_\(i)"
                exp.fulfill()
            }
        }
        
        UUWaitForExpectations()
        
        print("\(d)")
        count = d.count
        XCTAssertEqual(count, iterations)
    }

}
