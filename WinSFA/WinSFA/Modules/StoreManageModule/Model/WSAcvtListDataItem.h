//
//  WSAcvtListDataItem.h
//  WinSFA
//
//  Created by yang on 16/11/2.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSAcvtListDataItem : NSObject

@property (nonatomic, copy) NSString *genID;

@property (nonatomic, copy) NSString *acvtID;

@property (nonatomic, copy) NSString *mainTitle;

@property (nonatomic, strong) NSMutableAttributedString *subTitle;

@property (nonatomic, copy) NSString *leftTitle;

@property (nonatomic, copy) NSString *rightTitle;

@property (nonatomic, copy) NSString *newstoreid;

@property (nonatomic, assign) BOOL unRead;

@property (nonatomic, assign) BOOL isChecked;

@property (nonatomic, strong) NSArray *qstDisArray;

@property (nonatomic, strong) NSString *leftIconUrl;

@property (nonatomic, copy) NSString *rightTitleColor;

@property (nonatomic, copy) NSString *groupName;//YIHAIKERRY-1142益海嘉里深圳分组需求summary

@property (nonatomic, copy) NSString *groupSummary;//YIHAIKERRY-1722益海嘉里深圳分组金额汇总需求

@property (nonatomic, copy) NSString *groupExpression;
@property (nonatomic, copy) NSString *requiredLogo; //史克otc。必填标示

@end
