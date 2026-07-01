//
//  WSMessageObject.h
//  WinSFA
//
//  Created by winchannel on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_M_Display.h"



@interface WSMessageObject : NSObject<I_M_Display>{
    
    NSString   *messageId;
    NSString   *displayTitle;
    NSString   *displayMessage;
    NSMutableArray  *buttons;
    UIImage   *productIcon;
    NSInteger   messageType;
    __weak id  messageDelegate;
}

@property  (nonatomic,retain)    NSString   *messageId;
@property  (nonatomic,retain)    NSString   *displayTitle;
@property  (nonatomic,retain)    NSString   *displayMessage;
@property  (nonatomic,retain)    NSMutableArray  *buttons;
@property  (nonatomic,retain)    UIImage   *productIcon;
@property  (nonatomic,assign)    NSInteger   messageType;
@property  (nonatomic,weak) id  messageDelegate;

@end
