//
//  WSTextView.h
//  WinSFA
//
//  Created by zhangke on 14-5-6.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSHTextField.h"

@interface WSTextView : UITextView{
    
    BOOL isloaded;
}

@property (nonatomic,strong) WSHTextField* hTextField;



@end
