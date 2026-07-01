//
//  empinforefreshBean.h
//  WinChannelFrameWork
//
//  Created by wdy on 12-4-10.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSEmpinforefreshBean : NSObject

@property (nonatomic, copy, readonly) NSString  *empId;
@property (nonatomic, copy, readonly) NSString  *col1;
@property (nonatomic, copy, readonly) NSString  *col2;
@property (nonatomic, copy, readonly) NSString  *col3;
@property (nonatomic, copy, readonly) NSString  *col4;
@property (nonatomic, copy, readonly) NSString  *col5;
@property (nonatomic, copy, readonly) NSString  *col6;
@property (nonatomic, copy, readonly) NSString  *col7;
@property (nonatomic, copy, readonly) NSString  *col8;
@property (nonatomic, copy, readonly) NSString  *typ;
@property (nonatomic, copy, readonly) NSString  *typid;
@property (nonatomic, strong, readonly)NSDictionary *iEmpinfo;

- (id)initWithObject:(id)object;

@end
