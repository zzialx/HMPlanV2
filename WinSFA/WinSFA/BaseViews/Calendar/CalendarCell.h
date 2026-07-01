//
//  CalendarCell.h
//  TimeCalenda
//
//  Created by LIBB on 16/12/2.
//  Copyright © 2016年 LIBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MonthModel.h"

@interface CalendarCell : UICollectionViewCell{
    //10号位置图片
    UIImageView * cc_topImageView;
    //12号位置图片
    UIImageView * cc_botomLImageView;
    //13号位置图片
    UIImageView * cc_botomRImageView;
    
    UIImageView * isPlanImg;

    
}

@property (weak, nonatomic) UILabel *dayLabel;
@property (strong, nonatomic) MonthModel *monthModel;
@property (assign,nonatomic) BOOL visible;
@property (assign,nonatomic) BOOL newPlan;
@property (weak, nonatomic) UIView *topLine;
@property (weak, nonatomic) UIView *bottomline;
@property (assign,nonatomic) BOOL isPlan;




@end
