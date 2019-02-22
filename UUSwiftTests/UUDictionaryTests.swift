//
//  UUDictionaryTests.swift
//  UUSwiftTests
//
//  Created by Ryan DeVore on 2/22/19.
//  Copyright © 2019 Jonathan Hays. All rights reserved.
//

import XCTest
import UUSwift

class UUDictionaryTests: XCTestCase
{

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBuildQueryString_Simple()
    {
        let testData : [([AnyHashable:Any],String)] =
        [
            (["foo" : "bar"], "?foo=bar"),
            (["foo" : ["one", "two", "three"]], "?foo[]=one&foo[]=two&foo[]=three"),
            
            // Doesn't support non string keys
            ([NSNumber(value: 10) : "bar" ], ""),
        ]
        
        for td in testData
        {
            let actual = td.0.uuBuildQueryString()
            XCTAssertEqual(td.1, actual)
        }
    }

    func testPerformanceExample()
    {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
