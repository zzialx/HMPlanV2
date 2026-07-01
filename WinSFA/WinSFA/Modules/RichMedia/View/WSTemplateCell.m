//
//  WSTemplateCell.m
//  WinSFA
//
//  Created by huzepei on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTemplateCell.h"

@interface WSTemplateCell()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

- (IBAction)templateBtnClick:(id)sender;


@end

@implementation WSTemplateCell


-(void)setTitle:(NSString *)title
{
    _title = title;
    _nameLabel.text = _title;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (IBAction)templateBtnClick:(id)sender {
    
    if (_clickPlusBtn) {
        _clickPlusBtn(_cellIndexPath);
    }
}
@end
