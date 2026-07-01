//
//  SendSuggestionViewController.h
//  Suggestion
//
//  Created by winchannel on 12-2-18.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"
#import "MBProgressHUD.h"
#import "WSSugReplyBeanArray.h"
#import "SuperWorkSpaceViewController.h"

@interface WSSendSuggestionViewController : SuperWorkSpaceViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>{}

@property (nonatomic, strong) UITableView       *m_tableView;
@property (nonatomic, strong) NSMutableArray    *m_TextFields;
@property (nonatomic, strong) NSArray           *m_receivers;
@property (nonatomic, strong) MBProgressHUD     *m_HUD;
@property (nonatomic, strong) NSArray           *m_titles;
@property (nonatomic, strong) WSSugReplyBeanArray *m_sugReplyBeanArray;
@property (nonatomic, strong) NSString          *m_currentMsgId;

- (id)initWithFuncs:(WSFuncsBean *)funcs Titles:(NSArray *)aTitles;
- (id)initWithTitles:(NSArray *)aTitles;

@end
