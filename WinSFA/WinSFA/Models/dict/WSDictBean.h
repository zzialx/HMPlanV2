//
//  DictBean.h
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_W_OptionDataItem.h"

@interface WSDictBean : NSObject<I_W_OptionDataItem>

@property (nonatomic, copy/*, readonly*/) NSString  *dtyp;
@property (nonatomic, copy/*, readonly*/) NSString  *btyp;
@property (nonatomic, copy/*, readonly*/) NSString  *Id;
@property (nonatomic, copy/*, readonly*/) NSString  *name;
@property (nonatomic, copy/*, readonly*/) NSString  *cod;
@property (nonatomic, copy/*, readonly*/) NSString  *p;
@property (nonatomic, copy/*, readonly*/) NSString  *typ;
@property (nonatomic, copy/*, readonly*/) NSString  *SEQ;
@property (nonatomic, copy/*, readonly*/) NSString  *col1;
@property (nonatomic, copy/*, readonly*/) NSString  *col2;
@property (nonatomic, copy/*, readonly*/) NSArray  *child_data;
@property (nonatomic, copy/*, readonly*/) NSArray  *product;
@property (nonatomic, copy/*, readonly*/) NSString *empId;
@property (nonatomic, copy/*, readonly*/) NSString *levelCode;
@property (nonatomic, assign/*, readonly*/) BOOL isSelected;
@property (nonatomic, copy/*, readonly*/) NSString *iconUrl;
@property (nonatomic, copy/*, readonly*/) NSString *_id;

@property (nonatomic, copy) NSString *dicts_sequence;


//@property (nonatomic, strong) NSArray *childArray;

/*name中文拼音的首字母*/
@property (nonatomic, copy) NSString *fl;

//注销需求显示活动内容
@property (nonatomic, copy) NSString *memo;



- (id)initWithObject:(id)object;

@end
