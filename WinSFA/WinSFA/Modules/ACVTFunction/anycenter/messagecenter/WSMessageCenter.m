//
//  WSMessageCenter.m
//  WinSFA
//
//  Created by winchannel on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMessageCenter.h"
#import "I_M_View.h"

@implementation WSMessageCenter

static WSMessageCenter  *messagecenter;
+(id)shareInstance{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        messagecenter =[[WSMessageCenter alloc] init];
    });
    return messagecenter;
}


-(id)init{
    
    self = [super init];
    if (self) {
        
        [self initMessageViewInformation];
    
        return self;
    }
    return nil;
}


-(void)initMessageViewInformation{
    
 
    
    NSString  *filepath =[[NSBundle mainBundle] pathForResource:@"messageType" ofType:@"plist"];
    
    messageMappingDict =[[NSMutableDictionary alloc] initWithContentsOfFile:filepath];
 
}

-(void)showMessageView:(NSObject<I_M_Display> *)messageForDisplay{
    
    NSInteger   messageType = [messageForDisplay getMessageType];
    
    NSString  *messageTypeStr =[NSString stringWithFormat:@"%ld",(long)messageType];
    
    NSString  *messageViewClassName = [messageMappingDict valueForKey:messageTypeStr];
    
    currentMessageView =[[NSClassFromString(messageViewClassName) alloc] init];
    
    [currentMessageView showCurrentMessageView:messageForDisplay];
    
}

-(void)closeMessageView{
    
    [currentMessageView hiddenMessageView];
    
}


@end
