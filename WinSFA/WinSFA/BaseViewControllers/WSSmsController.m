//
//  WSSmsController.m
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-21.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import "WSSmsController.h"
#import <MessageUI/MessageUI.h>
#import "WSFuncsBean.h"
#import "WSStoreBean.h"
#import "WSAcvtBean.h"

#define LUA_SCRIPT_KEY      @"luaScript:"

@interface WSSmsController() <MFMessageComposeViewControllerDelegate>
{
    id<WSSmsControllerDelegate>     curDelegate;
    UIViewController                *parentViewController;
}

@end

@implementation WSSmsController



-(id) initWithDelegate:(id<WSSmsControllerDelegate>)delegate
          withParentVC:(UIViewController*)parentVC
{
    self = [super init];
    if (self) {
        curDelegate = delegate;
        parentViewController = parentVC;
    }
    return self;
}


- (int) presentSMSPageWithPhones:(NSArray*)phones withContent:(NSString*)content withIscanned:(BOOL)isCanceled
{
    LogInfo(@"phones:%@, content:%@, isCanceled:%d", phones, content, isCanceled);
    self.smsContent = content;
    if (!parentViewController) {
        LogInfo(@"parentViewC ontroller is empty");
        return -1;
    }
    
    if (isCanceled) {
        LogInfo(@"self.luaScriptParserObj.isCanceled YES. %@", self.smsContent);
        return 2;
    }
    
#if TARGET_IPHONE_SIMULATOR
    return 0;
#else
    if([MFMessageComposeViewController canSendText]){
        [self displaySMSComposeWithPhones:phones
                              withContent:content
                       withViewController:parentViewController];
        return 0;
    }else{
        NSString *title = NSLocalizedString(@"Device not configured to send SMS", nil);
        [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:title tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
        return 1;
    }
#endif
}

#pragma mark - private method
-(void) displaySMSComposeWithPhones:(NSArray*)phones withContent:(NSString*)content withViewController:(UIViewController*) parentVC
{
    MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
    picker.messageComposeDelegate = self;
    picker.recipients = phones;
    picker.body = content;
    [parentVC presentViewController:picker
                           animated:YES
                         completion:NULL];
}

#pragma mark - MFMessageComposeViewControllerDelegate
-(void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result{
    // Notifies users about errors associated with the interface
    
    ESmsComposeResult eResult;
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Result: SMS sending canceled");
            eResult=ESmsComposeResultCancelled;
            break;
        case MessageComposeResultSent:
            NSLog(@"Result: SMS sent");
            eResult=ESmsComposeResultSent;

            break;
        case MessageComposeResultFailed:
            eResult=ESmsComposeResultFailed;

            NSLog(@"Result: SMS sending failed");
            break;
        default:
            NSLog(@"Result: SMS not sent");
            break;
    }
    
    if (curDelegate && [curDelegate respondsToSelector:@selector(SmsFinishedWithResult:withContent:)]) {
        self.phones = controller.recipients;
        [curDelegate SmsFinishedWithResult:eResult withContent:self.smsContent];
    }
    
    [controller dismissViewControllerAnimated:YES completion:NULL];
}


@end
