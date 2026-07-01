//
//  WSStoreTableViewCell.m
//  WinSFA
//
//  Created by winchannel on 15/7/28.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSBaseTableViewCell.h"

@implementation WSBaseTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        return self;
    }
    
    return nil;
}

- (void)awakeFromNib {

    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    
    [super setSelected:selected animated:animated];
    
    
}


-(void)loadDisplayContent:(NSObject *)dataContent{
    
    content = dataContent;
    
}


-(void)clearDataContent{
    
    
}

@end
