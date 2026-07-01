//
//  WSAcvtListTableViewCell.h
//  WinSFA
//
//  Created by Alicia on 2017/5/26.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSAcvtListTableViewCell : UITableViewCell

@property (strong, nonatomic) UIImageView *iconImageView;
@property (nonatomic, strong) UIImageView  *isRequireImageView;

- (void)setAction:(WSVisitStoreActionObject *)action andAcvtBean:(WSAcvtBean *)acvtBean;

@end
