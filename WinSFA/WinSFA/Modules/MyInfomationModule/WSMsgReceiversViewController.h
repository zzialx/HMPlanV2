//
//  MsgReceiversViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-21.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMsgReceiversViewController : UITableViewController {}
@property (nonatomic, strong) NSMutableArray        *m_dataSources;
@property (nonatomic, strong) NSMutableDictionary   *m_markDic;
- (id)initWithDatasSources:(NSArray *)aArray;
@end
