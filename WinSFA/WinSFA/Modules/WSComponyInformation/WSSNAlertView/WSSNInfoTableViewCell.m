//
//  WSSNInfoTableViewCell.m
//  HookExampleApp
//
//  Created by admin on 2023/2/15.
//

#import "WSSNInfoTableViewCell.h"

@implementation WSSNInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setModel:(WSMsgsBean_msg *)model{
    
    _model = model;
//    self.infoNameLab.text = [NSString stringWithFormat:@"【%@】",ISNULL(_model.msgType)];
    self.infoNameLab.text = @"";
    self.infoContentLab.text = ISNULL(_model.title);
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
