//
//  UUKeychainTests.swift
//  UUSwiftTests
//
//  Created by Ryan DeVore on 12/18/19.
//  Copyright © 2019 Silverpine Software. All rights reserved.
//

import XCTest
import UUSwift

class UUKeychainTests: XCTestCase
{
    func testGetNonExistent()
    {
        let result = UUKeychain.getString(key: "does-not-exist")
        XCTAssertNil(result)
    }
    
    func testSetGet()
    {
        let key = "lookup-key"
        let accessLevel = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly
        var value = "ABC123"
        UUKeychain.saveString(key: key, acceessLevel: accessLevel, string: value)
        
        var lookup = UUKeychain.getString(key: key)
        XCTAssertNotNil(lookup)
        XCTAssertEqual(value, lookup)
        
        UUKeychain.remove(key: key)
        lookup = UUKeychain.getString(key: key)
        XCTAssertNil(lookup)
        
        value = "ZXY987"
        UUKeychain.saveString(key: key, acceessLevel: accessLevel, string: value)
        
        lookup = UUKeychain.getString(key: key)
        XCTAssertNotNil(lookup)
        XCTAssertEqual(value, lookup)
        
        value = "LMNO4567"
        UUKeychain.saveString(key: key, acceessLevel: accessLevel, string: value)
        
        lookup = UUKeychain.getString(key: key)
        XCTAssertNotNil(lookup)
        XCTAssertEqual(value, lookup)
    }

//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measure {
//            // Put the code you want to measure the time of here.
//        }
//    }

}
