//
//  MsgContentController.h
//  WinChannelIPhone
//
//  Created by winchannel on 11-10-21.
//  Copyright 2011年 Winchannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMsgsBean_msg.h"

@interface WSMsgContentController : UIViewController <NSURLConnectionDataDelegate>
{}
@property (nonatomic, strong) IBOutlet UITextView       *textviewContent;
@property (nonatomic, strong) NSString                  *contentString;
@property (nonatomic, strong) WSMsgsBean_msg              *m_Msg;
@property (nonatomic, strong) IBOutlet UIImageView      *prodImageView;
@property (nonatomic, strong) NSMutableData             *imageData;
@property (nonatomic, strong) UIAlertView               *alert;
@property (nonatomic, strong) UIActivityIndicatorView   *activity;
- (id)initWithNibName:(NSString *)nibNameOrNil MSG:(WSMsgsBean_msg *)aMsg;
- (void)getPic;
@end
