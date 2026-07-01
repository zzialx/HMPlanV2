//
//  WSVisitCollectionViewCell.m
//  WinSFA
//
//  Created by winchannel on 2018/3/12.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import "WSVisitCollectionViewCell.h"
#import "WSHosBean.h"
#import "WSRequestHelper.h"

#define k_ICON_VIEW_WIDTH (INTERFACE_IS_PHONE ? 36 : 36)

#define K_FILLED_OUT_STATUS_VIEW_WIDHT (INTERFACE_IS_PHONE ? 60 : 85)
#define K_FILLED_OUT_STATUS_VIEW_HEGIHT (INTERFACE_IS_PHONE ? 20 : 25)
#define K_FILLED_OUT_STATUS_VIEW_RIGHT_SPACE (INTERFACE_IS_PHONE ? 15 : 20)

#define k_TITLE

#define k_STATUS_VIEW_WIDHT 36

@interface WSVisitCollectionViewCell ()
{
    
}
@property (nonatomic, strong)UIImageView *iconView;
@property (nonatomic, strong)UIImageView *visitStatusView;
@property (nonatomic, strong)UILabel *titleLabel;
@property (nonatomic, strong)UIImageView *filledOutStatusImageView;
@property (nonatomic, strong)UIView *lineView;
@end

@implementation WSVisitCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.iconView = [[UIImageView alloc]initWithFrame:CGRectMake(MAIN_CELL_PADDING, (frame.size.height - k_ICON_VIEW_WIDTH)/2.0, k_ICON_VIEW_WIDTH, k_ICON_VIEW_WIDTH)];
        self.iconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.iconView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.iconView];
        
        CGFloat filledOutViewX = self.frame.size.width - K_FILLED_OUT_STATUS_VIEW_WIDHT - K_FILLED_OUT_STATUS_VIEW_RIGHT_SPACE;
        CGFloat titleX = k_ICON_VIEW_WIDTH + 2*MAIN_CELL_PADDING;
        CGFloat titleWidth = filledOutViewX - titleX - MAIN_CELL_PADDING;
        CGFloat visitStatusViewX = self.frame.size.width - k_STATUS_VIEW_WIDHT - K_FILLED_OUT_STATUS_VIEW_RIGHT_SPACE;
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(titleX , 0, titleWidth , frame.size.height)];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.contentMode = UIViewContentModeCenter;
        titleLabel.font =  FONT_SIZE_PINGFANG_MEDIUM(UI_Font);
        titleLabel.numberOfLines = 0;
        self.titleLabel = titleLabel;
        [self.contentView addSubview:titleLabel];
        
        self.visitStatusView = [[UIImageView alloc]initWithFrame:CGRectMake(visitStatusViewX, (frame.size.height - k_STATUS_VIEW_WIDHT)/2.0, k_STATUS_VIEW_WIDHT, k_STATUS_VIEW_WIDHT)];
        [self.visitStatusView setImage:[UIImage imageNamed:@"visit_action_done"]];
        self.visitStatusView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview: self.visitStatusView];
        
        _filledOutStatusImageView = [[UIImageView alloc] initWithFrame:CGRectMake(filledOutViewX, (self.frame.size.height - K_FILLED_OUT_STATUS_VIEW_HEGIHT)/2, K_FILLED_OUT_STATUS_VIEW_WIDHT, K_FILLED_OUT_STATUS_VIEW_HEGIHT)];
        [_filledOutStatusImageView setImage:[UIImage imageNamed:@"already_filled_out_icon"]];
        _filledOutStatusImageView.hidden = YES;
        [self.contentView addSubview:_filledOutStatusImageView];
        
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(titleX, frame.size.height, frame.size.width - titleX, 1)];
        _lineView.backgroundColor = [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1];
        [self.contentView addSubview:_lineView];
        
        
    }
    return self;
    
}

- (void)setDataWithFuncsBean:(WSFuncsBean *)aFuncsBean
                 withHosBean:(WSHosBean *)aHosBean
           visitActionStatus:(VisitActionStatus)visitActionStatus
        isContaintDepartment:(BOOL)isContaint
                    isDoctor:(BOOL)isDoctor{

    if (aHosBean) {
        if (isDoctor) {
            self.iconView.hidden = NO ;
            self.titleLabel.frame = CGRectMake(self.iconView.left, self.titleLabel.top, self.titleLabel.width, self.titleLabel.height);
            self.lineView.frame = CGRectMake(self.titleLabel.left, self.lineView.top, self.width, self.lineView.height);
        }else{
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:aHosBean.iconUrl] imageView:self.iconView placeholderImage:[UIImage imageForName:@"shop_default@2x"]];
        }
        
        self.titleLabel.text = aHosBean.name;
        BOOL isShowFillStatus = NO;
        if (aHosBean.state.length >0 && [aHosBean.state isEqualToString:@"1"]) {
            isShowFillStatus = YES;
        }
        if (aFuncsBean.opt.isShowAlreadyFilledStatus.length > 0 && [aFuncsBean.opt.isShowAlreadyFilledStatus isEqualToString:@"1"]){
            isShowFillStatus = YES;
            if ([aFuncsBean.opt.isHiddenFilledOutStatusImageView isEqualToString:@"1"] && isContaint) {
                isShowFillStatus = NO;
            }
        }
        
        if ([visitActionStatus isEqualToString:ActionDone]) {
            if (isShowFillStatus) {
                self.visitStatusView.hidden = YES;
                self.filledOutStatusImageView.hidden = NO;
            }else{
                self.visitStatusView.hidden = NO;
                self.filledOutStatusImageView.hidden = YES;
            }
        }else{
            self.visitStatusView.hidden = YES;
        }
    }else{
        self.titleLabel.text = nil;
        self.lineView.hidden = YES;
        self.iconView.hidden = YES;
        self.visitStatusView.hidden = YES;
    }
}

@end
