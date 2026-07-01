//
//  WSiConImageWithProgressAndStatusIcon.m
//  WinSFA
//
//  Created by winchannel on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSiConImageWithProgressAndStatusIcon.h"
#import "WSConstant.h"

@implementation WSiConImageWithProgressAndStatusIcon

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        statusIcon= [[UIImageView alloc] initWithFrame:WSRect(self.frame.size.height-(28.0/2.0), self.frame.size.height-(28.0/2.0), 28.0/2.0, 28.0/2.0) ];
        
        [statusIcon setImage:[UIImage imageForName:@"icon_finish"]];
        
        [statusIcon setHidden:YES];
        
        [self addSubview:statusIcon];
        
        
        
    }

    return self;
}

-(void)setIconImage:(UIImage *)image{
    
    [super setIconImage:image];
    
}

-(void)setCurrentProgress:(float)myprogress{
    
    [super setCurrentProgress:myprogress];
    
    
}


-(void)setStatsIconHidden:(BOOL)isHidden{
    
    [statusIcon setHidden:isHidden];
    
}
@end
