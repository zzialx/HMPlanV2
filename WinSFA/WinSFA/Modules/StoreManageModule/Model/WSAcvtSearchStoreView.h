//
//  WSAcvtSearchStoreView.h
//  WinSFA
//
//  Created by heju on 2016/12/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSAcvtSearchStoreViewDelegate;

@interface WSAcvtSearchStoreView : UIView

@property (nonatomic,weak) id <WSAcvtSearchStoreViewDelegate>delegate;

- (id)initWithFrame:(CGRect)frame current:(WSFuncsBean *)currentFuncs  acvtBean:(WSAcvtBean *)acvtBean;

@property (nonatomic, strong) UIView *blockView;
@property (nonatomic, strong) UIView *rightView;
@property (nonatomic,strong)WSAcvtBean *acvtBean;
@property (nonatomic, strong) WSLocationDescribe *locationDescribe;

- (void)requestStoreAcvtdisData;
- (void)celearData;
#pragma mark -刷新问卷的数据源
- (void)refreshStoreAcvtDataSource;

@end

@protocol WSAcvtSearchStoreViewDelegate <NSObject>

- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView isShow:(BOOL)isShow;

- (void)acvtSearchStoreView:(WSAcvtSearchStoreView *)storeView  searchStoreWithCondition:(NSMutableDictionary *)conditions  rangeConditions:(NSDictionary *)rangeConditions distance:(CGFloat)distance searchStoreType:(NSString *)storeType;;
@end
