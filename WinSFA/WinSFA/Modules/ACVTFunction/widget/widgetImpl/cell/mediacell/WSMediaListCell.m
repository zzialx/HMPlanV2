//
//  WSMediaPanel.m
//  WinSFA
//
//  Created by winchannel on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMediaListCell.h"

#import "I_Media_Info.h"
#import "WSConstant.h"
#import "I_W_Cell.h"


@implementation WSMediaListCell

@synthesize media_content_view;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.frame = WSRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 60);
        
//        media_content_view =[[WSMediaContentView alloc] initWithFrame:WSRect(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
//        
//        
//        [self addSubview:media_content_view];

    
        return self;
    }
    
    return nil;
}

-(void)clearDisplayContent{
    
   
}

-(void)loadDisplayContent:(NSObject<I_W_Cell> *)contentobject{
    
    NSArray *contentarray = [contentobject getCellContentArray];
   

    
    
}

-(UIView *)getContentView{
    
    return media_content_view;
    
}

@end
