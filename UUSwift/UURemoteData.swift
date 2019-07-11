//
//  UURemoteData.swift
//  Useful Utilities - An extension to Useful Utilities 
//  UUDataCache that fetches data from a remote source
//
//	License:
//  You are free to use this code for whatever purposes you desire.
//  The only requirement is that you smile everytime you use it.
//
//
//  UURemoteData provides a centralized place where application components can 
//  request data that may come from a remote source.  It utilizes existing 
//  UUDataCache functionality to locally store files for later fetching.  It 
//  will intelligently handle multiple requests for the same image so that 
//  extraneous network requests are not needed.
//
//  NOTE: This class depends on the following toolbox classes:
//
//  UUHttpSession
//  UUDataCache
//

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif


public typealias UUDataLoadedCompletionBlock = (Data?, Error?) -> Void

public class UURemoteData : NSObject
{
    
    public struct Notifications
    {
        public static let DataDownloaded = Notification.Name("UUDataDownloadedNotification")
        public static let DataDownloadFailed = Notification.Name("UUDataDownloadFailedNotification")
    }

    public struct MetaData
    {
        public static let MimeType = "MimeType"
        public static let DownloadTimestamp = "DownloadTimestamp"
    }
    
    public struct NotificationKeys
    {
        public static let RemotePath = "UUDataRemotePathKey"
        public static let Error = "UURemoteDataErrorKey"
    }
    
    // Default to 4 active requests at a time...
    var maxActiveRequests = 4
    
    public func get(_ path : String, completion : @escaping UUDataLoadedCompletionBlock)
    {
        
        // If there is already a set of handlers, just append our completion block...
        if var handlers = self.httpRequestLookups[path]
        {
            handlers.append(completion)
            self.httpRequestLookups[path] = handlers
        }
        else
        {
            self.httpRequestLookups[path] = [completion]
            self.queuedRequests.append(path)
        }
        
        self.checkForPendingRequests()
    }

    static public let shared : UURemoteData = UURemoteData()
    
    /*/////////////////////////////////////////////////////////////////////////////////////////////////////////
     Private Interface
     *//////////////////////////////////////////////////////////////////////////////////////////////////////////
    
    private func executeLocalLoad(_ path : String) -> Bool
    {
        
        if UUDataCache.shared.doesDataExist(for: path)
        {
            self.dataProcessingQueue.async
            {
                if let data = UUDataCache.shared.data(for: path)
                {
                    
                    if let callbacks : [UUDataLoadedCompletionBlock] = self.httpRequestLookups[path]
                    {
                        for callback in callbacks
                        {
                            callback(data, nil)
                        }
                    }
                    
                    // Also post a notification...
                    DispatchQueue.main.async
                    {
                        let md = UUDataCache.shared.metaData(for: path)
                        NotificationCenter.default.post(name: Notifications.DataDownloaded, object: nil, userInfo: md)
                    }

                    self.httpRequestLookups.removeValue(forKey: path)
                }
                else
                {
                    UUDataCache.shared.removeData(for: path)
                }
                    
                self.checkForPendingRequests()
            }
            
            return true
        }
        
        return false
    }
    
    private func executeRequest(_ path : String)
    {
        // Try to load it locally first...
        if self.executeLocalLoad(path)
        {
            return
        }
        
        let httpRequest = UUHttpRequest(url: path)
        httpRequest.processMimeTypes = false
        
        _ = UUHttpSession.executeRequest(httpRequest)
        { (response) in
            
            let error = response.httpError
            
            if let index = self.activeRequests.index(where: { $0 == path })
            {
                self.activeRequests.remove(at: index)
            }
            
            self.dataProcessingQueue.async
            {
                if let data = response.rawResponse
                {
                    UUDataCache.shared.set(data: data, for: path)

                    var md = UUDataCache.shared.metaData(for: path)
                    md[MetaData.MimeType] = "raw"
                    md[MetaData.DownloadTimestamp] = Date()
                    md[UURemoteData.NotificationKeys.RemotePath] = path
                    UUDataCache.shared.set(metaData: md, for: path)
                }
                else
                {
                    UUDataCache.shared.removeData(for: path)
                }
                
                if let responseHandlers = self.httpRequestLookups[path]
                {
                    for responseHandler in responseHandlers
                    {
                        responseHandler(response.rawResponse, error)
                    }
                }
                
                // Also post a notification...
                if (error == nil)
                {
                    DispatchQueue.main.async
                    {
                        let md = UUDataCache.shared.metaData(for: path)
                        NotificationCenter.default.post(name: Notifications.DataDownloaded, object: nil, userInfo: md)
                    }
                }
                else
                {
                    UUDebugLog("Remote download failed!\n\nPath: %@\nStatusCode: %d\nError: %@\n", path, String(describing: response.httpResponse?.statusCode), String(describing: response.httpError))
                    
                    DispatchQueue.main.async
                    {
                        var md : [String:Any] = [:]
                        md[UURemoteData.NotificationKeys.RemotePath] = path
                        md[NotificationKeys.Error] = response.httpError

                        NotificationCenter.default.post(name: Notifications.DataDownloadFailed, object: nil, userInfo: md)
                    }
                }
                
                self.httpRequestLookups.removeValue(forKey: path)

            }
            
            self.checkForPendingRequests()
        }
    }
    
    private func checkForPendingRequests()
    {
        while self.queuedRequests.count > 0 && self.activeRequests.count < self.maxActiveRequests
        {
            let path = self.queuedRequests.removeFirst()
            self.activeRequests.append(path)
            self.executeRequest(path)
        }
    }
    
    private var httpRequestLookups : [String : [UUDataLoadedCompletionBlock]] = [:]
    private var activeRequests : [String] = []
    private var queuedRequests : [String] = []
    
    private let dataProcessingQueue : DispatchQueue = DispatchQueue(label: "UURemoteDataQueue", qos: .background)    
}

extension Notification
{
    public var uuRemoteDataPath : String?
    {
        return userInfo?[UURemoteData.NotificationKeys.RemotePath] as? String
    }
    
    public var uuRemoteDataError : Error?
    {
        return userInfo?[UURemoteData.NotificationKeys.Error] as? Error
    }
}
