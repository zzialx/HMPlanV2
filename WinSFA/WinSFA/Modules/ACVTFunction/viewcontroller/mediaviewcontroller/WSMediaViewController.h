//
//  WSMediaViewController.h
//  WinSFA
//
//  Created by winchannel on 15/4/13.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WCBaseViewController.h"
#import "I_Media.h"
#import "I_Media_Info.h"


@interface WSMediaViewController : WCBaseViewController<I_Media_OperationDelegate>{
    
    NSObject<I_Media> *mediaview;
    
    NSMutableDictionary  *mediaconfig;
    
    NSObject<IAttachment> * currentMediaInfo;
}

@property (nonatomic,retain) NSObject<IAttachment> * currentMediaInfo;

@property (nonatomic,assign) BOOL isHidden;


@end
