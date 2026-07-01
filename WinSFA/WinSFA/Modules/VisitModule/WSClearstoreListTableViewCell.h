//
//  WSClearstoreListTableViewCell.h
//  WinSFA
//
//  Created by mac on 2018/7/18.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSClearstoreListTableViewCell : UITableViewCell
@property (nonatomic, strong) WSBaseStoreOtherDataObject *storeOther;
@property (nonatomic, strong) UILabel *labName;
@property (nonatomic, strong) UIButton *btnSelect;
@end
