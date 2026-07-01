//
//  WSPeopleListCell.m
//  WinSFA
//
//  Created by zhangke on 15/4/23.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSPeopleListCell.h"
#import "I_Media_Info.h"
#import "WSConstant.h"
#import "WSPeopleContentView.h"

@implementation WSPeopleListCell

@synthesize people_content_view;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.frame = WSRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, 60);
        
        people_content_view =[[WSPeopleContentView alloc] initWithFrame:WSRect(0.0, 0.0, self.frame.size.width, self.frame.size.height)];
        
        
        [self.contentView addSubview:people_content_view];
        
        
        
        return self;
    }
    
    return nil;
}

-(void)clearDisplayContent{
    
    [self.contentView removeAllSubviews];
    
    [people_content_view removeAllSubviews];
    
}

-(void)loadDisplayContent:(NSObject *)contentobject{
    
    [people_content_view loadMediaInfo:(NSObject *)contentobject];
    
}

-(UIView *)getContentView{
    
    return people_content_view;
    
}
-(void)showActionButton
{
    people_content_view.actionButton.hidden=NO;
}


@end
