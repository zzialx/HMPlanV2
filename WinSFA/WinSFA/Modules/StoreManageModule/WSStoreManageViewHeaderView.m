//
//  WSStoreManageViewHeaderView.m
//  WinSFA
//
//  Created by 董宏 on 2019/12/12.
//  Copyright © 2019 WinChannel. All rights reserved.
//

#import "WSStoreManageViewHeaderView.h"
#import "WSActionSheet.h"
#import "WSAttanceViewModel.h"

static CGFloat const kStoreRouteViewHeaderViewOffset = 10;
//============================================================================================================================================

@interface WSStoreManageViewHeaderView ()

@property (nonatomic, strong) UIButton *timeBtn;
@property (nonatomic, strong) UIButton *stateBtn;//状态
@property (nonatomic, strong) UIButton *searchBtn;//状态
@property (nonatomic, strong) UIView *linView;

@end
//============================================================================================================================================

@implementation WSStoreManageViewHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self addControls];
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layoutControls];
}

- (void)addControls {
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
    [formatter setDateFormat:@"yyyy-MM"];
    
    UIButton *timeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [timeBtn setImage:[UIImage imageNamed:@"triangle_down"] forState:UIControlStateNormal];
    [timeBtn setImage:[UIImage imageNamed:@"triangle_up"] forState:UIControlStateSelected];
    [timeBtn setTitle: [formatter stringFromDate:date] forState:UIControlStateNormal];
    timeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [timeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [timeBtn addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *stateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [stateBtn setImage:[UIImage imageNamed:@"triangle_down"] forState:UIControlStateNormal];
    [stateBtn setImage:[UIImage imageNamed:@"triangle_up"] forState:UIControlStateSelected];
    [stateBtn setTitle:@"全 部" forState:UIControlStateNormal];
    stateBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [stateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [stateBtn addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setTitle:@"搜索" forState:UIControlStateNormal];
    searchBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [searchBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [searchBtn addTarget:self action:@selector(selectButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];

    [self.contentView addSubview:timeBtn];
    [self.contentView addSubview:stateBtn];
    [self.contentView addSubview:searchBtn];
    [self.contentView addSubview:view];

    self.timeBtn = timeBtn;
    self.stateBtn = stateBtn;
    self.searchBtn = searchBtn;
    self.linView = view;
}

- (void)layoutControls {
    
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat offsetX = kStoreRouteViewHeaderViewOffset;
    CGFloat offsetY = 0;
    CGFloat imageWidth = CGRectGetWidth(self.timeBtn.imageView.frame);
    CGFloat titleWidth = CGRectGetWidth(self.timeBtn.titleLabel.frame);
    self.timeBtn.frame = CGRectMake(offsetX, offsetY , 80, viewHeight);
    self.timeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 + titleWidth, 0, 0 - titleWidth);
    self.timeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 - imageWidth, 0, 0 + imageWidth);
    
    imageWidth = CGRectGetWidth(self.stateBtn.imageView.frame);
    titleWidth = CGRectGetWidth(self.stateBtn.titleLabel.frame);
    self.stateBtn.frame = CGRectMake(CGRectGetMaxX(self.timeBtn.frame)  + offsetX, offsetY , 120, viewHeight);
    self.stateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 + titleWidth, 0, 0 - titleWidth);
    self.stateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 - imageWidth, 0, 0 + imageWidth);
    
    self.searchBtn.frame = CGRectMake(viewWidth - offsetX - 50, offsetY, 50 , viewHeight);

    self.linView.frame = CGRectMake(0, viewHeight - 1, viewWidth - offsetX, 1);
}

- (void)setupStatetWithTitle:(NSString *)title {
    
    [self.stateBtn setTitle:title forState:UIControlStateNormal];
    CGFloat imageWidth = CGRectGetWidth(self.stateBtn.imageView.frame);
    CGFloat titleWidth = CGRectGetWidth(self.stateBtn.titleLabel.frame);
    self.stateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 + titleWidth, 0, 0 - titleWidth);
    self.stateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 - imageWidth, 0, 0 + imageWidth);
}

- (void)selectButtonAction:(UIButton *)btn {
    
    if (btn == self.stateBtn) {
            
        NSArray *arrName = nil;
        NSArray *arrStatus = nil;
        NSString *role = [WSAttanceViewModel getLoginUserRole];
        if ([role isEqualToString:@"SR"]) {
            arrName = @[@"全 部", @"已提交", @"已撤销", @"MDM校验未通过", @"MDM校验已通过", @"MDM入库待审批", @"MDM入库失败", @"MDM待验证", @"MDM审批拒绝", @"MDM已通过", @"MDM待申诉", @"MDM已撤销"];
            arrStatus = @[@"10", @"1", @"3", @"6", @"7", @"4", @"8", @"9", @"0", @"2", @"5", @"11"];
        }
        else {
            arrName = @[@"全 部", @"已提交", @"已通过", @"已拒绝", @"已撤销", @"确认中", @"MDM通过", @"MDM拒绝"];
            arrStatus = @[@"10", @"1", @"2", @"0", @"3", @"4", @"5", @"6"];
        }
        
        __weak typeof(self) weakSelf = self;
        WSActionSheet *actionSheet = [WSActionSheet ws_actionSheetViewWithTitle:@"选择状态" cancelTitle:nil otherTitles:arrName
                                                              selectActionBlock:^(WSActionSheet *actionSheet, NSInteger index) {
                                                                  
            if (index > -1) {
                if (![weakSelf.stateBtn.titleLabel.text isEqualToString:arrName[index]]) {
                                                                          
                    [weakSelf.stateBtn setTitle:arrName[index] forState:UIControlStateNormal];
                    CGFloat imageWidth = CGRectGetWidth(weakSelf.stateBtn.imageView.frame);
                    CGFloat titleWidth = CGRectGetWidth(weakSelf.stateBtn.titleLabel.frame);
                    weakSelf.stateBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 + titleWidth, 0, 0 - titleWidth);
                    weakSelf.stateBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 - imageWidth, 0, 0 + imageWidth);
                    [weakSelf.iDelegate storeManageStatus:[arrStatus[index] integerValue]];
                }
            }
        }];
        [actionSheet show];
    }
    else if (btn == self.timeBtn) {
        
        WSPickerView *pickerView = [WSPickerView showPickerViewInWindowWithType:WSPickerViewTypeDateYearMonth isAddDeleteButton:NO];

        __weak typeof(self) weakSelf = self;
        [pickerView setDidSelectBlock:^(NSObject *data, BOOL isOK) {
            
            if (!isOK) {
                return;
            }
            
            NSDate *date = (NSDate *)data;
            NSDateFormatter *formatter = [NSDateFormatter standardDateFormatter];
            [formatter setDateFormat:@"yyyy-MM"];
            NSString *str =  [formatter stringFromDate:date];
            if (![weakSelf.timeBtn.titleLabel.text isEqualToString:str]) {
                
                [weakSelf.timeBtn setTitle:str forState:UIControlStateNormal];
                CGFloat imageWidth = CGRectGetWidth(weakSelf.timeBtn.imageView.frame);
                CGFloat titleWidth = CGRectGetWidth(weakSelf.timeBtn.titleLabel.frame);
                weakSelf.timeBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 0 + titleWidth, 0, 0 - titleWidth);
                weakSelf.timeBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 0 - imageWidth, 0, 0 + imageWidth);
                [weakSelf.iDelegate storeManageTimeStr: [formatter stringFromDate:date]];
            }
        }];
    }
    else {
        
        WSAcvtBean *acvtBean = nil;
        [self.iDelegate storeManageSearch:acvtBean];
    }
}

@end
//============================================================================================================================================
