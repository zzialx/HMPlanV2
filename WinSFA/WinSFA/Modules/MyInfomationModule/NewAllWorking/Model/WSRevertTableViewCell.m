//
//  RevertTableViewCell.m
//  demo
//
//  Created by admin on 15/10/26.
//  Copyright © 2015年 zhiqingPC. All rights reserved.
//

#import "WSRevertTableViewCell.h"
#import "RevertArrayModel.h"
#import "NSString+Additions.h"

@interface WSRevertTableViewCell ()


@end

@implementation WSRevertTableViewCell

+(instancetype)cellWithTableView:(UITableView *)tableView{
    static NSString * ID = @"ID";
    
    WSRevertTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        cell = [[WSRevertTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    
    return cell;

}
 // 原来数据模型的set方法
-(void)setModel:(RevertArrayModel *)model{
    _model = model;
    self.userName.text =  self.model.userName;
    
    NSMutableParagraphStyle *paraStyle = [[NSMutableParagraphStyle alloc] init];
    paraStyle.lineBreakMode = NSLineBreakByCharWrapping;
    paraStyle.alignment = NSTextAlignmentJustified;
    paraStyle.lineSpacing = 5; //设置行间距
    
    //设置字间距 NSKernAttributeName:@1.5f
    NSDictionary *dic = @{NSFontAttributeName:[UIFont systemFontOfSize:UI_Font], NSParagraphStyleAttributeName:paraStyle,
                          };
    
    NSAttributedString *attributeStr = [[NSAttributedString alloc] initWithString:self.model.revertMsg attributes:dic];
    self.detalLabel.attributedText = attributeStr;
//    self.detalLabel.text = self.model.revertMsg;
    // NSString *timeStr = [self.model.reply_time substringToIndex:16];
    
    self.timeLable.text = self.model.reply_time;
//    self.timeLable.text = self.model.timeMsg;

}

-(void)setFunsModel:(WSFuncsBean *)funsModel{
    _funsModel = funsModel;
    _userName.text = self.funsModel.name;
    _detalLabel.text = self.funsModel.name;
    _timeLable.text = @"2015-08-20";


}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        UILabel * userName = [UILabel new];
        [self.contentView addSubview:userName];
        userName.textColor = MAIN_TEXT_COLOR;
        userName.textAlignment = NSTextAlignmentLeft;

        self.userName = userName;
        self.userName.font = [UIFont systemFontOfSize:UI_Font];
        
        UILabel * timeLable = [UILabel new];
        [self.contentView addSubview:timeLable];
        timeLable.textColor = LIGHT_TEXT_COLOR;
        timeLable.textAlignment = NSTextAlignmentRight;
        self.timeLable = timeLable;
        self.timeLable.font = [UIFont systemFontOfSize:UI_Font - 2];
        
        UILabel * detalLabel = [UILabel new];
        detalLabel.font = [UIFont systemFontOfSize:UI_Font];
        detalLabel.textColor = DETAIL_TEXT_COLOR;
        [self.contentView addSubview:detalLabel];
        detalLabel.numberOfLines = 0;
        detalLabel.textAlignment = NSTextAlignmentLeft;

        self.detalLabel = detalLabel;
    }

    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat timeWidth = 150;
    self.userName.frame = CGRectMake(MAIN_CELL_PADDING, MAIN_CELL_PADDING, self.width - 2 * MAIN_CELL_PADDING -  timeWidth, kTitleHeight);
    self.timeLable.frame = CGRectMake(self.userName.right, MAIN_CELL_PADDING, timeWidth, kTitleHeight);
    self.detalLabel.frame = CGRectMake(MAIN_CELL_PADDING, CGRectGetMaxY(self.userName.frame) +MAIN_CELL_PADDING * 0.5, self.width - 2 * MAIN_CELL_PADDING, self.height - kTitleHeight - MAIN_CELL_PADDING * 0.5 - 2 * MAIN_CELL_PADDING);
}

@end
