/*
    Copyright (C) 2014 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    
                Handles application configuration logic and information.
            
*/

import Foundation

public typealias StorageState = (storageOption: AppConfiguration.Storage, accountDidChange: Bool, cloudAvailable: Bool)

public class AppConfiguration {
    private struct Defaults {
        static let firstLaunchKey = "AppConfiguration.Defaults.firstLaunchKey"
        static let storageOptionKey = "AppConfiguration.Defaults.storageOptionKey"
        static let storedUbiquityIdentityToken = "AppConfiguration.Defaults.storedUbiquityIdentityToken"
    }
    
    public struct UserActivity {
        public static let listColorUserInfoKey = "listColor"
    }
    
    /*
        The value of the `LISTER_BUNDLE_PREFIX` user-defined build setting is written to the Info.plist file of
        every target in Swift version of the Lister project. Specifically, the value of `LISTER_BUNDLE_PREFIX` 
        is used as the string value for a key of `AAPLListerBundlePrefix`. This value is loaded from the target's
        bundle by the lazily evaluated static variable "prefix" from the nested "Bundle" struct below the first
        time that "Bundle.prefix" is accessed. This avoids the need for developers to edit both `LISTER_BUNDLE_PREFIX`
        and the code below. The value of `Bundle.prefix` is then used as part of an interpolated string to insert
        the user-defined value of `LISTER_BUNDLE_PREFIX` into several static string constants below.
    */
    private struct Bundle {
        static var prefix = NSBundle.mainBundle().objectForInfoDictionaryKey("AAPLListerBundlePrefix") as String
    }

    struct ApplicationGroups {
        static let primary = "group.\(Bundle.prefix).Lister.Documents"
    }
    
    #if os(OSX)
    public struct App {
        public static let bundleIdentifier = "\(Bundle.prefix).ListerOSX"
    }
    #endif
    
    public struct Extensions {
        #if os(iOS)
        public static let widgetBundleIdentifier = "\(Bundle.prefix).Lister.ListerToday"
        #elseif os(OSX)
        public static let widgetBundleIdentifier = "\(Bundle.prefix).Lister.ListerTodayOSX"
        #endif
    }
    
    public enum Storage: Int {
        case NotSet = 0, Local, Cloud
    }
    
    public class var sharedConfiguration: AppConfiguration {
        struct Singleton {
            static let sharedAppConfiguration = AppConfiguration()
        }

        return Singleton.sharedAppConfiguration
    }
    
    public class var listerUTI: String {
        return "com.example.apple-samplecode.Lister"
    }
    
    public class var listerFileExtension: String {
        return "list"
    }
    
    public class var defaultListerDraftName: String {
        return NSLocalizedString("List", comment: "")
    }
    
    public class var localizedTodayDocumentName: String {
        return NSLocalizedString("Today", comment: "The name of the Today list")
    }
    
    public class var localizedTodayDocumentNameAndExtension: String {
        return "\(localizedTodayDocumentName).\(listerFileExtension)"
    }
    
    private var applicationUserDefaults: NSUserDefaults {
        return NSUserDefaults(suiteName: ApplicationGroups.primary)!
    }
    
    public private(set) var isFirstLaunch: Bool {
        get {
            registerDefaults()
            
            return applicationUserDefaults.boolForKey(Defaults.firstLaunchKey)
        }
        set {
            applicationUserDefaults.setBool(newValue, forKey: Defaults.firstLaunchKey)
        }
    }
    
    private func registerDefaults() {
        #if os(iOS)
            let defaultOptions: [NSObject: AnyObject] = [
                Defaults.firstLaunchKey: true,
                Defaults.storageOptionKey: Storage.NotSet.rawValue
            ]
        #elseif os(OSX)
            let defaultOptions: [NSObject: AnyObject] = [
                Defaults.firstLaunchKey: true
            ]
        #endif
        
        applicationUserDefaults.registerDefaults(defaultOptions)
    }
    
    public func runHandlerOnFirstLaunch(firstLaunchHandler: Void -> Void) {
        if isFirstLaunch {
            isFirstLaunch = false

            firstLaunchHandler()
        }
    }
    
    public var isCloudAvailable: Bool {
        return NSFileManager.defaultManager().ubiquityIdentityToken != nil
    }
    
    #if os(iOS)
    public var storageState: StorageState {
        return (storageOption, hasAccountChanged(), isCloudAvailable)
    }
    
    public var storageOption: Storage {
        get {
            let value = applicationUserDefaults.integerForKey(Defaults.storageOptionKey)
            
            return Storage(rawValue: value)!
        }

        set {
            applicationUserDefaults.setInteger(newValue.rawValue, forKey: Defaults.storageOptionKey)
        }
    }

    // MARK: Ubiquity Identity Token Handling (Account Change Info)
    
    public func hasAccountChanged() -> Bool {
        var hasChanged = false
        
        let currentToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? = NSFileManager.defaultManager().ubiquityIdentityToken
        let storedToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? = storedUbiquityIdentityToken
        
        let currentTokenNilStoredNonNil = currentToken == nil && storedToken != nil
        let storedTokenNilCurrentNonNil = currentToken != nil && storedToken == nil
        
        // Compare the tokens.
        let currentNotEqualStored = currentToken != nil && storedToken != nil && !currentToken!.isEqual(storedToken!)
        
        if currentTokenNilStoredNonNil || storedTokenNilCurrentNonNil || currentNotEqualStored {
            persistAccount()
            
            hasChanged = true
        }
        
        return hasChanged
    }

    private func persistAccount() {
        var defaults = applicationUserDefaults
        
        if let token = NSFileManager.defaultManager().ubiquityIdentityToken {
            let ubiquityIdentityTokenArchive = NSKeyedArchiver.archivedDataWithRootObject(token)
            
            defaults.setObject(ubiquityIdentityTokenArchive, forKey: Defaults.storedUbiquityIdentityToken)
        }
        else {
            defaults.removeObjectForKey(Defaults.storedUbiquityIdentityToken)
        }
    }
    
    // MARK: Convenience

    private var storedUbiquityIdentityToken: protocol<NSCoding, NSCopying, NSObjectProtocol>? {
        var storedToken: protocol<NSCoding, NSCopying, NSObjectProtocol>?
        
        // Determine if the logged in iCloud account has changed since the user last launched the app.
        let archivedObject: AnyObject? = applicationUserDefaults.objectForKey(Defaults.storedUbiquityIdentityToken)
        
        if let ubiquityIdentityTokenArchive = archivedObject as? NSData {
            if let archivedObject = NSKeyedUnarchiver.unarchiveObjectWithData(ubiquityIdentityTokenArchive) as? protocol<NSCoding, NSCopying, NSObjectProtocol> {
                storedToken = archivedObject
            }
        }
        
        return storedToken
    }

    #endif
}