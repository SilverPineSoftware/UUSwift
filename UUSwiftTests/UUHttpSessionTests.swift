//
//  UUHttpSessionTests.swift
//  UUSwiftTests
//
//  Created by Ryan DeVore on 2/22/19.
//  Copyright © 2019 Jonathan Hays. All rights reserved.
//

import XCTest
import UUSwift

class UUHttpSessionTests: XCTestCase
{
    override func setUp()
    {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown()
    {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testGet()
    {
        let exp = UUExpectationForMethod()
        
        let url = "http://www.silverpine.com"
        
        UUHttpSession.get(url, [:])
        { (response) in
            
            XCTAssertNil(response.httpError)
            exp.fulfill()
        }
        
        UUWaitForExpectations()
    }
    
    func testPostForm()
    {
        let exp = UUExpectationForMethod()
        
        let url = "https://ptsv2.com/t/UUSwiftUnitTest/post"
        
        let form = UUHttpForm()
        form.add(field: "Name", value: "UUSwift")
        form.add(field: "Email", value: "UUSwift@FakeEmail.com")
        
        let string = "This is a unit test"
        let data = string.data(using: .utf8)
        XCTAssertNotNil(data)
        
        form.addFile(fieldName: "testFile", fileName: "myFile.txt", contentType: "text/plain", fileData: data!)
        
        let request = UUHttpRequest.postFormRequest(url, [:], form)
        
        _ = UUHttpSession.executeRequest(request)
        { (response) in
        
            XCTAssertNil(response.httpError)
            exp.fulfill()
        }
        
        UUWaitForExpectations()
    }

}
