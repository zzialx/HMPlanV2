//
//  PlistHelper.h
//  WinChannelFrameWork
//
//  Created by Cai Lei on 10/19/12.
//
//

#import <Foundation/Foundation.h>

@interface WCPlistHelper : NSObject
@property (nonatomic, strong, readonly) NSDictionary *allProperties;

- (id)initWithPlistNamed:(NSString *)aPlistName;

@end
