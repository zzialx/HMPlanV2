//
//  WSSearchTableViewCell.h
//  WinSFA
//
//  Created by zhiqing on 16/9/10.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRichItemModel.h"

typedef NS_ENUM(NSInteger,WSSearchTableViewCellStyle) {
    WSSearchTableViewCellStyleAdd,
    WSSearchTableViewCellStyleNone
    

};

@interface WSSearchTableViewCell : UITableViewCell
@property(nonatomic,strong) UIImageView *icon;
@property(nonatomic,strong) UILabel *name;
@property(nonatomic,strong) UIImageView *jiaobiao;
@property(nonatomic,strong ) UIButton * addButton;

@property(nonatomic,strong)WSRichItemModel * model;

@property (nonatomic,copy) void (^addDemolist)(WSRichItemModel * model);


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withStyle:(WSSearchTableViewCellStyle) cellStyle;
@end
