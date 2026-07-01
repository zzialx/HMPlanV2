//
//  WSOpenCloseBtn.m
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSOpenCloseBtn.h"

@implementation WSOpenCloseBtn


@synthesize heightlightimg;
@synthesize normalimg;

- (id)initWithFrame:(CGRect)frame  normalimg:(UIImage *)nimg hightlightimg:(UIImage *)himg
{
    self = [super initWithFrame:frame];
    if (self) {
        
        normalimg= nimg;
        
        heightlightimg =himg;
        
        openclosebtn =[[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, nimg.size.width, nimg.size.height)];
        
        [openclosebtn setUserInteractionEnabled:YES];
        
        [openclosebtn setImage:normalimg];
        
        [self addSubview:openclosebtn];
        
        isopen =NO;
        
        
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (touchable==NO) {
        
        return;
    }
    
    if (isopen==NO) {
        
        [openclosebtn setImage:heightlightimg];
        
        isopen =YES;
    }else{
        
        [openclosebtn setImage:normalimg];
        isopen =NO;
    }
    
    
    if ([delegate respondsToSelector:@selector(forOperation:)]) {
        
        [delegate forOperation:isopen];
    }
    
    
    
}


-(void)setIsOpen:(BOOL)isok{
    isopen = isok;
    
    if (isopen==NO) {
        
        [openclosebtn setImage:heightlightimg];
        
        isopen =YES;
    }else{
        
        [openclosebtn setImage:normalimg];
        isopen =NO;
    }
    
    
    
}

-(void)setTouchable:(BOOL)istouchable{
    
    
    touchable = istouchable;
}
@end
