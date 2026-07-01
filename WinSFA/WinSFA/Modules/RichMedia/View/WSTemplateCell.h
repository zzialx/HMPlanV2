//
//  WSTemplateCell.h
//  WinSFA
//
//  Created by huzepei on 16/8/16.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSTemplateCell : UITableViewCell

@property (nonatomic,strong) NSIndexPath *cellIndexPath;

@property (nonatomic,strong) NSString *title;

@property (nonatomic,copy) void (^clickPlusBtn)(NSIndexPath *path);

@property (weak, nonatomic) IBOutlet UIButton *templateBtn;


@end
