//
//  WCSpbaInfoBean.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 6/27/13.
//
//

#import <Foundation/Foundation.h>

@interface WSSpbaInfoBean : NSObject

@property (nonatomic, readonly, strong) NSNumber *empId;
@property (nonatomic, readonly, strong) NSNumber *acvtId;
@property (nonatomic, readonly, strong) NSNumber *spbaInfoId;
@property (nonatomic, readonly, copy) NSString *name;
@property (nonatomic, readonly, copy) NSString *typ;
@property (nonatomic, readonly, strong) NSNumber *speechLevleId;
@property (nonatomic, readonly, strong) NSNumber *brandTrendId;


- (id)initWithObject:(id)aObject;

@end
