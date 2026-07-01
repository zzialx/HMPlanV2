//
//  WSInputTextField.h
//  WinSFA
//
//  Created by winchannel on 15/3/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidget.h"

@class WSUpKeyBoardView;



@interface WSInputTextField : WSWidget{
    
    UITextView  *textView;
    
    WSUpKeyBoardView  *keyboard;
    
    
}

@end
