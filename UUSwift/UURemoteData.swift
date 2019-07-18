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

public protocol UURemoteDataProtocol
{
    func data(for key: String) -> Data?
    func isDownloadPending(for key: String) -> Bool
    
    func metaData(for key: String) -> [String:Any]
    func set(metaData: [String:Any], for key: String)
}

public typealias UUDataLoadedCompletionBlock = (Data?, Error?) -> Void

public class UURemoteData : NSObject, UURemoteDataProtocol
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
    
    private var pendingDownloads : [String:UUHttpRequest] = [:]
    private var responseHandlers : [String: Any] = [:]
    private var serialQueue: DispatchQueue = DispatchQueue(label: "serialQueue", attributes: .concurrent)
    private var httpRequestLookups : [String : [UUDataLoadedCompletionBlock]] = [:]
    
    static public let shared : UURemoteData = UURemoteData()
    
    ////////////////////////////////////////////////////////////////////////////
    // UURemoteDataProtocol Implementation
    ////////////////////////////////////////////////////////////////////////////
    public func data(for key: String) -> Data?
    {
        return data(for: key, remoteLoadCompletion: nil)
    }
    
    public func data(for key: String, remoteLoadCompletion: UUDataLoadedCompletionBlock? = nil) -> Data?
    {
        let url = URL(string: key)
        if (url == nil)
        {
            return nil
        }
        
        let data = UUDataCache.shared.data(for: key)
        if (data != nil)
        {
            return data
        }
        
        self.serialQueue.async(flags: .barrier)
        {
            if (self.isDownloadPending(for: key))
            {
                // An active UUHttpSession means a request is currently fetching the resource, so
                // no need to re-fetch
                UUDebugLog("Download pending for \(key)")
                return
            }
            
            let request = UUHttpRequest(url: key)
            request.processMimeTypes  = false
            
            let client = UUHttpSession.executeRequest(request)
            { (response: UUHttpResponse) in
                
                self.serialQueue.async(flags: .barrier)
                {
                    self.handleDownloadResponse(response, key)
                }
            }
            
            self.pendingDownloads[key] = client
            
            if let remoteHandler = remoteLoadCompletion
            {
                var handlers = self.httpRequestLookups[key]
                if (handlers == nil)
                {
                    handlers = []
                }
                
                if (handlers != nil)
                {
                    handlers!.append(remoteHandler)
                    self.httpRequestLookups[key] = handlers!
                }
            }
        }
        
        return nil
    }
    
    public func isDownloadPending(for key: String) -> Bool
    {
        return (pendingDownloads[key] != nil)
    }
    
    public func metaData(for key: String) -> [String:Any]
    {
        return UUDataCache.shared.metaData(for: key)
    }
    
    public func set(metaData: [String:Any], for key: String)
    {
        UUDataCache.shared.set(metaData: metaData, for: key)
    }
    
    
    ////////////////////////////////////////////////////////////////////////////
    // Private Implementation
    ////////////////////////////////////////////////////////////////////////////
    private func handleDownloadResponse(_ response: UUHttpResponse, _ key: String)
    {
        var md : [String:Any] = [:]
        md[UURemoteData.NotificationKeys.RemotePath] = key
        
        if (response.httpError == nil && response.rawResponse != nil)
        {
            let responseData = response.rawResponse!
            
            UUDataCache.shared.set(data: responseData, for: key)
            updateMetaDataFromResponse(response, for: key)
            notifyDataDownloaded(metaData: md)
            
            if let handlers = httpRequestLookups[key]
            {
                notifyRemoteDownloadHandlers(key: key, data: responseData, error: nil, handlers: handlers)
            }
        }
        else
        {
            UUDebugLog("Remote download failed!\n\nPath: %@\nStatusCode: %d\nError: %@\n", key, String(describing: response.httpResponse?.statusCode), String(describing: response.httpError))
            
            md[NotificationKeys.Error] = response.httpError
            
            DispatchQueue.main.async
            {
                NotificationCenter.default.post(name: Notifications.DataDownloadFailed, object: nil, userInfo: md)
            }
            
            if let handlers = httpRequestLookups[key]
            {
                notifyRemoteDownloadHandlers(key: key, data: nil, error: response.httpError, handlers: handlers)
            }
        }
        
        pendingDownloads.removeValue(forKey: key)
        httpRequestLookups.removeValue(forKey: key)
    }
    
    private func updateMetaDataFromResponse(_ response: UUHttpResponse, for key: String)
    {
        var md = UUDataCache.shared.metaData(for: key)
        md[MetaData.MimeType] = response.httpResponse!.mimeType!
        md[MetaData.DownloadTimestamp] = Date()
        
        UUDataCache.shared.set(metaData: md, for: key)
    }
    
    public func save(data: Data, key: String)
    {
        UUDataCache.shared.set(data: data, for: key)
        
        var md = UUDataCache.shared.metaData(for: key)
        md[MetaData.MimeType] = "raw"
        md[MetaData.DownloadTimestamp] = Date()
        md[UURemoteData.NotificationKeys.RemotePath] = key
        
        UUDataCache.shared.set(metaData: md, for: key)
        
        notifyDataDownloaded(metaData: md)
    }
    
    private func notifyDataDownloaded(metaData: [String:Any])
    {
        DispatchQueue.main.async
        {
            NotificationCenter.default.post(name: Notifications.DataDownloaded, object: nil, userInfo: metaData)
        }
    }
    
    private func notifyRemoteDownloadHandlers(key: String, data: Data?, error: Error?, handlers: [UUDataLoadedCompletionBlock])
    {
        for handler in handlers
        {
            DispatchQueue.main.async
            {
                handler(data, error)
            }
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    /*
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
            
            if let index = self.activeRequests.firstIndex(where: { $0 == path })
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
    */
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
