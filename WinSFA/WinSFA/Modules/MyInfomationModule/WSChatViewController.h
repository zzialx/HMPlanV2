//
//  ChatViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-2-8.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMsgsBean_msg.h"
#import "MBProgressHUD.h"

@interface WSChatViewController : UIViewController <UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource, UINavigationBarDelegate, UINavigationControllerDelegate>{
    NSMutableArray  *chatArray;
    NSString        *chatFile;

    NSMutableDictionary *currentChatInfo;
    NSMutableString     *currentString;
    BOOL                storingCharacters;

    BOOL    isMySpeaking;
    BOOL    loadingLog;
}

@property (nonatomic, strong) WSMsgsBean_msg      *m_MSG;
@property (nonatomic, strong) NSMutableArray    *m_receivers;
@property (nonatomic, strong) NSMutableArray    *m_selectReceivers;
@property (nonatomic, strong) MBProgressHUD     *m_HUD;

- (id)initWithMSG:(WSMsgsBean_msg *)aMSG;
@end
