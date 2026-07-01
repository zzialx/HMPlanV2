//
//  ReplyPostCardViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-20.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSReplyPostCardViewController : UITableViewController {}
@property (nonatomic, strong) NSMutableDictionary   *m_MarkDictionary;
@property (nonatomic, strong) NSMutableArray        *m_CardArray;
@property (nonatomic, assign) BOOL                  m_isReceiver;
- (id)initWithOptArray:(NSArray *)aArray;
@end
