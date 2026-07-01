//
//  SalesPersonInfoBean.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-3-12.
//
//

#import <Foundation/Foundation.h>

@interface WSSalesPersonInfoBean : NSObject

@property (nonatomic, copy) NSString *empId;
@property (nonatomic, copy) NSString *col1;
@property (nonatomic, copy) NSString *col2;
@property (nonatomic, copy) NSString *col3;
@property (nonatomic, copy) NSString *col4;
@property (nonatomic, copy) NSString *col5;
@property (nonatomic, copy) NSString *typ;

- (id)initWithObject:(id)object;

@end
