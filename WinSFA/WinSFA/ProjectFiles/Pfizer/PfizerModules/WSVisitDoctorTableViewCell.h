//
//  WSVisitDoctorTableViewCell.h
//  WinSFA
//
//  Created by heju on 16/9/12.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


#import "WSHosBean.h"


#import "WSStoreBean.h"

@interface WSVisitDoctorTableViewCell : UITableViewCell

@property (nonatomic,strong) UIImageView *filledOutStatusImageView;

- (void)setModel:(WSHosBean *)hosBean  plan:(BOOL)plan;


@end
