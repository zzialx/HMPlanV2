//
//  WSAcvtTempView.m
//  WinSFA
//
//  Created by winchannel on 15/4/22.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSAcvtTempView.h"
#import "WSConstant.h"
#import "WSANTableView.h"
#import "WSWidget.h"


@implementation WSAcvtTempView
@synthesize iSneedlayout;
@synthesize risehight;
@synthesize resizeview;
@synthesize isrise;

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        iSneedlayout=NO;
        
        risehight=0;
        
        isrise=NO;
        
        return self;
    }
    return nil;

}

-(void)layoutSubviews{
    
    if (iSneedlayout) {
        
        for (int i=0; i<[[self subviews] count]; i++) {
            
            UIView *subview = [[self subviews] objectAtIndex:i];
            
            if (![subview isKindOfClass:[WSANTableView class]]) {
                
                if (![resizeview isEqual:subview] && [subview frame].origin.y > [resizeview frame].origin.y) {
                
                    if (isrise) {

                        
                        subview.frame = WSRect(subview.frame.origin.x, subview.frame.origin.y+risehight, subview.frame.size.width, subview.frame.size.height);
                        
              
                        if ([subview respondsToSelector:@selector(resetFrame:)] ) {
                            
                            [(WSWidget *)subview  resetFrame:subview.frame];
                            
                        }
                    }else{
                        
                        subview.frame = WSRect(subview.frame.origin.x, subview.frame.origin.y-risehight, subview.frame.size.width, subview.frame.size.height);

                    }
                    
                }
               
            }
        }
        
        if (self.superview) {
            
            if (risehight>0) {
            
                [(UIScrollView *)self.superview setContentSize:CGSizeMake(((UIScrollView *)self.superview).contentSize.width, ((UIScrollView *)self.superview).contentSize.height+risehight)];
                
          }
        }

    }
    iSneedlayout =NO;
}
@end
