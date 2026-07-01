//
//  WSBaseNewAcvtListHeadView.m
//  WinSFA
//
//  Created by heju on 2016/12/5.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSBaseNewAcvtListHeadView.h"

#import "WSCalendaView.h"

#import "UIImage+Additions.h"

#import "WSBaseAcvtDBService.h"
#import "WSRequestHelper.h"

#define K_CALENDER_HEIGHT  250

#define K_BOTTOM_VIEW_HEIGHT 50

#define BOTTOM_VIEW_LEFT_MARGIN 15

#define BUTTONS_SPACE  20

#define BUTTON_TOP_MAGIN 5

#define K_BUTTON_BASE_TAG 10000

#define TitleLabelFont [UIFont systemFontOfSize:UI_Font]

@interface WSBaseNewAcvtListHeadView()<WSCalendaViewDelegate>

@property (nonatomic,strong) WSFuncsBean *currentFuncs;

@property (nonatomic,strong) NSMutableArray *addAcvtArray;

@property (nonatomic,strong) WSCalendaView *calenderView;

@property (nonatomic,strong) UIView *bottomView;

@end

@implementation WSBaseNewAcvtListHeadView


- (id)initWithFrame:(CGRect)frame currentFuncs:(WSFuncsBean *)currentFuncs addAcvtArray:(NSArray *)acvtArray {
    self = [super initWithFrame:frame];
    if (self) {
        _currentFuncs = currentFuncs;
        
        //SFA-19954 2018-05-11
        _addAcvtArray = [[NSMutableArray alloc] initWithCapacity:acvtArray.count];
        for (int i = 0; i < acvtArray.count; ++i)
        {
            WSAcvtBean *acvtBean = acvtArray[i];
            if ([acvtBean.acvtCode isEqualToString:currentFuncs.opt.hiddenCode])
                continue;
            [_addAcvtArray addObject:acvtBean];
        }

        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews {
    CGFloat y_pont = 0.0f;
    if (INTERFACE_IS_PAD)
    {
        _calenderView = [[WSCalendaView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width-k_MainkLeftVieWidth, K_CALENDER_HEIGHT) MultipleSel:NO];
    }
    else
    {
        _calenderView = [[WSCalendaView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, K_CALENDER_HEIGHT) MultipleSel:NO];
    }
     CGSize layoutSize = [self.calenderView getControlViewSize];
     _calenderView.frame = CGRectMake(_calenderView.origin.x, _calenderView.origin.y, layoutSize.width, layoutSize.height);
    _calenderView.delegate = self;
    [self addSubview:_calenderView];
    y_pont += K_CALENDER_HEIGHT;
    
    _bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.calenderView.frame.size.height, self.bounds.size.width, K_BOTTOM_VIEW_HEIGHT)];
    [self addSubview:_bottomView];
     y_pont += K_BOTTOM_VIEW_HEIGHT;
    
    
    UIView *bottomLineView = [[UIView alloc] initWithFrame:CGRectMake(0,K_BOTTOM_VIEW_HEIGHT - 2, self.bounds.size.width, 2)];
    bottomLineView.backgroundColor = [UIColor colorWithRed:241.f/255.f green:240.f/255.f blue:241.f/255.f alpha:1];
    [_bottomView addSubview:bottomLineView];
//    SFA-15849 董宏修改 修改1为0 防止崩溃 增加为0时的log提醒
    NSInteger acvtCount = ([self.addAcvtArray count] > 0) ? [self.addAcvtArray count] : 0;
  
    if (acvtCount > 0) {
      
        CGFloat buttonWidth;
        buttonWidth = (self.bounds.size.width - 2* BOTTOM_VIEW_LEFT_MARGIN - (acvtCount - 1)*BUTTONS_SPACE)/acvtCount;

        if (INTERFACE_IS_PAD)
        {
            if (acvtCount == 1)
            {
                buttonWidth = 300;
            }
            else
            {
                buttonWidth = (self.bounds.size.width - k_MainkLeftVieWidth - 2* BOTTOM_VIEW_LEFT_MARGIN - (acvtCount - 1)*BUTTONS_SPACE)/acvtCount;
            }
        }
        
        for (NSInteger i = 0; i < acvtCount; i++) {
            WSAcvtBean *acvtBean = self.addAcvtArray[i];
            UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(BOTTOM_VIEW_LEFT_MARGIN + (buttonWidth + BOTTOM_VIEW_LEFT_MARGIN) * i, BUTTON_TOP_MAGIN -1, buttonWidth, K_BOTTOM_VIEW_HEIGHT - BUTTON_TOP_MAGIN * 2);
            button.layer.cornerRadius = 1.0f;
            button.layer.borderWidth = 2.0f;
            button.layer.borderColor =  [[UIColor colorWithRed:241.f/255.f green:240.f/255.f blue:241.f/255.f alpha:1] CGColor];
            button.tag = K_BUTTON_BASE_TAG + i;
            NSString *title = acvtBean.acvtName;
            [button setTitle:title forState:UIControlStateNormal];
            button.titleLabel.font = TitleLabelFont;
            [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            button.imageEdgeInsets = UIEdgeInsetsMake(button.imageView.top, button.imageView.left, button.imageView.bottom, BUTTON_TOP_MAGIN);
            
            [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:acvtBean.acvtIconUrl] imageView:button.imageView  completed:^(UIImage *image, NSError *error, NSURL *imageURL) {
                UIImage * scaleImage = [UIImage scaleToSize:image size:CGSizeMake(15, 15)];
                [button setImage:scaleImage forState:UIControlStateNormal];
            }];
            [button addTarget:self action:@selector(acvtButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
            [_bottomView addSubview:button];
            if ( INTERFACE_IS_PAD && acvtCount == 1)
            {
                button.centerX = (self.bounds.size.width - k_MainkLeftVieWidth)/2;
            }
        }
    }
    else
    {
        LogError(@"addAcvtArray字段为空请查看是否下发对应问卷");
    }
}


-(void)acvtButtonClicked:(UIButton *)button {
    
    if ([_delegate respondsToSelector:@selector(headView:selectedAcvtBean:)]) {
        WSAcvtBean *acvtBean = self.addAcvtArray[button.tag - K_BUTTON_BASE_TAG];
        [_delegate headView:self selectedAcvtBean:acvtBean];
    }
}

- (void)reloadCalendarSubViewIcons:(NSDictionary *)dictionary {
    if ([dictionary allKeys] == 0) {
        NSLog(@"ditionay is nil");
        return;
    }
    [self.calenderView resetDateImageContent:dictionary];
}


#pragma WSCalenderViewDelegate Methods

-(void)wsCalendaView:(WSCalendaView *)calendarView selDateAarray:(NSArray *)dateArray {
    if ([_delegate respondsToSelector:@selector(headView:selectedDates:)]) {
        [_delegate headView:self selectedDates:dateArray];
    }
}

- (void)wsCalendaView:(WSCalendaView *)calendarView changToSize:(CGSize)size {
    CGRect calendarRect = self.calenderView.frame;
    calendarRect.size.height = size.height;
    self.calenderView.frame = calendarRect;
    
}

-(void)wsCalendaView:(WSCalendaView *)calendarView changeToMonth:(NSInteger)month
{
    if ([_delegate respondsToSelector:@selector(headView:changeToMonth:)]) {
        [_delegate headView:self changeToMonth:month];
    }
}

- (void)layoutSubviews {
    
    CGSize originSize = self.frame.size;
    CGFloat y_point = 0;
    y_point += self.calenderView.frame.size.height;
    self.bottomView.frame = CGRectMake(0, y_point, self.bottomView.frame.size.width, self.bottomView.frame.size.height);
    y_point += self.bottomView.frame.size.height;
    self.frame = CGRectMake(self.frame.origin.x, self.origin.y, self.frame.size.width, y_point);
    
    if (y_point != originSize.height) {
        if ([_delegate respondsToSelector:@selector(headView:changeToHeight:)]) {
            [_delegate headView:self changeToHeight:y_point];
        }
    }

}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
