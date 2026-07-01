//
//  WSRichMediaOptionBar.h
//  选项卡
//
//  Created by huzepei on 16/7/26.
//  Copyright © 2016年 huzepei. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSRichMediaOptionBar;

@protocol WSRichMediaOptionBarDelegate <NSObject>

- (void)WSRichMediaOptionBarClickWithStringID:(NSString *)str;

@end

@interface WSRichMediaOptionBar : UIView

@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,copy) NSString *groupHeaderName;
@property (nonatomic,copy) NSString *groupHeaderID;
@property (nonatomic,strong) NSArray *kindStringIDs;
@property (nonatomic,weak) id <WSRichMediaOptionBarDelegate> delagate;

@end
