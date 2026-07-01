//
//  WinDBSelectBoxPanel.m
//  WinSFA
//
//  Created by yuanji on 2022/11/1.
//  Copyright © 2022 WinChannel. All rights reserved.
//

#import "WinDBSelectBoxPanel.h"
#import "I_W_DisplayValue.h"

#define kDBSelectBoxButtonStartTag 900
//==============================================================================================================================

@interface WinDBSelectBoxPanel ()

@property (nonatomic, strong) UILabel *selectBoxTitleLabel; //选择盒子标题标签
@property (nonatomic, strong) UIView *spaceView;            //间隔视图
@property (nonatomic, strong) NSMutableArray * dataList;
@end
//==============================================================================================================================

@implementation WinDBSelectBoxPanel

#pragma mark - 获取selectBoxTitleLabel方法
- (UILabel *)selectBoxTitleLabel {
    
    if (!_selectBoxTitleLabel) {
        
        _selectBoxTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _selectBoxTitleLabel.backgroundColor = [UIColor clearColor];
        _selectBoxTitleLabel.textAlignment = NSTextAlignmentLeft;
        _selectBoxTitleLabel.textColor = [UIColor colorWithRed:(50.0f/255) green:(50.0f/255) blue:(50.0f/255) alpha:1.0f];
        _selectBoxTitleLabel.font = [UIFont boldSystemFontOfSize:15.0f];
    }
    return _selectBoxTitleLabel;
}

#pragma mark - 获取spaceView方法
- (UIView *)spaceView {
    
    if (!_spaceView) {
        
        _spaceView = [[UIView alloc] initWithFrame:CGRectZero];
        _spaceView.backgroundColor = [UIColor colorWithRed:(241.0f/255) green:(241.0f/255) blue:(241.0f/255) alpha:1.0f];
    }
    return _spaceView;
}

#pragma mark - 重写buildDisplayContent方法
- (void)buildDisplayContent {
    
    [super buildDisplayContent];
    [self removeAllSubviews];
    self.backgroundColor = [UIColor whiteColor];
    
    CGFloat space = 10.0f;
    CGFloat offY = 10.0f;
    NSInteger maxCount = 2;
    CGFloat buttonWidth = ((self.width - space * 2) - ((maxCount - 1) * space)) / maxCount;
    CGFloat buttonHeight = 32.0f;
    
    [self addSubview:self.selectBoxTitleLabel];
    NSString *questName = [xbuildInfo getQuestName];
    CGFloat constrainedWidth = (self.width - space * 2);
    CGSize size = [questName ws_sizeWithFont:self.selectBoxTitleLabel.font constrainedToWidth:constrainedWidth lineBreakMode:NSLineBreakByWordWrapping];
    self.selectBoxTitleLabel.text = questName;
    self.selectBoxTitleLabel.frame = CGRectMake(space, offY, size.width, size.height);
    offY = CGRectGetMaxY(self.selectBoxTitleLabel.frame) + space;
    
    NSArray *optArray = [xbuildInfo getOptArray];
    if(self.dataList.count>0){
        optArray = self.dataList.copy;
    }
    for (int i = 0; i < optArray.count; ++i) {
        
        NSInteger row = i / maxCount;
        NSInteger col = i % maxCount;
        CGFloat x = (col * buttonWidth) + (col * space) + space;
        CGFloat y = (row * buttonHeight) + (row * space) + offY;
        WSAcvtBean_qst_opt *option = [optArray objectAtIndex:i];
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(x, y, buttonWidth, buttonHeight);
        button.tag = kDBSelectBoxButtonStartTag + i;
        button.layer.cornerRadius = 5.0f;
        button.layer.masksToBounds = YES;
        [button setTitle:option.optName forState:UIControlStateNormal];
        [button setTitleColor:[UIColor colorWithRed:(50.0f/255) green:(50.0f/255) blue:(50.0f/255) alpha:1.0f] forState:UIControlStateNormal];
        [button.titleLabel setFont:[UIFont systemFontOfSize:13.0f]];
        [button setBackgroundImage:[UIImage createImageWithColor:[UIColor colorWithRed:(241.0f/255) green:(241.0f/255) blue:(241.0f/255) alpha:1.0f]] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage createImageWithColor:MAIN_TINT_COLOR] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        
        if (i == (optArray.count - 1)) {
            offY = CGRectGetMaxY(button.frame) + space;
        }
    }
    
    [self addSubview:self.spaceView];
    self.spaceView.frame = CGRectMake(0.0f, offY, self.width, 3.0f);
    offY = CGRectGetMaxY(self.spaceView.frame);
    
    self.frame = CGRectMake(CGRectGetMinX(self.frame), CGRectGetMinY(self.frame), CGRectGetWidth(self.frame), offY);
}

#pragma mark - 按键响应方法
- (void)buttonClick:(id)sender {
    
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}

#pragma mark - 重写getResultDirectly方法(获取结果)
- (NSObject *)getResultDirectly {
    
    NSMutableArray *resultArray = [[NSMutableArray alloc] init];
    NSArray *optArray = [xbuildInfo getOptArray];
    if(self.dataList.count>0){
        optArray = self.dataList.copy;
    }
    for (int i = 0; i < optArray.count; ++i) {
        
        NSInteger tag = kDBSelectBoxButtonStartTag + i;
        UIButton *button = (UIButton *)[self viewWithTag:tag];
        if (button.selected) {
            
            WSAcvtBean_qst_opt *option = [optArray objectAtIndex:i];
            [resultArray addObject:option.optId];
        }
    }
    
    NSString *result = [NSString stringNotNilWithValue:[resultArray componentsJoinedByString:@","]];
    return result;
}
- (void)setValidDataSourceFromScript:(NSString *)validDataSource
{
    NSArray *dataSourceArray = [validDataSource componentsSeparatedByString:@","];
    NSMutableArray *validDataArray = [[NSMutableArray alloc] init];
    WSAcvtBean_qst * qst = (WSAcvtBean_qst*)xbuildInfo;
    for (NSString * data in dataSourceArray) {
        for (WSAcvtBean_qst_opt * optAnswer in qst.opt) {
            if([optAnswer.optName isEqualToString:data]){
                [validDataArray addObject:optAnswer];
                break;
            }
        }
    }
    self.dataList = validDataArray;
    [self buildDisplayContent];
}

@end
//==============================================================================================================================
