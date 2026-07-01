//
//  WSActionListView.h
//  WinSFA
//
//  Created by yang on 17/1/15.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kActionInfoDicTitleKey @"title"
#define kActionInfoDicImageKey @"image"
#define kActionInfoDicSelectorKey @"selector"

@interface WSActionListView : UIView

- (instancetype)initWithFrame:(CGRect)frame actionDicInfoList:(NSArray *)dicInfoArray target:(id)target;

- (void)showOnView:(UIView *)view fromPoint:(CGPoint)point;

@end
