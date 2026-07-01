//
//  WSTileListContentView.h
//  WinSFA
//
//  Created by heju on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TileBtnClickBlock)(NSInteger tag,NSArray *selectedOrgs);


@interface WSTileListContentView : UIView

@property (nonatomic,copy) TileBtnClickBlock tileClickBlock;

@property (nonatomic,strong) NSMutableArray *dataSource;


- (id)initWithFrame:(CGRect)frame;

- (void)loadSubViewsAndTableNum:(NSInteger )num qstName:(NSString *)qstName;

- (void)setDataSource:(NSMutableArray *)dataSource  redisOrgs:(NSMutableArray *)redisOrgs;

@end
