//
//  WSMediaPanel.h
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"
#import "I_Media.h"

@protocol  I_Media_Info;

@protocol I_Media_OperationDelegate;

@protocol IAttachment;

@interface WSMediaPanel : WSWidget<I_Media>{
    
    NSObject<IAttachment>  *media_info;
    
    __unsafe_unretained id<I_Media_OperationDelegate>  mediaOperationDelegate;
    
}

@property (nonatomic,strong) NSObject<IAttachment>  *media_Info;

@property (nonatomic,assign) id<I_Media_OperationDelegate>  mediaOperationDelegate;

@property (nonatomic,strong) UIViewController *parentViewController;



@end
