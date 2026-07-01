//
//  PlistHelper.m
//  WinChannelFrameWork
//
//  Created by Cai Lei on 10/19/12.
//
//

#import "WCPlistHelper.h"

@interface WCPlistHelper ()
@property (nonatomic, copy) NSString *plistName;
@end

@implementation WCPlistHelper
@synthesize plistName = plistName_;
@synthesize allProperties = allProperties_;

- (id)initWithPlistNamed:(NSString *)aPlistName {
    self = [super init];
    if (self) {
        plistName_ = [aPlistName copy];
        allProperties_ = [[NSDictionary alloc] init];
    }
    return self;
}


- (NSDictionary *)allProperties {
    if (!self.plistName) {
        return nil;
    }
    
    NSString *filepath = [[NSBundle mainBundle] pathForResource:self.plistName ofType:@"plist"];
    if (!filepath) {
        return nil;
    }
    
    NSDictionary *properties = [NSDictionary dictionaryWithContentsOfFile:filepath];
    return properties;
}

@end
