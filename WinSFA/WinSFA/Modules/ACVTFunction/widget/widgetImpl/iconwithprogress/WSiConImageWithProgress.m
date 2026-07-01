//
//  WSiConImageWithProgress.m
//  WinSFA
//
//  Created by winchannel on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSiConImageWithProgress.h"
#import "WSConstant.h"

@implementation WSiConImageWithProgress

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        progress =[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        
        progress.frame = WSRect(0.0, self.frame.size.width/2.0-(20.0/2.0/2.0), self.frame.size.width,20.0/2.0);
        
        [self addSubview:progress];
        
        return self;
    }
    return nil;
}

-(void)setIconImage:(UIImage *)image{
    
    [super setIconImage:image];
    
}

-(void)setCurrentProgress:(float)myprogress{
   
    [progress setProgress:myprogress animated:YES];
    if (myprogress==1.0) {
        
        [progress setHidden:YES];
        
    }
}

@end
