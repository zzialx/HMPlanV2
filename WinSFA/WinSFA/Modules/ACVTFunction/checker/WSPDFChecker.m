//
//  WSPDFChecker.m
//  WinSFA
//
//  Created by yang on 15/6/4.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPDFChecker.h"
#import "I_CheckerInfo.h"

@implementation WSPDFChecker

- (BOOL)checkObjectIsValidate:(NSObject *)checkobject
{
    if (![checkobject isKindOfClass:[NSString class]]) {
        
        return NO;
    }
    
    NSString *filePath = (NSString *)checkobject;
    
    CFURLRef urlRef = (__bridge CFURLRef)[NSURL fileURLWithPath:filePath isDirectory:NO];
    
    if (urlRef == NULL) {
        return NO;
    }
    
    CGPDFDocumentRef thePDFDocRef = CGPDFDocumentCreateWithURL(urlRef);
    
    if (thePDFDocRef == NULL) {
        return NO;
    }
    
    CGPDFDocumentRelease(thePDFDocRef);
    
    return YES;
}

@end
