//
//  UUDictionary.swift
//  Useful Utilities - Extensions for Dictionary
//
//	License:
//  You are free to use this code for whatever purposes you desire.
//  The only requirement is that you smile everytime you use it.
//

#if os(macOS)
	import AppKit
#else
	import UIKit
#endif


public extension Dictionary
{
    func uuBuildQueryString(_ appendSquareBracketsToQueryStringArrays: Bool = true) -> String
    {
        let sb : NSMutableString = NSMutableString()
        
        for key in keys
        {
            guard let stringKey = key as? String else
            {
                continue
            }
            
            let formattedKey = stringKey.uuUrlEncoded()
            
            var prefix = "&"
            if ((sb as String).count == 0)
            {
                prefix = "?"
            }
            
            let rawVal = self[key]
            var val : String? = nil
            
            if (rawVal is String)
            {
                val = rawVal as? String
            }
            else if (rawVal is NSNumber)
            {
                val = (rawVal as? NSNumber)?.stringValue
            }
            else if let arrayVal = rawVal as? [String]
            {
                var arrayKey = formattedKey
                if (appendSquareBracketsToQueryStringArrays)
                {
                    arrayKey = "\(formattedKey)[]"
                }
                
                for strVal in arrayVal
                {
                    if let formattedVal = strVal.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                    {
                        sb.appendFormat("%@%@=%@", prefix, arrayKey, formattedVal)
                        prefix = "&"
                    }
                }
                
                continue
            }
            
            if (val != nil)
            {
                if let formattedVal = val!.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                {
                    sb.appendFormat("%@%@=%@", prefix, formattedKey, formattedVal)
                }
            }
        }
        
        return sb as String
    }
    
    func uuSafeGetDate(_ key: Key, formatter: DateFormatter) -> Date?
    {
        guard let stringVal = self[key] as? String else
        {
            return nil
        }
        
        return formatter.date(from: stringVal)
    }
    
    // Unix timestamps are number of seconds since 01/01/1970 UTC.
    // This method assumes the value at the key is a double in milliseconds representing
    // the time since 1/1/1970
    func uuSafeGetUnixDateFromMilliseconds(_ key: Key, _ defaultValue: Date = Date(timeIntervalSince1970: 0)) -> Date
    {
        return uuGetUnixDateFromMilliseconds(key) ?? defaultValue
    }
    
    // Unix timestamps are number of seconds since 01/01/1970 UTC.
    // This method assumes the value at the key is a double in seconds representing
    // the time since 1/1/1970
    func uuSafeGetUnixDateFromSeconds(_ key: Key, _ defaultValue: Date = Date(timeIntervalSince1970: 0)) -> Date
    {
        return uuGetUnixDateFromSeconds(key) ?? defaultValue
    }
    
    // Unix timestamps are number of seconds since 01/01/1970 UTC.
    // This method assumes the value at the key is a double in milliseconds representing
    // the time since 1/1/1970
    func uuGetUnixDateFromMilliseconds(_ key: Key) -> Date?
    {
        guard let doubleVal = uuGetDouble(key) else
        {
            return nil
        }
        
        return Date(timeIntervalSince1970: doubleVal / 1000.0)
    }
    
    // Unix timestamps are number of seconds since 01/01/1970 UTC.
    // This method assumes the value at the key is a double in seconds representing
    // the time since 1/1/1970
    func uuGetUnixDateFromSeconds(_ key: Key) -> Date?
    {
        guard let doubleVal = uuGetDouble(key) else
        {
            return nil
        }
        
        return Date(timeIntervalSince1970: doubleVal)
    }
    
    func uuSafeGetString(_ key: Key, _ defaultValue: String = "") -> String
    {
        return uuGetString(key) ?? defaultValue
    }
    
    func uuGetString(_ key: Key) -> String?
    {
        return self[key] as? String
    }
    
    func uuSafeGetStringArray(_ key: Key) -> [String]
    {
        return uuGetStringArray(key) ?? []
    }
    
    func uuGetStringArray(_ key: Key) -> [String]?
    {
        return self[key] as? [String]
    }
    
    func uuSafeGetNumber(_ key: Key, _ defaultValue: NSNumber = NSNumber(value: 0)) -> NSNumber
    {
        return uuGetNumber(key) ?? defaultValue
    }
    
    func uuGetNumber(_ key: Key) -> NSNumber?
    {
        var val = self[key] as? NSNumber
        
        if (val == nil)
        {
            if let str = uuGetString(key)
            {
                let nf = NumberFormatter()
                nf.numberStyle = .decimal
                val = nf.number(from: str)
            }
        }
        
        return val
    }
    
    func uuSafeGetNumberArray(_ key: Key) -> [NSNumber]
    {
        guard let arr = self[key] as? [Any] else
        {
            return []
        }
        
        var result: [NSNumber] = []
        
        for obj in arr
        {
            let d = ["val": obj ]
            if let num = d.uuGetNumber("val")
            {
                result.append(num)
            }
        }
        
        return result
    }
    
    func uuSafeGetBool(_ key: Key, _ defaultValue: Bool = false) -> Bool
    {
        return uuGetBool(key) ?? defaultValue
    }
    
    func uuGetBool(_ key: Key) -> Bool?
    {
        if let str = uuGetString(key)?.lowercased()
        {
            if "true" == str
            {
                return true
            }
            else if "false" == str
            {
                return false
            }
        }
        
        if let num = uuGetNumber(key)
        {
            return num.boolValue
        }
        
        return nil
    }
    
    func uuSafeGetBoolNumber(_ key: Key, _ defaultValue: Bool) -> NSNumber
    {
        return uuGetNumber(key) ?? NSNumber(value: defaultValue)
    }
    
    func uuGetBoolNumber(_ key: Key) -> NSNumber?
    {
        if let bool = uuGetBool(key)
        {
            return NSNumber(value: bool)
        }
        
        return nil
    }
    
    func uuGetInt(_ key: Key) -> Int?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.intValue
    }
    
    func uuGetUInt8(_ key: Key) -> UInt8?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.uint8Value
    }
    
    func uuGetUInt16(_ key: Key) -> UInt16?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.uint16Value
    }
    
    func uuGetUInt32(_ key: Key) -> UInt32?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.uint32Value
    }
    
    func uuGetUInt64(_ key: Key) -> UInt64?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.uint64Value
    }
    
    func uuGetInt8(_ key: Key) -> Int8?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.int8Value
    }
    
    func uuGetInt16(_ key: Key) -> Int16?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.int16Value
    }
    
    func uuGetInt32(_ key: Key) -> Int32?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.int32Value
    }
    
    func uuGetInt64(_ key: Key) -> Int64?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.int64Value
    }
    
    func uuGetFloat(_ key: Key) -> Float?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.floatValue
    }
    
    func uuGetDouble(_ key: Key) -> Double?
    {
        guard let num = uuGetNumber(key) else
        {
            return nil
        }
        
        return num.doubleValue
    }
    
    func uuSafeGetInt(_ key: Key, _ defaultValue: Int = 0) -> Int
    {
        if let val = uuGetInt(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetUInt8(_ key: Key, _ defaultValue: UInt8 = 0) -> UInt8
    {
        if let val = uuGetUInt8(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetUInt16(_ key: Key, _ defaultValue: UInt16 = 0) -> UInt16
    {
        if let val = uuGetUInt16(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetUInt32(_ key: Key, _ defaultValue: UInt32 = 0) -> UInt32
    {
        if let val = uuGetUInt32(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetUInt64(_ key: Key, _ defaultValue: UInt64 = 0) -> UInt64
    {
        if let val = uuGetUInt64(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetInt8(_ key: Key, _ defaultValue: Int8 = 0) -> Int8
    {
        if let val = uuGetInt8(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetInt16(_ key: Key, _ defaultValue: Int16 = 0) -> Int16
    {
        if let val = uuGetInt16(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetInt32(_ key: Key, _ defaultValue: Int32 = 0) -> Int32
    {
        if let val = uuGetInt32(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetInt64(_ key: Key, _ defaultValue: Int64 = 0) -> Int64
    {
        if let val = uuGetInt64(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetFloat(_ key: Key, _ defaultValue: Float = 0) -> Float
    {
        if let val = uuGetFloat(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuSafeGetDouble(_ key: Key, _ defaultValue: Double = 0) -> Double
    {
        if let val = uuGetDouble(key)
        {
            return val
        }
        
        return defaultValue
    }
    
    func uuGetDictionary(_ key: Key) -> [AnyHashable:Any]?
    {
        return self[key] as? [AnyHashable:Any]
    }
    
    func uuGetObject<T: UUDictionaryConvertible>(type: T.Type, key: Key) -> T?
    {
        guard let d = uuGetDictionary(key) else
        {
            return nil
        }
        
        return T.create(from: d)
    }
    
    func uuGetEnum<T: RawRepresentable>(_ key: Key) -> T? where T.RawValue == String
    {
        guard let string = uuGetString(key) else
        {
            return nil
        }
        
        return T(rawValue: string)
    }
    
    func uuSafeGetEnum<T: RawRepresentable>(_ key: Key, _ defaultValue: T) -> T where T.RawValue == String
    {
        return uuGetEnum(key) ?? defaultValue
    }
    
    func uuGetDictionaryArray(_ key: Key) -> [[AnyHashable:Any]]?
    {
        return self[key] as? [[AnyHashable:Any]]
    }
    
    func uuGetObjectArray<T: UUDictionaryConvertible>(type: T.Type, key: Key) -> [T]?
    {
        guard let array = uuGetDictionaryArray(key) else
        {
            return nil
        }
        
        var list: [T] = []
        for d in array
        {
            list.append(T.create(from: d))
        }
        
        return list
    }
    
    func uuSafeGetObjectArray<T: UUDictionaryConvertible>(type: T.Type, key: Key) -> [T]
    {
        guard let array = uuGetDictionaryArray(key) else
        {
            return []
        }
        
        var list: [T] = []
        for d in array
        {
            list.append(T.create(from: d))
        }
        
        return list
    }
    
    mutating func uuChangeKey(_ oldKey: Key, _ newKey: Key)
    {
        if (self[newKey] == nil && self[oldKey] != nil)
        {
            self[newKey] = self[oldKey]
            self.removeValue(forKey: oldKey)
        }
    }
    
    mutating func uuTrimKeys(_ keysToKeep: [Key])
    {
        for key in self.keys
        {
            if !(keysToKeep.contains(key))
            {
                self.removeValue(forKey: key)
            }
        }
    }
}

public extension Array where Element == Dictionary<AnyHashable, Any>
{
    func uuSafeGetString(_ key: Dictionary<AnyHashable, Any>.Key) -> [String]
    {
        return self.compactMap({ $0.uuSafeGetString(key) })
    }
}

public protocol UUDictionaryConvertible
{
    init()
    
    func fill(from dictionary: [AnyHashable:Any])
    func toDictionary() -> [AnyHashable:Any]
}

public extension UUDictionaryConvertible
{
    static func create(from dictionary : [AnyHashable:Any]) -> Self
    {
        let obj = self.init()
        obj.fill(from: dictionary)
        return obj
    }
    
    func clone() -> Self
    {
        return Self.create(from: toDictionary())
    }

    func isJsonEqual(_ other: UUDictionaryConvertible) -> Bool
    {
        let left = toDictionary().uuToJsonString()
        let right = other.toDictionary().uuToJsonString()
        return (left == right)
    }
}

extension Array where Element:UUDictionaryConvertible
{
    public func uuToDictionaryArray() -> [[AnyHashable:Any]]
    {
        return map({ $0.toDictionary() })
    }
}
