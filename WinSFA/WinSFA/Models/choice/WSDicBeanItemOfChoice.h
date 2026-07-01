//
//  WCDicBeanItemOfChoice.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/17/13.
//
//

#import <Foundation/Foundation.h>
#import "WSBaseItemOfChoice.h"
#import "WSDictBean.h"

@interface WSDicBeanItemOfChoice : NSObject <WSBaseItemOfChoice>

@property (nonatomic, strong)WSDictBean *iDictBean;

- (id)init;
- (id)initWithDictBean:(WSDictBean *)aDictBean;

@end
