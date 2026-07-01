//
//  WSiConImage.m
//  WinSFA
//
//  Created by winchannel on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSiConImage.h"

@implementation WSiConImage

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        imageView =[[UIImageView alloc] initWithFrame:self.bounds];
        
        [self addSubview:imageView];
        
        return self;
    }
    return nil;
}

-(void)setIconImage:(UIImage *)image{
    
    imageView.image = image;
    
}

@end
