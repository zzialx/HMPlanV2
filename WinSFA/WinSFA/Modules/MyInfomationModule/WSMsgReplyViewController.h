//
//  MsgReplyViewController.h
//  WinChannelFrameWork
//
//  Created by Niu Zhaowang on 11/7/12.
//
//

#import "WSAcvtViewController.h"
@class WSMsgsBean_msg;

@interface WSMsgReplyViewController : WSAcvtViewController<UITextViewDelegate>

@property (nonatomic, strong) WSMsgsBean_msg *msg;

@end
