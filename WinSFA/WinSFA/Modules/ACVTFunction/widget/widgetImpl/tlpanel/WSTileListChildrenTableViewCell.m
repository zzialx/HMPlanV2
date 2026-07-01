//
//  WSTileListChildrenTableViewCell.m
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSTileListChildrenTableViewCell.h"


#define K_CELL_BUTTON_RIGHT_SPACE 10


#define K_CELL_BUTTON_WIDTH 60


#define K_CELL_BUTTON_HEIGHT 30


#define K_NAME_LABEL_WIDTH 150




@interface WSTileListChildrenTableViewCell ()

@property (nonatomic,strong) WSOrgBean<I_W_OptionDataItem,I_W_Children_DataSource> *object;

@property (nonatomic,strong) UILabel *nameLabel;

@property (nonatomic,strong) UIButton *flagButton;


@end

@implementation WSTileListChildrenTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // to  do something
        
        CGFloat left_space = 5.0f;
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left_space, 0, K_NAME_LABEL_WIDTH, self.height)];
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.font = [UIFont systemFontOfSize:UI_Font - 2];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.textColor = [UIColor grayColor];
        _nameLabel.numberOfLines = 0;
        _nameLabel.lineBreakMode = NSLineBreakByCharWrapping;
        [self addSubview:_nameLabel];
        
        
        _flagButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.flagButton addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.flagButton setFrame:CGRectMake(235 - K_CELL_BUTTON_WIDTH, 5  , K_CELL_BUTTON_WIDTH, K_CELL_BUTTON_HEIGHT)];
        [self.flagButton setImage:[UIImage imageForName:@"tile_selected_no_radio"] forState:UIControlStateNormal];
        
        [self.flagButton setTitle:NSLocalizedString(@"", nil) forState:UIControlStateNormal];
        [self addSubview:self.flagButton];
    }
    return self;
}



- (void)buttonClick:(UIButton *)button {
    
    BOOL status = [self.object getSelectedStatus];
    
    [self.object setStatus:!status];
    
    if (self.object.status) {
        [button setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"]forState:UIControlStateNormal];
    }else {
        [button setImage:[UIImage scaledImageForName:@"selected_no_radio" ofType:@"png"] forState:UIControlStateNormal];
    }
    
    if ([_cellDelegate respondsToSelector:@selector(tableViewCell:didSelectOrgBean:tag:)]) {
        [_cellDelegate tableViewCell:self didSelectOrgBean:self.object tag:self.tableViewTag];
    }
}


- (void)setObject:(WSOrgBean<I_W_OptionDataItem,I_W_Children_DataSource> *)object {
    
    _object = object;
    
    NSString *orgName = [object getDataItemName];

    NSInteger allLevelsChildren = [self getAlllevelsOrg];
    
    NSInteger  selectedChildrenInt = [object.selectedChildren count];
    
    if (allLevelsChildren > 0) {
        NSString *textStr = [NSString stringWithFormat:@" %@(%ld/%ld)",orgName,(long)selectedChildrenInt,(long)allLevelsChildren];
        NSRange range1 = [textStr rangeOfString:@"("];
        NSRange range2 = [textStr rangeOfString:@")"];
    
        NSMutableAttributedString *attributedStr = [self text:textStr addSpecialColor: MAIN_TINT_COLOT inRange:NSMakeRange(range1.location, range2.location - range1.location  + 1)];
        self.nameLabel.attributedText = attributedStr;
        
    }else {
        self.nameLabel.text = orgName;
    }
    if (object.status) {
        [self.flagButton setImage:[UIImage scaledImageForName:@"selected_yes_radio" ofType:@"png"] forState:UIControlStateNormal];
    }else {
        
        [self.flagButton setImage:[UIImage scaledImageForName:@"selected_no_radio" ofType:@"png"] forState:UIControlStateNormal];
    }
    
}

- (NSInteger )getAlllevelsOrg {
    
    self.allLevelsChildren = 0;
    
    [self computeSublevelsOrgWith:self.object];
    
    return self.allLevelsChildren;
}



- (void)computeSublevelsOrgWith:(WSOrgBean *)org {
    
    if ([org.childen count] > 0) {
        
        self.allLevelsChildren += [org.childen count];
        
        for (WSOrgBean *subOrg in org.childen ) {
            
            if ([subOrg.childen count] > 0) {
                [self computeSublevelsOrgWith:subOrg];
            }
        }
    }
}


- (NSMutableAttributedString *)text:(NSString *)text addSpecialColor:(UIColor *)color  inRange:(NSRange)range {
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttribute:NSForegroundColorAttributeName value:color range:range];
    return str;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
