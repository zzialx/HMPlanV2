//
//  WSRichShowProdCell.h
//  WinSFA
//
//  Created by zhiqing on 16/8/28.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRichItemModel.h"
@protocol WSRichShowProdCellDelegate <NSObject>

-(void)popWebViewWith:(WSRichItemModel *)richModel;

@end

@interface WSRichShowProdCell : UITableViewCell
@property(nonatomic,weak) id delegate;
@property(nonatomic,strong) UIImageView *typeImageView;
@property(nonatomic,strong) NSArray *richItemArray;  
@property(nonatomic,strong) UIImageView *filterImageView;

;

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withStyle:(NSString * )styleType;
@end
