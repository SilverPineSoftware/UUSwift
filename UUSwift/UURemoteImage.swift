//
//  UURemoteImage.swift
//  Useful Utilities - An extension to Useful Utilities
//  UURemoteData that exposes the cached data as UIImage objects
//
//	License:
//  You are free to use this code for whatever purposes you desire.
//  The only requirement is that you smile everytime you use it.
//
//  NOTE: This class depends on the following toolbox classes:
//
//  UUHttpSession
//  UUDataCache
//  UURemoteData
//
#if os(macOS)
	import AppKit
	public typealias UUImage = NSImage
#else
	import UIKit
	public typealias UUImage = UIImage
#endif

public typealias UUImageLoadedCompletionBlock = (UUImage?, Error?) -> Void


public class UURemoteImage: NSObject
{
    public static let shared = UURemoteImage()

    public func imageSize(for path: String) -> CGSize?
    {
        let md = UUDataCache.shared.metaData(for: path)
        return md[MetaData.ImageSize] as? CGSize
    }    
    
    public func local(_ path : String) -> Bool
    {
        if let _ = self.systemImageCache.object(forKey: path as NSString)
        {
            return true
        }
        if UUDataCache.shared.doesDataExist(for: path)
        {
            return true
        }
        
        return false
    }

    public func image(_ path : String, completion : @escaping UUImageLoadedCompletionBlock)
    {
        // Check the local cache...
        if let image = self.systemImageCache.object(forKey: path as NSString) as? UUImage
        {
            completion(image, nil)
            return
        }
        else
        {
            UURemoteData.shared.get(path)
            { (data, error) in
                var image : UUImage? = nil
                
                if let imageData = data
                {
                    image = UUImage(data: imageData)
                    if let img = image
                    {
                        self.systemImageCache.setObject(img, forKey: path as NSString)
                        
                        var md : [String : Any] =  UUDataCache.shared.metaData(for: path)
                        md[MetaData.ImageSize] = img.size
                        UUDataCache.shared.set(metaData: md, for: path)
                    }
                }
                
                completion(image, error)
            }
        }
    }
    
    ////////////////////////////////////////////////////////////////////////////
    // Private implementation
    ////////////////////////////////////////////////////////////////////////////
    private let systemImageCache = NSCache<AnyObject, AnyObject>()
    
    private struct MetaData
    {
        static let ImageSize = "ImageSize"
    }

}
