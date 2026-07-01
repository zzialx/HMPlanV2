//
//  WSScheduleStoreTableViewCell.m
//  WinSFA
//
//  Created by admin on 2022/10/20.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSScheduleStoreTableViewCell.h"

@interface WSScheduleStoreTableViewCell ()

@property (weak, nonatomic) IBOutlet UILabel *storeCodeLab;
@property (weak, nonatomic) IBOutlet UILabel *storeNameLab;
@property (weak, nonatomic) IBOutlet UILabel *storeLevelLab;

@end

@implementation WSScheduleStoreTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.storeCodeLab.textColor = HColorFromHex(0x343434);
    self.storeNameLab.textColor = HColorFromHex(0x343434);
    self.storeLevelLab.textColor = HColorFromHex(0x343434);
    self.storeCodeLab.text = @"";
    self.storeLevelLab.text = @"";
    self.storeNameLab.text = @"";
}
- (void)setStoreModel:(WSPlanStoreModel *)storeModel{
    _storeModel = storeModel;
    if(_storeModel==nil)return;
    self.storeCodeLab.text = ISNULL(_storeModel.storeCode);
    self.storeNameLab.text = ISNULL(_storeModel.storeName);
    self.storeLevelLab.text = ISNULL(_storeModel.storeLevel);

}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
