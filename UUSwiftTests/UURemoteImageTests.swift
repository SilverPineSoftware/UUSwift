//
//  UURemoteImageTests.swift
//  UUSwiftTests
//
//  Created by Ryan DeVore on 7/17/19.
//  Copyright © 2019 Silverpine Software. All rights reserved.
//

import XCTest
@testable import UUSwift

class UURemoteImageTests: XCTestCase
{
    override func setUp()
    {
        super.setUp()
        
        //UURemoteData.shared.maxActiveRequests = 50
    }
    
    func test_0000_fetchRemote_1()
    {
        _ = fetchMultipleRemote(count: 1)
    }
    
    func test_0001_fetchMultipleConcurrent_10()
    {
        _ = fetchMultipleRemote(count: 10)
    }
    
    func test_0002_fetchMultipleConcurrent_100()
    {
        _ = fetchMultipleRemote(count: 100)
    }
    
    func test_0003_fetchMultipleConcurrent_500()
    {
        _ = fetchMultipleRemote(count: 500)
    }
    
    func test_0004_fetchFromBadUrl()
    {
        expectation(forNotification: NSNotification.Name(rawValue: UURemoteData.Notifications.DataDownloadFailed.rawValue), object: nil)
        
        let key = "http://this.is.a.fake.url/non_existent.jpg"
        
        let data = UURemoteImage.shared.image(for: key)
        XCTAssertNil(data)
        
        UUWaitForExpectations(300)
    }
    
    func test_0005_fetchExisting_1()
    {
        fetchMultipleLocal(count: 1)
    }
    
    func test_0006_fetchExisting_10()
    {
        fetchMultipleLocal(count: 10)
    }
    
    func test_0006_fetchExisting_100()
    {
        fetchMultipleLocal(count: 100)
    }
    
    func test_0007_fetchBadUrl_1()
    {
        _ = fetchMultipleBadUrl(count: 1)
    }
    
    func test_0008_fetchBadUrl_10()
    {
        _ = fetchMultipleBadUrl(count: 10)
    }
    
    func test_0009_fetchBadUrl_100()
    {
        _ = fetchMultipleBadUrl(count: 100)
    }
    
    func test_0010_fetchBadUrl_500()
    {
        _ = fetchMultipleBadUrl(count: 500)
    }
    
    //////////////////////////////////////////////////////////////////////////////////////////
    // Private Methods
    // MARK:- Private
    //////////////////////////////////////////////////////////////////////////////////////////
    
    private func fetchMultipleBadUrl(count: Int) -> [String]
    {
        UUDataCache.shared.clearCache()
        UURemoteImage.shared.clearCache()
        
        let exp = UUExpectationForMethod()
        
        var testData: [String] = []
        
        UUTestData.getRandomPhotoUrls(page: 1, count: count, query: "tree")
        { (list) in
            
            testData.append(contentsOf: list)
            exp.fulfill()
        }
        
        UUWaitForExpectations(300)
        
        testData = testData.map({ return $0.appending(randomWord(4))})
        
        var expectations : [XCTestExpectation] = []
        for td in testData
        {
            let exp = expectationForRemoteDataFailed(td)
            expectations.append(exp)
        }
        
        
        for td in testData
        {
            let data = UURemoteImage.shared.image(for: td)
            XCTAssertNil(data)
        }
        
        UUWaitForExpectations(300)
        
        for td in testData
        {
            let data = UUDataCache.shared.data(for: td)
            XCTAssertNil(data)
        }
        
        let keys = UUDataCache.shared.listKeys()
        XCTAssertEqual(keys.count, 0)
        
        return testData
    }
    
    private func fetchMultipleLocal(count: Int)
    {
        let testData = fetchMultipleRemote(count: count)
        
        for td in testData
        {
            let data = UURemoteImage.shared.image(for: td)
            XCTAssertNotNil(data)
            
            let md = UURemoteData.shared.metaData(for: td)
            XCTAssertNotNil(md)
        }
    }
    
    private func fetchMultipleRemote(count: Int) -> [String]
    {
        UUDataCache.shared.clearCache()
        UURemoteImage.shared.clearCache()
        
        let exp = UUExpectationForMethod()
        
        var testData: [String] = []
        
        UUTestData.getRandomPhotoUrls(page: 1, count: count, query: "ocean")
        { (list) in
            
            testData.append(contentsOf: list)
            exp.fulfill()
        }
        
        UUWaitForExpectations(300)
        
        var expectations : [XCTestExpectation] = []
        for td in testData
        {
            let exp = expectationForRemoteData(td)
            expectations.append(exp)
        }
        
        for td in testData
        {
            let data = UURemoteImage.shared.image(for: td)
            XCTAssertNil(data)
        }
        
        UUWaitForExpectations(300)
        
        for td in testData
        {
            let md = UURemoteData.shared.metaData(for: td)
            let data = UURemoteImage.shared.image(for: td)
            XCTAssertNotNil(data)
            XCTAssertNotNil(md)
        }
        
        let keys = UUDataCache.shared.listKeys()
        XCTAssertEqual(keys.count, count)
        
        return testData
    }
    
    private func expectationForRemoteData(_  key: String) -> XCTestExpectation
    {
        return  expectation(forNotification: NSNotification.Name(rawValue: UURemoteImage.Notifications.ImageDownloaded.rawValue), object: nil)
        { (notification: Notification) -> Bool in
            
            guard let remoteKey = notification.uuRemoteDataPath else
            {
                return false
            }
            
            if (remoteKey != key)
            {
                return false
            }
            
            let md = UURemoteData.shared.metaData(for: key)
            XCTAssertNotNil(md)
            
            let data = UURemoteImage.shared.image(for: key)
            XCTAssertNotNil(data)
            
            let nKey = notification.uuRemoteDataPath
            XCTAssertNotNil(nKey)
            
            let nErr = notification.uuRemoteDataError
            XCTAssertNil(nErr)
            
            return true
        }
    }
    
    private func expectationForRemoteDataFailed(_  key: String) -> XCTestExpectation
    {
        return  expectation(forNotification: NSNotification.Name(rawValue: UURemoteData.Notifications.DataDownloadFailed.rawValue), object: nil)
        { (notification: Notification) -> Bool in
            
            guard let remoteKey = notification.uuRemoteDataPath else
            {
                return false
            }
            
            if (remoteKey != key)
            {
                return false
            }
            
            let data = UUDataCache.shared.data(for: key)
            XCTAssertNil(data)
            
            let nKey = notification.uuRemoteDataPath
            XCTAssertNotNil(nKey)
            
            let nErr = notification.uuRemoteDataError
            XCTAssertNotNil(nErr)
            
            return true
        }
    }

}
