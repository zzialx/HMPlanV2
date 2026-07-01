//
//  NSURLRequest+Https.m
//  WinSFA
//
//  Created by Stephanie on 16/5/20.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "NSURLRequest+Https.h"

@implementation NSURLRequest (Https)


+(BOOL)allowsAnyHTTPSCertificateForHost:(NSString *)host
{
    return YES;
}

@end
