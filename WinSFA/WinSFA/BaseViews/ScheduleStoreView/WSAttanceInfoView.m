//
//  WSAttanceInfoTableViewCell.m
//  WinSFA
//
//  Created by admin on 2022/10/20.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WSAttanceInfoView.h"

@interface WSAttanceInfoView ()

@property (weak, nonatomic) IBOutlet UILabel *forenoonLab;

@property (weak, nonatomic) IBOutlet UILabel *afternoonLab;

@property (weak, nonatomic) IBOutlet UILabel *approveStateLab;

@end

@implementation WSAttanceInfoView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.forenoonLab.font = FONT(13.0);
    self.forenoonLab.textColor = HColorFromHex(0x000000);
    
    self.afternoonLab.font = FONT(13.0);
    self.afternoonLab.textColor = HColorFromHex(0x000000);
    
    self.approveStateLab.font = FONT(13.0);
    self.approveStateLab.textColor = MAIN_TINT_COLOR;
    
    self.forenoonLab.text = @"上午：";
    self.afternoonLab.text = @"下午：";
    self.approveStateLab.text = @"";
}

- (void)setAttenanceModel:(WSAttenanceModel *)attenanceModel{
    _attenanceModel = attenanceModel;
    if(_attenanceModel==nil){
        self.forenoonLab.hidden= YES;
        self.afternoonLab.hidden = YES;
        self.approveStateLab.hidden = YES;
        return;
    }
    self.forenoonLab.hidden= NO;
    self.afternoonLab.hidden = NO;
    self.approveStateLab.hidden = NO;
    self.forenoonLab.text = _attenanceModel.forenoon==nil?@"上午：无":[NSString stringWithFormat:@"上午：%@",_attenanceModel.forenoon];
    self.afternoonLab.text = _attenanceModel.afternoon==nil?@"下午：无":[NSString stringWithFormat:@"下午：%@",_attenanceModel.afternoon];
    self.approveStateLab.text = _attenanceModel.approveName==nil?@"":_attenanceModel.approveName;
        
}

@end
