//
//  WSShowImageTextEdgeView.h
//  WinSFA
//
//  Created by mac on 2018/1/27.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSShowQstViewForStoreListCellModel : NSObject

@property (nonatomic , strong)  UIFont *titleFont; // 字体大小
@property (nonatomic , strong) NSArray *displayArray; // WSShowQstViewSingleLineModel的array
@property (nonatomic , strong)  UIColor *defaultColor; // 默认字体颜色
@property (nonatomic , strong) NSArray *horizontalDisplayArray; //横向显示的
@property (nonatomic , strong) NSArray *verticalDisplayArray; //纵向显示的WSShowQstViewSingleLineModel的array

@end

@interface WSShowQstViewSingleLineModel : NSObject

@property (nonatomic , copy) NSString *qstanwser;  // 问题的回显
@property (nonatomic , copy) NSString *qstdisplaymodel; // 问题的显示模式
@property (nonatomic , copy) NSString *qstname;         // 问题的名称
@property (nonatomic , copy) NSString *hideQstName;         // 是否隐藏问题的名称
@property (nonatomic , copy) NSString *groupName;         // 组名
@property (nonatomic , copy) NSString *qstIconUrl;         // 问题url
@end

@interface WSShowQstViewForStoreListCell : UIView
@property (nonatomic , assign) BOOL isHasQstHorizontal;  //是否有横向显示的问题
@property (nonatomic , strong)  WSShowQstViewForStoreListCellModel *currentModel;
@property (nonatomic , assign) CGFloat maxWidth; //显示的最大宽度

-(instancetype)initWithFrame:(CGRect)frame withModel:(WSShowQstViewForStoreListCellModel *)model isHasQstHorizontal:(BOOL)isHasQstHorizontal tagBottom:(NSString*)tagBottom;

+(CGFloat)getViewWidth:(WSShowQstViewForStoreListCellModel*)model;

+(NSString *)getTitleString:(WSShowQstViewSingleLineModel*)qstModel;

@end
