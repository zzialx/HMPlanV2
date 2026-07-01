//
//  WSMessageCenter.h
//  WinSFA
//
//  Created by winchannel on 15/3/30.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "I_M_Display.h"

@protocol I_M_View;


typedef enum {
    
    MESSAGE_TYPE_OK,
    
    MESSAGE_TYPE_CANCEL_OK,
    
    MESSAGE_TYPE_CANCEL,
    
    MESSAGE_TYPE_WAIT,
    
    MESSAGE_TYPE_WAIT_WITH_PROGRESS,
    
    MESSAGE_TYPE_AUTO_HIDE_DONE,
    
    MESSAGE_TYPE_AUTO_HIDE_FAILED,
    
    
}SHOW_MESSAGE_TYPE;




@interface WSMessageCenter : NSObject{
    
    NSMutableDictionary   *messageMappingDict;
    
    NSObject<I_M_View>  *currentMessageView;
    
}

+(id)shareInstance;


-(void)showMessageView:(NSObject<I_M_Display> *)messageForDisplay;

-(void)closeMessageView;

@end
