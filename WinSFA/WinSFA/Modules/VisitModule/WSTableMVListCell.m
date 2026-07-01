//
//  WSTableMVListCell.m
//  WinSFA
//
//  Created by winchannel on 16/4/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTableMVListCell.h"
#import "WSServerIPList.h"
#import "WSServerIPController.h"
#import "SDWebImageManager.h"
#import "WSRequestHelper.h"

@implementation WSTableMVListCell


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        
        self.leftImageView = [[UIImageView alloc]init];
        self.mainTitle = [[UILabel alloc]init];
        
        [self.contentView addSubview:self.leftImageView];
        [self.contentView addSubview:self.mainTitle];
        
    }
    return self;
}
- (void)layoutSubviews{
    
    [super layoutSubviews];
    
   
}

- (void)setFuncsBean:(WSFuncsBean *)funcsBean{
    
    _funcsBean = funcsBean;
    
    NSString *stringURL = [self getFucsBeanIconURL:funcsBean];
    
    
    [[WSRequestHelper shareInstance]  downloadImageWithUrl:stringURL imageView:_leftImageView];
    _leftImageView.frame = CGRectMake(5, (self.bounds.size.height - 30.5) /2.0, 40, 30.5);
    
   
    
    self.mainTitle.frame = CGRectMake(50, (self.bounds.size.height - 30) /2.0, self.bounds.size.width - 50, 30);
    self.mainTitle.text = funcsBean.name;
    
    
}

- (NSString *)getFucsBeanIconURL:(WSFuncsBean *)aFuncsBean{
    
    if (aFuncsBean.icon && aFuncsBean.icon.length >0) {
        
        WSServerIPList *svip =  [WSAppData getObjectbyKey:SERVERURL];
        
        WSServerIPController *serverIP =[svip.serverIPArray firstObject];
        
        NSString *stringURL = nil;
        
        stringURL = [NSString stringWithFormat:@"%@%@",[serverIP ServerIPString],aFuncsBean.icon];
        
        stringURL = [stringURL stringByReplacingOccurrencesOfString:@"\\" withString:@""];//字符转换
        
        return stringURL;
    }
    
    return nil;

}
@end
