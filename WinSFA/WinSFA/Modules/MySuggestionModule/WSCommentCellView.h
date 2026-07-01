//
//  CommentCellView.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSCommentCellView : UITableViewCell
{}
@property (nonatomic, strong) IBOutlet UILabel  *m_person;
@property (nonatomic, strong) IBOutlet UILabel  *m_content;
@property (nonatomic, strong) IBOutlet UILabel  *m_time;

@end
