//
//  NSError+Description.m
//  WinSFA
//
//  Created by yang on 2017/7/11.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "NSError+Description.h"

@implementation NSError (Description)

- (NSString *)ws_localizedDescription {
    
    NSString *result = [self localizedDescription];
    
    if (self.code == NSURLErrorNetworkConnectionLost) {
        NSString *customStr = NSLocalizedString(@"server_connect_error", nil);
        if ([customStr length] > 0 && ![customStr isEqualToString:@"server_connect_error"]) {
            result = customStr;
        }
    }
    
    return result;
}

@end
