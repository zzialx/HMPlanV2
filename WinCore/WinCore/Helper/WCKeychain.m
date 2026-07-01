//
//  WCKeychain.m
//  WinCore
//
//  Created by dujinfeng481 on 14-5-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WCKeychain.h"

@implementation WCKeychain

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge id)(kSecClassGenericPassword),(__bridge id)(kSecClass),
            service, (__bridge id)(kSecAttrService),
            service, (__bridge id)(kSecAttrAccount),
            (__bridge id)(kSecAttrAccessibleAfterFirstUnlock),(__bridge id)(kSecAttrAccessible),
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    
    CFDictionaryRef query = CFBridgingRetain(keychainQuery);
    
    //Delete old item before add new item
    SecItemDelete(query);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)(kSecValueData)];
    //Add item to keychain with the search dictionary
    OSStatus statusAdd = SecItemAdd(query, NULL);
    if (statusAdd != errSecSuccess) {
        LogError(@"error save keychain, error code is %d", (int)statusAdd);
    }

    if (query) {
        CFBridgingRelease(query);
    }
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    //Since in our simple case we are expecting only a single attribute to be returned (the password) we can set the attribute kSecReturnData to kCFBooleanTrue
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)(kSecReturnData)];
    [keychainQuery setObject:(id)CFBridgingRelease(kSecMatchLimitOne) forKey:(__bridge id)(kSecMatchLimit)];
    
    CFDictionaryRef query = CFBridgingRetain(keychainQuery);
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching(query, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)(keyData)];
        } @catch (NSException *e) {
            //            NSLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    if (keyData)
        CFRelease(keyData);
    if (query) {
        CFBridgingRelease(query);
    }
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge CFDictionaryRef)(keychainQuery));
}

@end
