//
//  WSTileListParentTableViewCell.m
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTileListParentTableViewCell.h"



#define K_IMAGEVIEW_HEIGHT 30

#define K_IMAGEVIEW_WIDTH 30

#define K_IMAGEVIEW_RIGHT_SPACE 10


@interface WSTileListParentTableViewCell ()

@property (nonatomic,strong)id<I_W_OptionDataItem> object;

@property (nonatomic,strong) UIImageView *statusImageView;

@end

@implementation WSTileListParentTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // to  do something
        
        _statusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - K_IMAGEVIEW_WIDTH - K_IMAGEVIEW_RIGHT_SPACE, (self.height - K_IMAGEVIEW_HEIGHT)/2, K_IMAGEVIEW_WIDTH, K_IMAGEVIEW_HEIGHT)];
        [self addSubview:_statusImageView];
    }
    return self;
}

- (void)setObject:(id <I_W_OptionDataItem> )object {
    _object = object;
    /* to  do  something*/
    self.textLabel.text =  [object getDataItemName];
    if ([object getSelectedStatus]) {
        [_statusImageView setImage:[UIImage imageForName:@"selected"]];
    }else {
        [_statusImageView setImage:[UIImage imageForName:@"unselected"]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
