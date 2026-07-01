//
//  WSActionSheet.m
//  WinSFA
//
//  Created by yuanji on 2017/9/18.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSActionSheet.h"

#ifndef WSActionSheet_h
#define WSActionSheet_h

#define WSAS_SCREEN_BOUNDS          [UIScreen mainScreen].bounds                                                            //屏幕边框尺寸
#define WSAS_SCREEN_WIDTH           [UIScreen mainScreen].bounds.size.width                                                 //屏幕宽度
#define WSAS_SCREEN_HEIGHT          [UIScreen mainScreen].bounds.size.height                                                //屏幕高度
#define WSAS_SCREEN_ADJUST(Value)   SCREEN_WIDTH * (Value) / 375.0                                                          //计算通用公式

#define kActionItemHeight           WSAS_SCREEN_ADJUST(50)                                                                  //条目高度
#define kTitleFontSize              WSAS_SCREEN_ADJUST(15)                                                                  //标题字体
#define kLineHeight                 1.0                                                                                     //线高度
#define kDividerHeight              8.0                                                                                     //分隔高度

#define kActionSheetColor           [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]  //动作表格颜色
#define kTitleColor                 [UIColor colorWithRed:111.0f/255.0f green:111.0f/255.0f blue:111.0f/255.0f alpha:1.0f]  //标题颜色
#define kDividerColor               [UIColor colorWithRed:230.0f/255.0f green:230.0f/255.0f blue:230.0f/255.0f alpha:1.0f]  //分隔颜色

#endif
//===================================================================================================================================================================

#pragma mark - 动作表格 延展(内部)
@interface WSActionSheet ()

@property (nonatomic, strong) NSString *title;                                  //标题
@property (nonatomic, strong) NSString *cancelTitle;                            //取消标题
@property (nonatomic, strong) NSArray  *otherTitles;                            //其它标题
@property (nonatomic, weak) id <WSActionSheetDelegate> delegate;                //代理协议
@property (nonatomic, copy) WSActionSheetDidSelectActionBlock selectActionBlock;//选择动作闭包

@property (nonatomic, weak) UIView *coverView;                                  //遮盖视图
@property (nonatomic, weak) UIView *actionSheetView;                            //动作表格视图
@property (nonatomic, assign) CGFloat offsetY;                                  //y坐标偏移量
@property (nonatomic, assign) CGFloat actionSheetHeight;                        //动作表格高度

- (void)didSelectSheet:(UIButton *)button;  //按键响应方法 button:按键
- (void)dismiss;                            //解除方法

@end
//===================================================================================================================================================================

#pragma mark - 动作表格 延展(工具)
@interface WSActionSheet (Tools)

- (void)setupCover;                 //设置遮盖方法
- (void)setupActionSheet;           //设置动作表格方法
- (void)setupTitleLabel;            //设置标题方法
- (void)setupOtherActionItems;      //设置其它动作条目方法
- (void)setupCancelActionItem;      //设置取消条目方法

@end
//===================================================================================================================================================================

#pragma mark - 动作表格
@implementation WSActionSheet

#pragma mark - 自定义初始化方法(+号) title:标题 cancelTitle:取消标题 otherTitles:其它标题 selectActionBlock:选择闭包
+ (instancetype)ws_actionSheetViewWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
                          selectActionBlock:(WSActionSheetDidSelectActionBlock)selectActionBlock
{
    return [[self alloc] initWithTitle:title cancelTitle:cancelTitle otherTitles:otherTitles selectActionBlock:selectActionBlock];
}

#pragma mark - 自定义初始化方法(-号) title:标题 cancelTitle:取消标题 otherTitles:其它标题selectActionBlock:选择闭包
- (instancetype)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
            selectActionBlock:(WSActionSheetDidSelectActionBlock)selectActionBlock
{
    self = [super initWithFrame:WSAS_SCREEN_BOUNDS];
    if (self)
    {
        _title = title;
        _cancelTitle = cancelTitle;
        _otherTitles = otherTitles;
        _selectActionBlock = selectActionBlock;
        
        [self setupCover];
        [self setupActionSheet];
    }
    return self;
}

#pragma mark - 自定义初始化方法(+号) title:标题 cancelTitle:取消标题 otherTitles:其它标题 delegate:代理指针
+ (instancetype)sr_actionSheetViewWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
                                   delegate:(id<WSActionSheetDelegate>)delegate
{
    return [[self alloc] initWithTitle:title cancelTitle:cancelTitle otherTitles:otherTitles delegate:delegate];
}

#pragma mark - 自定义初始化方法(-号) title:标题 cancelTitle:取消标题 otherTitles:其它标题 delegate:代理指针
- (instancetype)initWithTitle:(NSString *)title cancelTitle:(NSString *)cancelTitle otherTitles:(NSArray *)otherTitles
                     delegate:(id<WSActionSheetDelegate>)delegate
{
    self = [super initWithFrame:WSAS_SCREEN_BOUNDS];
    if (self)
    {
        _title = title;
        _cancelTitle = cancelTitle;
        _otherTitles = otherTitles;
        _delegate = delegate;
        
        [self setupCover];
        [self setupActionSheet];
    }
    return self;
}

#pragma mark - 显示方法
- (void)show
{
    // MMSH-2149 备注， 如果出现 blockWindow 弹出框 keywindow 就会变成弹出框
    // [[UIApplication sharedApplication].keyWindow addSubview:self];
    [[[[UIApplication sharedApplication] delegate] window]  addSubview:self];
    
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.coverView.alpha = 1.0;
                         self.actionSheetView.transform = CGAffineTransformMakeTranslation(0, -self.actionSheetHeight);
                     }
                     completion:nil];
}

#pragma mark - 按键响应方法 button:按键
- (void)didSelectSheet:(UIButton *)button
{
    if (_selectActionBlock)
        _selectActionBlock(self, button.tag);
    
    if ([_delegate respondsToSelector:@selector(actionSheet:didSelectSheet:)])
        [_delegate actionSheet:self didSelectSheet:button.tag];
    
    [self dismiss];
}

#pragma mark - 解除方法
- (void)dismiss
{
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.9 initialSpringVelocity:0.7 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         self.coverView.alpha = 0.0;
                         self.actionSheetView.transform = CGAffineTransformIdentity;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}

@end
//===================================================================================================================================================================

#pragma mark - 动作表格 延展(工具)
@implementation WSActionSheet (Tools)

#pragma mark - 设置遮盖方法
- (void)setupCover
{
    UIView *cover = [[UIView alloc] init];
    cover.frame = self.bounds;
    cover.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.33];
    cover.alpha = 0;
    [cover addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)]];
    _coverView = cover;
    [self addSubview:cover];
}

#pragma mark - 设置动作表格方法
- (void)setupActionSheet
{
    UIView *actionSheet = [[UIView alloc] init];
    actionSheet.backgroundColor = kActionSheetColor;
    _actionSheetView = actionSheet;
    [self addSubview:actionSheet];
    
    _offsetY = 0;
    [self setupTitleLabel];
    [self setupOtherActionItems];
    
    UIView *dividerView = [[UIView alloc] initWithFrame:CGRectMake(0, _offsetY, self.frame.size.width, kDividerHeight)];
    dividerView.backgroundColor = kDividerColor;
    [self.actionSheetView addSubview:dividerView];
    
    [self setupCancelActionItem];
    
    _actionSheetView.frame = CGRectMake(0, CGRectGetHeight(self.frame), CGRectGetWidth(self.frame), _offsetY);
    _actionSheetHeight = _offsetY;
}

#pragma mark - 设置标题方法
- (void)setupTitleLabel
{
    if (!_title || _title.length == 0)
        return;
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kActionItemHeight)];
    titleLabel.backgroundColor = [UIColor whiteColor];
    titleLabel.textColor = kTitleColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
    titleLabel.numberOfLines = 0;
    titleLabel.text = self.title;
    
    [self.actionSheetView addSubview:titleLabel];
    self.offsetY += kActionItemHeight + kLineHeight;
}

#pragma mark - 设置其它动作条目方法
- (void)setupOtherActionItems
{
    if (!_otherTitles || _otherTitles.count == 0)
        return;
    
    for (int i = 0; i < _otherTitles.count; ++i)
    {
        UIButton *otherBtn = [[UIButton alloc] init];
        otherBtn.frame = CGRectMake(0, _offsetY, self.frame.size.width, kActionItemHeight);
        otherBtn.backgroundColor = [UIColor whiteColor];
        otherBtn.titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
        [otherBtn setTitle:_otherTitles[i] forState:UIControlStateNormal];
        [otherBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        otherBtn.tag = i;
        [otherBtn addTarget:self action:@selector(didSelectSheet:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.actionSheetView addSubview:otherBtn];
        if (i == _otherTitles.count - 1)
            _offsetY += kActionItemHeight;
        else
            _offsetY += kActionItemHeight + kLineHeight;
    }
}

#pragma mark - 设置取消条目方法
- (void)setupCancelActionItem
{
    if (!_cancelTitle || _cancelTitle.length == 0)
        return;
    
    _offsetY += kDividerHeight;
    
    UIButton *cancelBtn = [[UIButton alloc] init];
    cancelBtn.frame = CGRectMake(0, _offsetY, self.frame.size.width, kActionItemHeight);
    cancelBtn.tag = -1;
    cancelBtn.backgroundColor = [UIColor whiteColor];
    cancelBtn.titleLabel.font = [UIFont systemFontOfSize:kTitleFontSize];
    [cancelBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancelBtn setTitle:_cancelTitle forState:UIControlStateNormal];
    [cancelBtn addTarget:self action:@selector(didSelectSheet:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.actionSheetView addSubview:cancelBtn];
    _offsetY += kActionItemHeight;
}

@end
//===================================================================================================================================================================
