//
//  WSScheduleHeadView.m
//  WinSFA
//
//  Created by admin on 2022/10/20.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSScheduleHeadView.h"

@interface WSScheduleHeadView ()

@property (weak, nonatomic) IBOutlet UILabel *nameLab;
@property (weak, nonatomic) IBOutlet UILabel *storeCodeLab;
@property (weak, nonatomic) IBOutlet UILabel *storeLevelLab;

@end

@implementation WSScheduleHeadView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}
- (void)awakeFromNib{
    [super awakeFromNib];
    self.storeCodeLab.textColor = HColorFromHex(0x343434);
    self.nameLab.textColor = HColorFromHex(0x343434);
    self.storeLevelLab.textColor = HColorFromHex(0x343434);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
