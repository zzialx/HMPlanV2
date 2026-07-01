//
//  WSMyJPJTableViewCell.h
//  WinSFA
//
//  Created by zhiqing on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSMyJPJTableViewCell : UITableViewCell
@property(nonatomic,strong) NSDictionary * storeDict;
@property(nonatomic,strong) WSStoreBean * storeBean;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withStyle:(NSString *)styleStr;
@end
