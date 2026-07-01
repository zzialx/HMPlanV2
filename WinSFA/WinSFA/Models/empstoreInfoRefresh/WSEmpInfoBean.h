//
//  EmpInfoBean.h
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-6-25.
//
//

#import <Foundation/Foundation.h>

#define SUBEMPINFO  @"subEmpInfo"
#define EMPID       @"empId"
#define STORE_ID    @"storeId"
#define COL_NAME    @"col_name"
#define COL_VALUE   @"col_value"
#define COL_TYPE    @"col_type"
#define TYP         @"typ"

@interface WSEmpInfoBean : NSObject

@property (nonatomic, copy, readonly) NSString *empId;
@property (nonatomic, copy, readonly) NSString *store_id;
@property (nonatomic, copy, readonly) NSString *col_name;
@property (nonatomic, copy, readonly) NSString *col_value;
@property (nonatomic, copy, readonly) NSString *col_type;
@property (nonatomic, copy, readonly) NSString *typ;

@property (nonatomic, strong, readonly) NSArray *subEmpInfoArray;

- (id)initWithObject:(id)object;

@end
