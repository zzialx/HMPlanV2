//
//  WSSmsController.h
//  TestLua2
//
//  Created by dujinfeng481 on 14-8-21.
//  Copyright (c) 2014年 djf. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    ESmsComposeResultCancelled,
    ESmsComposeResultSent,
    ESmsComposeResultFailed
} ESmsComposeResult;


@protocol WSSmsControllerDelegate;

@interface WSSmsController : NSObject

@property (nonatomic, strong) NSString      *smsContent;        //短信内容
@property (nonatomic , strong) NSArray *phones;

-(id) initWithDelegate:(id<WSSmsControllerDelegate>)delegate
          withParentVC:(UIViewController*)parentVC;

/**
 *  启动SMS界面
 *
 *  @return -1 参数错误， 0 成功掉起sms界面， 1 设备不支持sms功能,  2 canceled
 */
- (int) presentSMSPageWithPhones:(NSArray*)phones withContent:(NSString*)content withIscanned:(BOOL)isCanceled;

@end

@protocol WSSmsControllerDelegate <NSObject>
@optional
-(void) SmsFinishedWithResult:(ESmsComposeResult)result withContent:(NSString*) contentStr;
@end
