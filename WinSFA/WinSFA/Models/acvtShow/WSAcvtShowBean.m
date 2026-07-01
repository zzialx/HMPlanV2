//
//  WCAcvtShowBean.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/14/13.
//
//

#import "WSAcvtShowBean.h"

@implementation WSAcvtShowBean

@synthesize iId = _iId;
@synthesize iName = _iName;


#pragma mark - init and dealloc
- (id)initWithObject:(id) aObject
{
    self = [super init];
    if (self){
        if (aObject != nil && [aObject isKindOfClass:[NSDictionary class]]) {
            _iId = [aObject objectForKey:@"id"]; // acvt id
            _iName = [[NSString stringWithValue:[aObject objectForKey:@"name"]] copy]; // content
        }
    }
    
    return self;
}




@end
