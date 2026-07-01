//
//  WCURLUILabel.m
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/15/13.
//
//

#import "WCURLUILabel.h"
#import "WCDownLoadingAndShowingImageView.h"
#import "DataGridComponent.h"
#import "WSAcvtDataGridComponentDataSource.h"
//=====================================================================================================================================

#pragma mark - 长按删除视图
@interface WCLongPressDeleteView : UIView

@property (nonatomic, strong) UIButton *deleteButton; //删除按键

@end
//=====================================================================================================================================

#pragma mark - 长按删除视图
@implementation WCLongPressDeleteView

#pragma mark - 获取deleteButton方法
- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor colorWithRed:(255.0f / 255.0f) green:(0.0f / 255.0f) blue:(0.0f / 255.0f) alpha:0.5f];
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:15.0f];
        [_deleteButton setTitle:NSLocalizedString(@"delete_label", nil) forState:UIControlStateNormal];
        [_deleteButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _deleteButton;
}

#pragma mark - 重写initWithFrame:方法
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.deleteButton];
    }
    return self;
}

@end
//=====================================================================================================================================


@implementation WCURLUILabel

@synthesize iImageURL = _iImageURL;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
      
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:singleTap];
        
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 1.0f;
        [self addGestureRecognizer:longPress];
    }
    return self;
}


- (void)dealloc
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

-(void)setIImageURL:(NSString *)iImageURL
{
    // MN-560 经产品测试和安卓确认注释掉以下代码，以下代码是 MSTD-321 中添加没有人知道需求也没有配置，蒙牛要求去掉该功能
    // 如果有项目需要添加该功能，请加配置
    /*
    
    if (_iImageURL != iImageURL) {
        _iImageURL = [iImageURL copy];
    }
    self.textColor = [UIColor blueColor];
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:self.text];
    NSRange strRange = {0,[str length]};
    [str addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:strRange];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strRange];
    
    self.attributedText = str;
     
     */

//    [self setNeedsDisplay];
}

#pragma mark - private function
- (void)showAlert:(NSString *)message{
    
    if (message == nil) {
        return;
    }
    [MBProgressHUD showHUDAddedTo:kApplicationWinddow withText:message tips:nil tapTarget:nil action:nil type:MBProgressHUDMessageTypeFailed];
}

#pragma mark - single tap function
- (void)handleDoubleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        [self showAlert:self.text];
    }
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        if (self.iImageURL == nil || self.iImageURL.length == 0) return;
        CGRect rect = [[UIScreen mainScreen] bounds];
        WCDownLoadingAndShowingImageView *view = [[WCDownLoadingAndShowingImageView alloc] initWithFrame:rect
                                                                                            withImageURL:self.iImageURL
                                                                                         withProductName:self.detailText ? self.detailText : self.text];
        [self.window addSubview:view];
    }
}

- (void)longPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self performSelector:@selector(showDownLoadingAndShowingView) withObject:nil afterDelay:0.1f];
    }
}

- (void)showDownLoadingAndShowingView {
    if (self.iImageURL && self.iImageURL.length > 0) {
        CGRect rect = [[UIScreen mainScreen] bounds];
        WCDownLoadingAndShowingImageView *view = [[WCDownLoadingAndShowingImageView alloc] initWithFrame:rect
                                                                                            withImageURL:self.iImageURL
                                                                                         withProductName:self.detailText ? self.detailText : self.text];
        [self.window addSubview:view];
    } else {
        if ([self.container isKindOfClass:[DataGridComponent class]]) {
            
            DataGridComponent *dataGridComponent = (DataGridComponent *)self.container;
            if (dataGridComponent.isReadOnly) {
                return;
            }
            
            if ([dataGridComponent.dataSource isKindOfClass:[WSBaseDataGridComponentDataSource class]]) {
                WSBaseDataGridComponentDataSource *dataSource = (WSBaseDataGridComponentDataSource *)dataGridComponent.dataSource;
                if (![dataSource.currentFunc.opt.deleteButton isEqualToString:@"3"]) {
                    return;
                }
            }
            
            if (self.longPressTag >= 0) {
                
                CGFloat x = 0.0f;
                CGFloat y = 0.0f;
                CGFloat w = CGRectGetWidth(self.window.frame);
                CGFloat h = CGRectGetHeight(self.window.frame);
                WCLongPressDeleteView *deleteView = [[WCLongPressDeleteView alloc] initWithFrame:CGRectMake(x, y, w, h)];
                
                UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deleteViewHandleTap:)];
                [deleteView addGestureRecognizer:singleTap];
                
                CGPoint point = [self convertPoint:CGPointMake(0,0) toView:self.window];
                x = 0.0f;
                y = point.y;
                w = CGRectGetWidth(deleteView.frame);
                h = CGRectGetHeight(self.frame);
                deleteView.deleteButton.frame = CGRectMake(x, y, w, h);
                [deleteView.deleteButton addTarget:self action:@selector(deleteButtonClick:) forControlEvents:UIControlEventTouchUpInside];
                
                [self.window addSubview:deleteView];
            }
        }
    }
}

- (void)deleteButtonClick:(id)sender {
    UIButton *button = (UIButton *)sender;
    WCLongPressDeleteView *deleteView = (WCLongPressDeleteView *)button.superview;
    [deleteView removeFromSuperview];
    deleteView = nil;
    
    if ([self.container isKindOfClass:[DataGridComponent class]]) {
        DataGridComponent *dataGridComponent = (DataGridComponent *)self.container;
        [dataGridComponent longPressDeletePods:self.longPressTag];
    }
}

- (void)deleteViewHandleTap:(UITapGestureRecognizer *)sender {
    WCLongPressDeleteView *deleteView = (WCLongPressDeleteView *)sender.view;
    [deleteView removeFromSuperview];
    deleteView = nil;
}

@end
//=====================================================================================================================================
