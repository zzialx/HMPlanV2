//
//  WSTableMVListCell.h
//  WinSFA
//
//  Created by winchannel on 16/4/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSFuncsBean.h"

@interface WSTableMVListCell : UITableViewCell

@property (nonatomic, strong) UILabel *mainTitle;
@property (nonatomic, strong) UIImageView *leftImageView;
@property (nonatomic, strong) WSFuncsBean *funcsBean;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier;


@end
