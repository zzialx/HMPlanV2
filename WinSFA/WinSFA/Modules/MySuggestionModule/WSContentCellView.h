//
//  ContentCellView.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSSuggestListBean.h"

@interface WSContentCellView : UITableViewCell {
    IBOutlet UILabel    *m_title;
    IBOutlet UILabel    *m_content;
    IBOutlet UILabel    *m_replyCount;
    IBOutlet UILabel    *m_replyTime;
}

@property (nonatomic, strong) UILabel   *m_title;
@property (nonatomic, strong) UILabel   *m_content;
@property (nonatomic, strong) UILabel   *m_replyCount;
@property (nonatomic, strong) UILabel   *m_replyTime;

@end
