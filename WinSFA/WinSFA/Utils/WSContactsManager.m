//
//  WSContactsManager.m
//  WinSFA
//
//  Created by yang on 13-10-16.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import "WSContactsManager.h"
#import <AddressBook/AddressBook.h>
#import "WSEnvrionment.h"

static WSContactsManager *instance = nil;

@implementation WSContactsManager

+ (WSContactsManager *)sharedInstance
{
    if (instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            instance = [[WSContactsManager alloc] init];
        });
    }
    return instance;
}

- (void)addServiceCallToAddressBook
{
    
    if (![[UIDevice currentDevice] systemVersionLowerThan:@"9.0"]) {
        return;
    }
    
    ABAddressBookRef addressBookRef = NULL;
    
    if ([[UIDevice currentDevice] systemVersionLowerThan:@"6.0"]) {
        
        addressBookRef = ABAddressBookCreate();
        [self _addServiceCallToAddressBook:addressBookRef];
        if (addressBookRef) CFRelease(addressBookRef);
    }
    else
    {
        addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);
        
        if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
            ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
                if (granted) {
                    [self _addServiceCallToAddressBook:addressBookRef];
                } else {
                    LogInfo(@"用户拒绝访问通讯录");
                }
                if (addressBookRef)
                    CFRelease(addressBookRef);
            });
        }
        else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
            
            [self _addServiceCallToAddressBook:addressBookRef];
            
            if (addressBookRef)
                CFRelease(addressBookRef);
        }
        else {
            LogInfo(@"用户拒绝访问通讯录");
            if (addressBookRef)
                CFRelease(addressBookRef);
        }
    }
    
}

#pragma mark - private methods

- (BOOL)isContactNameExist:(NSString*)name inAddressBook:(ABAddressBookRef)addressBook
{
    NSArray* thePeople = (NSArray*)CFBridgingRelease(ABAddressBookCopyPeopleWithName(addressBook, (__bridge CFStringRef)name));
    if (thePeople && [thePeople count] > 0) {
        return YES;
    }
    return NO;
}

- (void)_addServiceCallToAddressBook:(ABAddressBookRef)addressBook
{
    
    NSString* firstname = NSLocalizedString(@"service_hotline",nil);
    NSString* phonenumber = [WSEnvrionment getHotline];
    
    if (!phonenumber || !firstname || [phonenumber length] == 0 || [firstname length] == 0) {
        return;
    }
    
    if (![self isContactNameExist:firstname inAddressBook:addressBook]) {
        ABRecordRef contactRef = ABPersonCreate();
        
        CFErrorRef error = NULL;
        
        
        //Add first name
        ABRecordSetValue(contactRef, kABPersonFirstNameProperty, (__bridge CFTypeRef)(firstname), &error);
        
        //Add phone number
        ABMutableMultiValueRef phoneNumberMultiValue = ABMultiValueCreateMutable(kABPersonPhoneProperty);
        ABMultiValueAddValueAndLabel(phoneNumberMultiValue, (__bridge CFTypeRef)(phonenumber), kABPersonPhoneMobileLabel, NULL);
        ABRecordSetValue(contactRef, kABPersonPhoneProperty, phoneNumberMultiValue, &error);
        
        ABAddressBookAddRecord(addressBook, contactRef, NULL);
        ABAddressBookSave(addressBook, NULL);
        
        if (phoneNumberMultiValue) CFRelease(phoneNumberMultiValue);
        if (contactRef) CFRelease(contactRef);
        
    }
    
}


@end
