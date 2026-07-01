//
//  WCContactInviteWithHeadPicCell.m
//  NewSolution
//
//  Created by 李振杰 on 14-9-5.
//  Copyright (c) 2014年 com.winchannel. All rights reserved.
//

#import "WSContactInviteWithHeadPicCell.h"
#import "WSOpenCloseBtn.h"

#import <QuartzCore/QuartzCore.h>

#import "I_W_ContactDisplay.h"

#import "WidgetConstant.h"

@implementation WSContactInviteWithHeadPicCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        headpic =[[UIImageView alloc] initWithFrame:WSRect(18.0/2.0, 18.0/2.0, 94.0/2.0, 94.0/2.0)];
   
        headpic.image =  WSImg(@"headimg.png");
        
        headpic.layer.cornerRadius = 94.0/2.0/2.0;
        
        headpic.layer.borderColor =[[UIColor lightGrayColor] CGColor];
        
        headpic.layer.borderWidth =1.0;
        
        headpic.layer.masksToBounds=YES;
        
        [self addSubview:headpic];
        
        contacname.frame =WSRect(headpic.frame.origin.x+headpic.frame.size.width+10.0, 15.0,  contacname.frame.size.width, contacname.frame.size.height);
        
        invitebutton.frame =WSRect(541.0/2.0-10.0, 27.0/2.0, invitebutton.frame.size.width, invitebutton.frame.size.height);
        
        
    }

    return self;
}

-(void)updateCell:(NSObject<I_W_ContactDisplay> *)contactx{
    
    [super updateCell:contactx];
    
    if ([contact getContactImageData]!=nil) {
        
        headpic.image =[UIImage imageWithData:[contact getContactImageData]];
        
        
    }
    self.frame =WSRect(0.0, 0.0, self.frame.size.width, 120.0/2.0);
    
    
}
-(void)clearContent{
    
    [super clearContent];
    
    headpic.image = nil;
    
    headpic.image =  WSImg(@"headimg.png");
    
}
@end
