//
//  FUISingleSelectionListView.h
//  WinSFA
//  单选下拉列表
//  Created by dujinfeng481 on 14-7-28.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FUISingleSelectionSource;

typedef void(^FSelectedBlock)(NSString *key, NSInteger selectIndex, FUISingleSelectionSource *selectObject);

@interface FUISingleSelectionSource : NSObject
@property (nonatomic, strong) NSString*     sId;
@property (nonatomic, strong) NSString*     sName;

-(id) initWithName:(NSString*)pName withId:(NSString*)pId;

@end

@interface FUISingleSelectionListView : UIView

/**
 *  初始化单选列表
 *
 *  @param frame       位置
 *  @param sourceArray 下拉列表资源(FUISingleSelectionSource object)
 *  @param selectedStr 默认选中项标题or ID，未指定默认不填写
 *
 *  @return view
 */
- (id)initWithFrame:(CGRect)frame
         withKeyStr:(NSString*)sKey
withListSourceArray:(NSArray*)sourceArray
    withSelectedStr:(NSString*)selectedStr
          withBlock:(FSelectedBlock)block;

@end
