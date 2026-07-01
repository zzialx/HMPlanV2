//
//  WSMessageViewButton.h
//  WinSFA
//
//  Created by winchannel on 15/3/31.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BlockAlertView.h"
#import "I_M_ViewDelegate.h"




@interface WSMessageViewWithButtons : NSObject<I_OP_BlockAlertViewDelegate>{
    
    __weak id<I_M_ViewDelegate>  opdelegate;
    
    BlockAlertView   *blockview;
    
    
}

@property (nonatomic,weak) id<I_M_ViewDelegate>  opdelegate;


@end
