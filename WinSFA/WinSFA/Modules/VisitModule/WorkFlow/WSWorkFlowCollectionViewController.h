//
//  WSWorkFlowCollectionViewController.h
//  WinSFA
//
//  Created by Alicia on 17/2/14.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSWorkFlowViewController.h"

typedef NS_ENUM(NSInteger, WSWorkFlowViewStyleMode) {
    WSWorkFlowViewStyleCollection,      // 当前列表项按照多行多列显示
    WSWorkFlowViewStyleList         // 当前列表项按照多行单列显示
};

@interface WSWorkFlowCollectionViewController : WSBaseWorkFlowViewController



@property (nonatomic, strong) NSArray *allDataArray;


- (void)reloadData;
- (void)setBackgroundColor:(UIColor *)color;

@end
