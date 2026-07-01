//
//  WCDicBeanItemOfChoice.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/17/13.
//
//

#import "WSDicBeanItemOfChoice.h"

@implementation WSDicBeanItemOfChoice

@synthesize name = _name;
@synthesize iDictBean = _iDictBean;


#pragma mark - init and dealloc

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization
    }
    return self;
}

- (id)initWithDictBean:(WSDictBean *)aDictBean
{
    if (aDictBean == nil) return nil;
    
    self = [super init];
    if (self) {
        _name = [aDictBean.name copy];
        _iDictBean = aDictBean;
    }
    return self;
}




@end
