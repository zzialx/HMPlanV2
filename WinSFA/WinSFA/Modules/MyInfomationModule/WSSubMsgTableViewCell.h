//
//  WSSubMsgTableViewCell.h
//  WinSFA
//
//  Created by xiajl on 14-10-27.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIImageView+WebCache.h"

typedef enum{
	ECELLTAGStatusUnread = 1,
	ECELLTAGStatusRead,
}ECELLTAGStatus;

@interface WSSubMsgTableViewCell : UITableViewCell

@property (nonatomic, strong) UILabel *msgTitle_label;
@property (nonatomic, strong) UILabel *msgContent_label;

@property (nonatomic, strong) UIImageView *msg_imageView;
@property (nonatomic, copy) NSString *imageURLString;
@property (nonatomic, strong) UIButton *navButton;

@property (nonatomic, strong) UILabel *msgDate_label;

@property (nonatomic, assign) ECELLTAGStatus readStatus;

@property (nonatomic, strong) __block UIProgressView *progressView;

- (void)removeProgressView;

- (void)addProgressView;

 

@end
