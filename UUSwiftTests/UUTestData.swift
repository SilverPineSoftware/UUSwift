//
//  UUTestData.swift
//  UUSwiftTests
//
//  Created by Ryan DeVore on 7/17/19.
//  Copyright © 2019 Silverpine Software. All rights reserved.
//

import UIKit
import UUSwift

class UUTestData: NSObject
{
    static func getRandomPhotoUrls(
        page: Int = 1,
        count: Int = 10,
        query: String = "forest",
        completion: @escaping (([String])->()))
    {
        let url = "https://api.shutterstock.com/v2/images/search"
        
        var args : UUQueryStringArgs = [:]
        args["page"] = "\(page)"
        args["per_page"] = "\(count)"
        args["query"] = query
        
        var headers : UUHttpHeaders = [:]
        
        let username = "d4a89-1400b-04251-4faee-f7a23-12271:61764-d9c3c-8a832-a7bdf-098e4-0b382"
        let usernameData = username.data(using: .utf8)
        let usernameEncoded = usernameData!.base64EncodedString(options: Data.Base64EncodingOptions.init(rawValue: 0))
        headers["Authorization"] = "Basic \(usernameEncoded)"
        
        let req = UUHttpRequest(url: url, method: .get, queryArguments: args, headers: headers)
        
        _ = UUHttpSession.executeRequest(req)
        { (response: UUHttpResponse) in
            
            var results: [String] = []
            
            if (response.httpError == nil)
            {
                if let parsed = response.parsedResponse as? [AnyHashable:Any]
                {
                    if let data = parsed["data"] as? [ [AnyHashable:Any] ]
                    {
                        for item in data
                        {
                            if let assets = item["assets"] as? [AnyHashable:Any]
                            {
                                if let largeThumb = assets["large_thumb"] as? [AnyHashable:Any]
                                {
                                    if let value = largeThumb["url"] as? String
                                    {
                                        results.append(value)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
            DispatchQueue.main.async
            {
                completion(results)
            }
        }
    }

}
