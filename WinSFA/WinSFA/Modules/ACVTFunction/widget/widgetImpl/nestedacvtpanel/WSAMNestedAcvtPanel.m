//
//  WSAMNestedAcvtPanel.m
//  WinSFA
//
//  Created by yang on 16/1/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSAMNestedAcvtPanel.h"
#import "I_W_BuildInfo.h"
#import "WSInterAction.h"
#import "WSEmbeddedAcvtViewController.h"
#import "WSAcvtModel.h"
#import "WSDataSourceManager.h"
#import "I_W_DisplayValue.h"
#import "UIButton+WebCache.h"
#import "WSEditableAcvtQstDBService.h"
#import "WSBaseAcvtDBService.h"
#import "WSPhotoLogicService.h"

#define kDefaultHeight 50

#define kViewGap 5.0f
#define kRightSpace 10.0f
#define kArrowImageViewWidth 20.0f
#define kArrowImageViewHeight 20.0f

#define kButtonWidth 50.0f
#define kButtonHeight 30.0f

#define kLeftViewWith 50
#define kLeftLineViewLeftOffset 25
#define kLeftImageViewWidth 17

@interface WSAMNestedAcvtPanel ()

@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) UIImageView *leftImageView;

@end

@implementation WSAMNestedAcvtPanel

- (void)buildDisplayContent
{
    [super buildDisplayContent];
    
    WSBaseAcvtDBService *service = [[WSBaseAcvtDBService alloc] init];
    self.nestedAcvtBean = [service queryAcvtByFilter:[xbuildInfo getFilterCondition] acvtCode:[xbuildInfo getFilterCondition]];
    
    
    if ([self isShowLeftLine]) {
        CGRect frame = self.titleLabel.frame;
        frame.origin.x = kLeftViewWith;
        self.titleLabel.frame = frame;
        
        frame = self.bottomLineView.frame;
        frame.size.width -= kLeftViewWith - frame.origin.x;
        frame.origin.x = kLeftViewWith;
        self.bottomLineView.frame = frame;
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(kLeftLineViewLeftOffset, 0, 1, kDefaultHeight)];
        line.backgroundColor = RGBCOLOR(234, 234, 234);
        [self addSubview:line];
        
        if ([self isShowLeftIcon]) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, (kDefaultHeight - kLeftImageViewWidth)/2, kLeftImageViewWidth, kLeftImageViewWidth)];
            CGPoint center = imageView.center;
            center.x = line.center.x;
            imageView.center = center;
            [self addSubview:imageView];
            self.leftImageView = imageView;
        }
    }
    
    if (self.nestedAcvtBean) {
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.width - kRightSpace - kArrowImageViewWidth, (kDefaultHeight - kArrowImageViewHeight)/2, kArrowImageViewWidth, kArrowImageViewHeight)];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        imageView.image = [UIImage scaledImageForName:@"arrow_right" ofType:@"png"];
        self.rightArrowImageView = imageView;
        [self addSubview:self.rightArrowImageView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTapped)];
        [self addGestureRecognizer:tap];
        
        CGRect frame = self.titleLabel.frame;
        frame.size.width = self.rightArrowImageView.left - kViewGap - self.titleLabel.left;
        self.titleLabel.frame = frame;
    }
    
    if ([[xbuildInfo getQuestIconURL] length] > 0) {
        
        self.backgroundColor = [UIColor whiteColor];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(self.width - kRightSpace - kButtonWidth, (kDefaultHeight - kButtonHeight)/2, kButtonWidth, kButtonHeight)];
        NSString *urlString = [WSHttpURLHelper getImageCompleteURL:[xbuildInfo getQuestIconURL]];
        NSURL *url = [NSURL URLWithString:urlString];
        LogInfo(@"button开始下载图标，name:%@, url:%@, 完整url:%@，url对象：%@", [xbuildInfo getQuestName],[xbuildInfo getQuestIconURL], urlString, url ? @"YES":@"NO");
        [button sd_setBackgroundImageWithURL:url forState:UIControlStateNormal completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            if (!error && image) {
                
                LogInfo(@"WSAMNestedAcvtPanel button图片下载完成, name:%@, acvtQstId:%@, url:%@", [xbuildInfo getQuestName], [xbuildInfo getAcvtQstId], imageURL);
                
                CGFloat buttonWidth = (image.size.width / image.size.height) * kButtonHeight;
                button.frame = CGRectMake(button.origin.x - (buttonWidth - button.width), button.origin.y, buttonWidth, kButtonHeight);
                
                CGFloat labelWidth = self.width - kViewGap * 2 - kRightSpace - self.titleLabel.right - ([self.actionButton isHidden] ? 0 : buttonWidth);
                self.textLabel.frame = CGRectMake(self.titleLabel.right + kViewGap, 0, labelWidth, self.height);
                
            }else {
                
                LogInfo(@"WSAMNestedAcvtPanel button图片下载失败, name:%@, acvtQstId:%@, url:%@", [xbuildInfo getQuestName], [xbuildInfo getAcvtQstId], imageURL);
                
                UIImage *failedImage = [UIImage imageForName:@"picture_loading_failed"];
                CGFloat buttonWidth = (failedImage.size.width / failedImage.size.height) * kButtonHeight;
                button.frame = CGRectMake(button.origin.x - (buttonWidth - button.width), button.origin.y, buttonWidth, kButtonHeight);
                
                CGFloat labelWidth = self.width - kViewGap * 2 - kRightSpace - self.titleLabel.right - ([self.actionButton isHidden] ? 0 : buttonWidth);
                self.textLabel.frame = CGRectMake(self.titleLabel.right + kViewGap, 0, labelWidth, self.height);
                [button setBackgroundImage:failedImage forState:UIControlStateNormal];
            }
            
        }];
        [button addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
        
        self.actionButton = button;
        
        BOOL isReadOnly = [[xbuildInfo getReadOnly] isEqualToString:@"1"] ? YES : NO;
        
        if (isReadOnly) {
            [self.actionButton setHidden:YES];
        }
        
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        WSEditableAcvtQstBean *qstBean = [WSEditableAcvtQstDBService queryObjectWithGen_id:model.md5 acvtId:model.currentAcvtBean.acvtId acvtQstId:[xbuildInfo getAcvtQstId]];
        
        if ([qstBean.value isEqualToString:@"1"]) {
            [xbuildInfo setIsReadOnly:@"0"];
            [self.actionButton setHidden:NO];
        }
        LogInfo(@"actionButton isHidden:%@, %@, %@", [self.actionButton isHidden] ? @"YES" : @"NO", [xbuildInfo getQuestName],self.actionButton);
    }
    
    CGFloat labelWidth = self.width - kViewGap * 2 - kRightSpace - self.titleLabel.right - ([self.actionButton isHidden] ? 0 : self.actionButton.width);
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.titleLabel.right + kViewGap, 0, labelWidth, self.height)];
    label.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [label setBackgroundColor:[UIColor clearColor]];
    [label setFont:[UIFont systemFontOfSize:UI_Font - 1]];
    [label setTextColor:[UIColor lightGrayColor]];
    [label setTextAlignment:NSTextAlignmentRight];
    [label setLineBreakMode:NSLineBreakByTruncatingHead];
    label.adjustsFontSizeToFitWidth = YES;
    [self addSubview:label];
    self.textLabel = label;
    
    if (!self.nestedAcvtBean && _originalValue && [_originalValue isKindOfClass:[NSString class]]) {
        self.textLabel.text = (NSString *)_originalValue;
    }
    
    if (self.actionButton) {
        [self addSubview:self.actionButton];
    }
    
    
    if ([self isShowLeftIcon]) {
        
        [self refreshLeftImageViewState];
    }

    
    CGRect labelFrame = self.titleLabel.frame;
    labelFrame.origin.y = (kDefaultHeight - labelFrame.size.height)/2;
    self.titleLabel.frame = labelFrame;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, kDefaultHeight);
    
}

- (void)refreshLeftImageViewState
{
    if ([self isShowLeftIcon]) {
        if ([self hasData]) {
            self.leftImageView.image = [UIImage scaledImageForName:@"icon_workstatus_done" ofType:@"png"];
        }else if (self.actionButton && ![self.actionButton isHidden]) {
            self.leftImageView.image = [UIImage scaledImageForName:@"icon_workstatus_working" ofType:@"png"];
        }else {
            self.leftImageView.image = [UIImage scaledImageForName:@"icon_workstatus_notbegin" ofType:@"png"];
        }
    }
}

- (BOOL)hasData
{
    BOOL result = NO;
    
    if (!self.nestedAcvtBean) {
        if (![self.textLabel isHidden] && [self.textLabel.text length] > 0) {
            result = YES;
        }
    }else {
        if ([self.acvtDataArray count] > 0) {
            result = YES;
        }
    }
    
    return result;
}

- (BOOL)isShowLeftLine
{
    if ([[xbuildInfo getAcvtMemo] isEqualToString:@"1"] || [[xbuildInfo getAcvtMemo] isEqualToString:@"2"]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isShowLeftIcon
{
    if ([[xbuildInfo getAcvtMemo] isEqualToString:@"1"]) {
        return YES;
    }
    
    return NO;
}

- (void)setReadonly:(NSString *)isReadonly
{
    [super setReadonly:isReadonly];
    
    if (!self.nestedAcvtBean) {
        self.backgroundColor = [UIColor whiteColor];
    }
    
    self.userInteractionEnabled = ![[xbuildInfo getReadOnly] boolValue];
    
    [self.actionButton setHidden:[[xbuildInfo getReadOnly] boolValue]];
    
    LogInfo(@"actionButton isHidden:%@ , %@, %@", [self.actionButton isHidden] ? @"YES" : @"NO", [xbuildInfo getQuestName], self.actionButton);
    
    CGFloat labelWidth = self.width - kViewGap * 2 - kRightSpace - self.titleLabel.right - ([self.actionButton isHidden] ? 0 : self.actionButton.width);
    
    self.textLabel.frame = CGRectMake(self.titleLabel.right + kViewGap, 0, labelWidth, self.height);
    
    
    NSString *luaScript = [xbuildInfo getLuaScript];
    
    if ([luaScript rangeOfString:@"excuseAction"].location != NSNotFound  || [luaScript rangeOfString:@"showDialogAndExcuseAction"].location != NSNotFound ) {
        
        WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
        
        if ([[xbuildInfo getReadOnly] isEqualToString:@"0"]) {
            [WSEditableAcvtQstDBService insertOrUpdateEditableAcvtQstWithValue:@"1" gen_id:model.md5 acvtId:model.currentAcvtBean.acvtId acvtQstId:[xbuildInfo getAcvtQstId] qstId:[xbuildInfo getQstId]];
        }else if ([[xbuildInfo getReadOnly] isEqualToString:@"1"]) {
            [WSEditableAcvtQstDBService insertOrUpdateEditableAcvtQstWithValue:@"0" gen_id:model.md5 acvtId:model.currentAcvtBean.acvtId acvtQstId:[xbuildInfo getAcvtQstId] qstId:[xbuildInfo getQstId]];
        }
    }
    
    [self refreshLeftImageViewState];
    
}

- (void)setCurrentValueWithPresentation:(NSString *)valuePresentation
{
    self.textLabel.text = valuePresentation;
    
    if ((!valuePresentation || [valuePresentation length] == 0) && self.nestedAcvtBean) {
        [self.acvtDataArray removeAllObjects];
        [self.acvtMd5Array removeAllObjects];
        _originalValue = nil;
    }
    
    [self refreshLeftImageViewState];
}

- (NSObject *)getResultDirectly
{
    if (!self.nestedAcvtBean) {
        return self.textLabel.text;
    }else {

        if ([self.acvtDataArray count] > 0) {
            
            if (!self.isEmbeddedAcvtConfirmedData) {
                NSMutableArray *photoQsts = [NSMutableArray array];
                for (WSAcvtBean_qst *qst in self.nestedAcvtBean.qsts) {
                    if ([qst.qstType isEqualToString:QST_TYPE_P]) {
                        [photoQsts addObject:qst];
                    }
                }
                if ([photoQsts count] > 0) {
                    
                    NSMutableDictionary *dic = [[self.acvtDataArray firstObject] mutableCopy];
                    
                    for (WSAcvtBean_qst *qst in photoQsts) {
                        NSString *key = [NSString stringWithFormat:@"%@%@", qst.qstType, qst.acvtQstId];
                        NSString *value = dic[key];
                        if ([value length] > 0 && [value rangeOfString:@"@"].location != NSNotFound) {
                            NSString *flag = qst.isCoverNewId;
                            NSString *serverImageIndex = [WSPhotoLogicService getImageIndexFromServerRedisValue:value];
                            if ((!flag || [flag isEqualToString:@"0"]) && [serverImageIndex length] > 0) {
                                [dic setObject:serverImageIndex forKey:key];
                            }
                        }
                    }
                    
                    [self.acvtDataArray replaceObjectAtIndex:0 withObject:dic];
                    
                }
            }
            
            return [self.acvtDataArray JSONString];
        }
        
    }
    
    return nil;
    
}

- (NSObject *)getResultPresentation
{
    return [self getResultDirectly];
}

- (void)cellTapped
{
    WSInterAction  *interaction =[[WSInterAction alloc] init];
    
    [interaction setAcvt_qust_id:[xbuildInfo  getAcvtQstId]];
    
    [interaction setDirect_type:DIRECT_TYPE_PUSH];
    
    WSAcvtModel *model = (WSAcvtModel *)[WSDataSourceManager sharedInstance].currentActiveModel;
    
    NSString *md5;
    if ([self.acvtMd5Array count] > 0) {
        md5 = [self.acvtMd5Array firstObject];
    }else if ([_originalValue isKindOfClass:[NSString class]]) {
        md5 = (NSString *)_originalValue;
    }
    
    [self.nestedAcvtBean setParentgenId:model.md5];
    [self.nestedAcvtBean setAcvtParentQstId:[xbuildInfo getAcvtQstId]];
    [self.nestedAcvtBean setParentAcvtId:model.currentAcvtBean.acvtId];
    WSEmbeddedAcvtViewController *acvtCon = [[WSEmbeddedAcvtViewController alloc] initWithAcvt:self.nestedAcvtBean Funcs:model.currentFuncs Store:model.currentStore md5:md5];
    acvtCon.parentModel = model;
    acvtCon.delegate = self;
    
    [interaction setExecute_controller:acvtCon];
    
    
    if ([delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [delegate executeInterAction:interaction];
        
    }
}

- (void)buttonTapped
{
    if ([xbuildInfo getLuaScript] && [[xbuildInfo getLuaScript] length] > 0) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    
    [self refreshLeftImageViewState];
}

- (void)setBottomLineLeftPadding:(CGFloat)padding
{
    [super setBottomLineLeftPadding:padding];
    
    if (padding > 0 && [self isShowLeftLine]) {
        CGRect frame = self.bottomLineView.frame;
        frame.size.width -= kLeftViewWith - frame.origin.x;
        frame.origin.x = kLeftViewWith;
        self.bottomLineView.frame = frame;
    }
}

#pragma mark - WSEmbeddedAcvtViewControllerDelegate

- (void)embeddedAcvtController:(WSEmbeddedAcvtViewController *)controller confirmData:(NSDictionary *)dic
{
    [super embeddedAcvtController:controller confirmData:dic];
    
    NSString *luaScript = [xbuildInfo getLuaScript];
    
    if (luaScript && [luaScript length] > 0 && [luaScript rangeOfString:@"submitAction"].location != NSNotFound ) {
        if ([self.delegate respondsToSelector:@selector(executeLuaScript:widget:)]) {
            [self.delegate executeLuaScript:xbuildInfo widget:self];
        }
    }
    
    [self refreshLeftImageViewState];
}

@end
