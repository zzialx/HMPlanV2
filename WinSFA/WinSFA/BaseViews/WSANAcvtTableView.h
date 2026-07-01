//
//  WSANAcvtTableView.h
//  WinSFA
//
//  Created by zhangmin on 2018/12/13.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCBaseViewController.h"


@protocol WSANAcvtTableViewDelegate;

@class WSAcvtBean;


@interface WSANAcvtTableView : UIView

@property(nonatomic ,weak) id<WSANAcvtTableViewDelegate> delegate;

@property (nonatomic ,strong) NSMutableArray *embeddedAcvtsMD5;
@property (nonatomic, assign) BOOL isValueChange;
@property(nonatomic ,strong)UITableView *tableView;
@property (nonatomic, assign)CGFloat offset;
@property (nonatomic,assign) BOOL usereditable;
@property(nonatomic ,strong)WSAcvtBean *acvtBean;
@property(nonatomic ,assign)BOOL readonly;
@property(nonatomic ,strong)NSMutableArray *dataArray;
@property(nonatomic ,assign)BOOL mainIsDelete;


@property(nonatomic ,strong)NSMutableArray *acvtVCArray; //问卷控制器数组
@property(nonatomic ,assign)float cellHight;



//加号，添加问卷
- (void)addVCViewToSelfWithViewController:(WCBaseViewController *)contentController;
//移除全部
- (void)removeAll ;
//移除某一个
- (void)removeIndex:(NSInteger )index;


@end


@protocol WSANAcvtTableViewDelegate <NSObject>

@optional


- (void)anTableView:(WSANAcvtTableView *)tableView leftTitleQst:(WSAcvtBean_qst *)leftTitleQst isSelected:(BOOL)selected md5:(NSString *)md5;

@end
