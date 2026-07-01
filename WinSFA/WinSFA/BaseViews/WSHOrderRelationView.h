//
//  WSHOrderRelationView.h
//  WinSFA
//
//  Created by HZH on 2017/7/23.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSHOrderRelationView : UIView

@property (nonatomic, strong) WSFuncsBean *funcsBean;
@property (nonatomic, strong) NSDictionary *dataCacheDic;
@property (nonatomic, strong) NSArray *prodFirstLevelTypesArray;

- (id)initWithFrame:(CGRect)frame andFuncsBean:(WSFuncsBean *)funcsBean andDataCache:(NSDictionary *)dataCacheDic;

- (void)resetDataSource;

- (void)resetTotalCount:(NSString *)totalCountStr;

@end
