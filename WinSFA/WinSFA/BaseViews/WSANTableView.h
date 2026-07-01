//
//  WSANTableView.h
//  WinSFA
//
//  Created by xiajl on 14-11-6.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WSANTableViewDelegate;

@class WSAcvtBean;

@interface WSANTableView : UIView

@property(nonatomic ,weak) id<WSANTableViewDelegate> delegate;

@property (nonatomic ,strong) NSMutableArray *embeddedAcvtsMD5;
@property (nonatomic, assign) BOOL isValueChange;
@property(nonatomic ,strong)UITableView *tableView;
@property (nonatomic, assign)CGFloat offset;
@property (nonatomic,assign) BOOL usereditable;
@property(nonatomic ,strong)WSAcvtBean *acvtBean;
@property(nonatomic ,assign)BOOL readonly;
@property(nonatomic ,strong)NSMutableArray *dataArray;

- (NSUInteger)tableViewHeight;

- (void)statisticsViewHeight;

-(void)clearView;
@end


@protocol WSANTableViewDelegate <NSObject>

@optional

- (void)anTableView:(WSANTableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)anTableView:(WSANTableView *)tableView didDeleteRowAtIndexPath:(NSIndexPath *)indexPath;

- (void)anTableViewAddButtonClicked:(WSANTableView *)tableView;

- (void)anTableView:(WSANTableView *)tableView leftTitleQst:(WSAcvtBean_qst *)leftTitleQst isSelected:(BOOL)selected md5:(NSString *)md5;

@end
