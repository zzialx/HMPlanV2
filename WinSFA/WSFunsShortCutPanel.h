//
//  WSFunsShortCutPanel.h
//  WinSFA
//
//  Created by winchannel on 15/9/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "WSFuncsBeanArray.h"

@class WSFunsShortCutPanel ;
@class WSShortCutButton;

@protocol WSFunsShortCutPanelDelegate <NSObject>

@optional
- (void)funsShortCutPanel:(WSFunsShortCutPanel *)funsShortCutPanel didAddedBtnForID:(NSString *)imageID;

- (void)funsShortCutPanel:(WSFunsShortCutPanel *)funsShortCutPanel didSelectBtnFuncsBean:(WSFuncsBean *)bean withStoreBean:(WSStoreBean *)storeBean;

@end

@interface WSFunsShortCutPanel : UIView

@property (nonatomic ,weak) id<WSFunsShortCutPanelDelegate>delegate;

//@property (nonatomic , strong) NSMutableArray *imageIDArray;
//
//@property (nonatomic ,strong) NSMutableArray *shortCutBtnArray;
//
//@property (nonatomic ,strong) WSShortCutButton *btn;
//
//@property (nonatomic ,assign) float cellWidth;

- (id)initWithFrame:(CGRect)frame;

- (void)refreshImagesFromFunsBeanArray:(NSArray *)array withStoreBean:(WSStoreBean *)storeBean;

//- (void)addShortCutButton:(WSFuncsBean *)bean andImae:(UIImage *)image andIndex:(NSInteger)index;
@end
