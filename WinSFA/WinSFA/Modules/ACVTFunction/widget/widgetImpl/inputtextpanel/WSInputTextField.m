//
//  WSInputTextField.m
//  WinSFA
//
//  Created by winchannel on 15/3/26.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSInputTextField.h"
#import "WidgetConstant.h"
#import <QuartzCore/QuartzCore.h>

@implementation WSInputTextField

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self buildDisplayContent];
        
        return self;
    }
    return nil;
    
}

-(void)buildDisplayContent{
    
    [super buildDisplayContent];
    
    textView =[[UITextView alloc] initWithFrame:WSRect(0.0, 0.0, self.frame.size.width, self.frame.size.width)];
    
    textView.layer.cornerRadius =10.0;
    
    textView.layer.borderWidth =1.0;
    
    textView.layer.borderColor = [[UIColor blackColor] CGColor];

    [self addSubview:textView];
    
}


@end
