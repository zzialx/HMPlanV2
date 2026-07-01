//
//  WCURLUILabel.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/15/13.
//
//

#import <UIKit/UIKit.h>

@interface WCURLUILabel : UILabel

@property (nonatomic, copy) NSString *iImageURL;
@property (nonatomic, copy) NSString *detailText;

@property (nonatomic, weak) id container;               //装载容器
@property (nonatomic, assign) NSInteger longPressTag;   //长按标示

@end
