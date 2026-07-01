//
//  WSContactCell.m
//  WinSFA
//
//  Created by winchannel on 15/3/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSContactCell.h"
#import "I_W_ContactDisplay.h"



@implementation WSContactCell

@synthesize contacname;
@synthesize white;
@synthesize gray;
@synthesize contact;
@synthesize keys;

@synthesize delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        white = [[UIImageView alloc] initWithFrame:CGRectMake(0, 40.5, self.frame.size.width, 1)];
        white.backgroundColor = [UIColor colorWithHexString:@"#f0f0f0"];
        gray = [[UIImageView alloc] initWithFrame:CGRectMake(0, 41.5, self.frame.size.width, 1)];
        gray.backgroundColor = [UIColor colorWithHexString:@"#d0d0d0"];
        contacname = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, self.frame.size.width, 20)];
        contacname.backgroundColor = [UIColor clearColor];
        contacname.textColor = [UIColor colorWithHexString:@"#646464"];
        contacname.textAlignment = NSTextAlignmentLeft;
        contacname.font = [UIFont systemFontOfSize:14.0f];
        [self addSubview:contacname];
        
    }
    return self;
}




- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    
    [super setSelected:selected animated:animated];
    
    
}

-(void)clearContent{
    
    contacname.text=@"";
}

-(void)setNoSelectedForSuccessInvited{
    
    
}

- (void)updateCell:(NSObject<I_W_ContactDisplay> *)contactx
{
    
    contact = contactx;
    
    contacname.text = [contact getContactName];
    
    
}

- (void)updateCellStatus:(BOOL)isuse {
    
}

@end
