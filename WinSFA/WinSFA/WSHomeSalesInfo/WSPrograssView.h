//
//  WSPrograssView.h
//  WinSFA
//
//  Created by mac on 2018/8/30.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSPrograssView : UIView

// 中间显示的数字
@property (nonatomic, assign) float rate;
// 开始动画
- (void)startAnimation;

+ (instancetype) sharedProgressViewManagerInitwithframe: (CGRect)frame imageName :(NSString *)imageName progressRate :(NSInteger)rate isNeedshowRate :(BOOL) isNeedShow;


@end
