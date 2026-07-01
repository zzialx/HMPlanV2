//
//  WSYearCalenderBottomScrollView.m
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSYearCalenderBottomScrollView.h"
#import "WSMonthBottomView.h"
#import "WSCurrentTime.h"

#define BOTTOM_BG_IAMGE_WIDHT 600.0f //639
#define BOTTOM_BG_IAMGE_HEIGHT 28.0f
#define BOTTOM_BG_IMAGE_STRECHABLE_HEIGHT 4.0f

#define YEAR_LABEL_WIDTH  (BOTTOM_BG_IAMGE_WIDHT/15)

#define TODAY_BUTTON_LEFT_MARGIN 15.0f
#define TODAY_BUTON_WIDHT 79.0f
#define TODAY_BUTTON_HEIGHT 32.0f
#define TODAY_BUTTON_NAV_BUTTON_MARGIN  10.0f

#define NAV_BUTTON_WIDTH 45.0f
#define NAV_BUTTON_HEIGHT 32.0f

#define LEFT_NAV_BUTTON_BOTTOMVIEW_MARGIN 5.0f
#define BOTTOMVIEW_RIGHT_NAV_BUTTON_MARGIN 5.0f

#define YEAR_BASE_TAG 2000

#define MIN_MONTH_INDEX 0
#define MAX_MONTH_INDEX 11


#define MONTH_LABEL_SELECTED_COLOR [UIColor whiteColor]//([UIColor colorWithRed:17.0/255 green:127.0f/255 blue:196.0f/255 alpha:1.0f])
#define YEAR_BUTTON_SELECTED_TITLE_COLOR  MONTH_LABEL_SELECTED_COLOR
 

@interface WSYearCalenderBottomScrollView ()


@property (nonatomic,assign) CGSize size;

@property (nonatomic,strong) UIImageView *calenderBottomBgView;
@property (nonatomic,strong) WSMonthBottomView *monthBottomView;
/*
@property (nonatomic,strong) UILabel *previousYearLabel;
@property (nonatomic,strong) UILabel *currentYearLabel;
@property (nonatomic,strong) UILabel *nextYearLabel;
 */
@property (nonatomic,strong) UIButton *previousYearBtn;
@property (nonatomic,strong) UIButton *currentYearBtn;
@property (nonatomic,strong) UIButton *nextYearBtn;
@property (nonatomic,strong) UIButton *lastClickYearBtn;

@property (nonatomic,strong) UILongPressGestureRecognizer *nextLongPressGestureRecognizer;
@property (nonatomic,strong) UILongPressGestureRecognizer *previousLongPressGestureRecognizer;
@property (nonatomic,strong) NSTimer *nextLongPressTimer;
@property (nonatomic,strong) NSTimer *previousLongPressTimer;

@property (nonatomic,assign) NSInteger bottomViewSelectedIndex;

@end

@implementation WSYearCalenderBottomScrollView


- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // to do something
        _size = frame.size;
        [self initView];
    }
    return self;
}


- (void)initView {
    [self initTodayButton];
    [self initNavButtons];
    [self initContentView];
}

/*
 当前时间按钮
 */

- (void)initTodayButton {
    UIButton *todayButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [todayButton setFrame:CGRectMake(TODAY_BUTTON_LEFT_MARGIN, (_size.height - TODAY_BUTTON_HEIGHT)/2, TODAY_BUTON_WIDHT, TODAY_BUTTON_HEIGHT)];
    [todayButton setBackgroundImage:[UIImage imageForName:@"calender_today_btn"] forState:UIControlStateNormal];
    [todayButton setTitle:NSLocalizedString(@"今天", nil) forState:UIControlStateNormal];
    
    [todayButton addTarget:self action:@selector(todayButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:todayButton];
}

/*
 导航上一月 下一月按钮
 */
- (void)initNavButtons{
    CGFloat previous_x = TODAY_BUTTON_LEFT_MARGIN + TODAY_BUTON_WIDHT + TODAY_BUTTON_NAV_BUTTON_MARGIN;
    UIButton *previousMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [previousMonthButton addTarget: self action:@selector(previousButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [previousMonthButton setFrame:CGRectMake(previous_x, (_size.height - NAV_BUTTON_HEIGHT)/2, NAV_BUTTON_WIDTH, NAV_BUTTON_HEIGHT)];
    [previousMonthButton setImage:[UIImage imageForName:@"calendar_left_btn.png"] forState:UIControlStateNormal];
    [self addSubview:previousMonthButton];
    /*
     添加长按手势
     */
    _previousLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                       initWithTarget:self
                                       action:@selector(handleLongPressGestures:)];
    _previousLongPressGestureRecognizer.numberOfTouchesRequired = 1;
    [previousMonthButton addGestureRecognizer:_previousLongPressGestureRecognizer];
    
    
    CGFloat next_x = TODAY_BUTTON_LEFT_MARGIN + TODAY_BUTON_WIDHT + TODAY_BUTTON_NAV_BUTTON_MARGIN + NAV_BUTTON_WIDTH + LEFT_NAV_BUTTON_BOTTOMVIEW_MARGIN + BOTTOM_BG_IAMGE_WIDHT + BOTTOMVIEW_RIGHT_NAV_BUTTON_MARGIN;
    UIButton *nextMonthButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [nextMonthButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [nextMonthButton setFrame:CGRectMake(next_x,(_size.height - NAV_BUTTON_HEIGHT)/2, NAV_BUTTON_WIDTH, NAV_BUTTON_HEIGHT)];
    [nextMonthButton setImage:[UIImage imageForName:@"calendar_right_btn.png"] forState:UIControlStateNormal];
    [nextMonthButton addTarget:self action:@selector(nextButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:nextMonthButton];
    /*
     添加长按手势
     */
    _nextLongPressGestureRecognizer = [[UILongPressGestureRecognizer alloc]
                                                                initWithTarget:self
                                                                action:@selector(handleLongPressGestures:)];
    _nextLongPressGestureRecognizer.numberOfTouchesRequired = 1;
    [nextMonthButton addGestureRecognizer:_nextLongPressGestureRecognizer];
}






/*
 当前年 去年，下年 及月份视图
 */
- (void)initContentView {
    CGFloat x = TODAY_BUTTON_LEFT_MARGIN + TODAY_BUTON_WIDHT + TODAY_BUTTON_NAV_BUTTON_MARGIN + NAV_BUTTON_WIDTH + LEFT_NAV_BUTTON_BOTTOMVIEW_MARGIN;
    
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectMake(x,(_size.height - (BOTTOM_BG_IAMGE_HEIGHT + BOTTOM_BG_IMAGE_STRECHABLE_HEIGHT))/2,BOTTOM_BG_IAMGE_WIDHT,BOTTOM_BG_IAMGE_HEIGHT + BOTTOM_BG_IMAGE_STRECHABLE_HEIGHT)];
    [self addSubview:contentView];
    
    _calenderBottomBgView = [[UIImageView alloc] init];
    UIImage *bgImage = [UIImage imageNamed:@"calender_year_bottom_bg.png"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:floorf(bgImage.size.width/2) topCapHeight:floorf(bgImage.size.height/2)];
    [_calenderBottomBgView setImage:bgImage];
    [_calenderBottomBgView setFrame:CGRectMake(0, 0, BOTTOM_BG_IAMGE_WIDHT, BOTTOM_BG_IAMGE_HEIGHT + BOTTOM_BG_IMAGE_STRECHABLE_HEIGHT)];
    [contentView addSubview:_calenderBottomBgView];
    
    
    CGFloat button_y = BOTTOM_BG_IMAGE_STRECHABLE_HEIGHT /2;
    NSInteger currentYear = [[WSCurrentTime getYearString] integerValue];
    _previousYearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_previousYearBtn setFrame:CGRectMake(0, button_y, YEAR_LABEL_WIDTH, BOTTOM_BG_IAMGE_HEIGHT )];
    [_previousYearBtn addTarget:self action:@selector(yearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_previousYearBtn setTitle:[NSString stringWithFormat:@"%ld",(long)currentYear - 1] forState:UIControlStateNormal];
    [_previousYearBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_previousYearBtn setBackgroundImage:[UIImage imageNamed:@"caleder_year_select.png"] forState:UIControlStateHighlighted];
    [_previousYearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_previousYearBtn setTitleColor:YEAR_BUTTON_SELECTED_TITLE_COLOR forState:UIControlStateHighlighted];
    _previousYearBtn.contentMode =  UIViewContentModeBottom;
    _previousYearBtn.tag = YEAR_BASE_TAG;
    [contentView addSubview:_previousYearBtn];
    
    _currentYearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_currentYearBtn setFrame:CGRectMake(YEAR_LABEL_WIDTH, button_y, YEAR_LABEL_WIDTH, BOTTOM_BG_IAMGE_HEIGHT )];
    [_currentYearBtn addTarget:self action:@selector(yearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_currentYearBtn setTitle:[NSString stringWithFormat:@"%ld",(long)currentYear] forState:UIControlStateNormal];
    [_currentYearBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_currentYearBtn setBackgroundImage:[UIImage imageNamed:@"caleder_year_select.png"] forState:UIControlStateSelected];
    [_currentYearBtn setBackgroundImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [_currentYearBtn setContentMode:UIViewContentModeCenter];
    [_currentYearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_currentYearBtn setTitleColor:YEAR_BUTTON_SELECTED_TITLE_COLOR forState:UIControlStateSelected];
    [_currentYearBtn setSelected:YES];
    _currentYearBtn.contentMode =  UIViewContentModeCenter;
    _currentYearBtn.tag = YEAR_BASE_TAG + 1;
    [contentView addSubview:_currentYearBtn];

    
    
    NSDateComponents *today = [WSCurrentTime YMDComponents];
    NSInteger month = today.month;
    CGFloat bottomView_y = button_y;
    _monthBottomView = [[WSMonthBottomView alloc] initWithFrame:CGRectMake(2*YEAR_LABEL_WIDTH, bottomView_y, 12*YEAR_LABEL_WIDTH, BOTTOM_BG_IAMGE_HEIGHT) index:month - 1];
    _monthBottomView.delegate = self;
    [contentView addSubview:_monthBottomView];
    
     _nextYearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextYearBtn setFrame:CGRectMake(14*YEAR_LABEL_WIDTH, button_y, YEAR_LABEL_WIDTH, BOTTOM_BG_IAMGE_HEIGHT)];
    [_nextYearBtn addTarget:self action:@selector(yearButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [_nextYearBtn setTitle:[NSString stringWithFormat:@"%ld",(long)currentYear + 1] forState:UIControlStateNormal];
    [_nextYearBtn.titleLabel setFont:[UIFont systemFontOfSize:12.0f]];
    [_nextYearBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextYearBtn setTitleColor:YEAR_BUTTON_SELECTED_TITLE_COLOR forState:UIControlStateHighlighted];
    [_nextYearBtn setBackgroundImage:[UIImage imageNamed:@"caleder_year_select.png"] forState:UIControlStateHighlighted];
    _nextYearBtn.contentMode =  UIViewContentModeCenter;
    _nextYearBtn.tag = YEAR_BASE_TAG + 2;
    [contentView addSubview:_nextYearBtn];

}



/*
 年减少
 */
- (void)changYearButtonsToPresious {
    
    NSString *changedPresious = [self presiousYearWith: self.previousYearBtn.currentTitle];
    [self.previousYearBtn setTitle:changedPresious forState: UIControlStateNormal];
    [self.previousYearBtn  setSelected:NO];
    
    NSString *changeCurrent = [self presiousYearWith:self.currentYearBtn.currentTitle];
    [self.currentYearBtn setTitle:changeCurrent forState:UIControlStateNormal];
    [self.currentYearBtn setSelected:YES];
    
    NSString *changeNext = [self presiousYearWith:self.nextYearBtn.currentTitle];
    [self.nextYearBtn setTitle:changeNext forState:UIControlStateNormal];
    [self.nextYearBtn setSelected:NO];

}

/*
 年增加
 */

- (void)changYearButtonsToNext {
    
    NSString *changedPresious = [self nextYearWith:self.previousYearBtn.currentTitle];
    [self.previousYearBtn setTitle:changedPresious forState: UIControlStateNormal];
    [self.previousYearBtn setSelected:NO];
    
    NSString *changeCurrent = [self nextYearWith:self.currentYearBtn.currentTitle];
    [self.currentYearBtn setTitle:changeCurrent forState:UIControlStateNormal];
    [self.currentYearBtn setSelected:YES];
    
    NSString *changeNext = [self nextYearWith:self.nextYearBtn.currentTitle];
    [self.nextYearBtn setTitle:changeNext forState:UIControlStateNormal];
    [self.nextYearBtn setSelected:NO];

    
}

- (NSString *)presiousYearWith:(NSString *)year {
    NSInteger yearInteger =  [year integerValue];
    return [NSString stringWithFormat:@"%ld",(long)(yearInteger - 1)];
}

- (NSString *)nextYearWith:(NSString *)year {
    NSInteger yearInteger = [year integerValue];
    return [NSString stringWithFormat:@"%ld",(long)(yearInteger + 1)];
}


#pragma mark Year Button Click Methods
- (void)yearButtonClick:(id)sender {
    if (sender) {
        UIButton *clickBtn = (UIButton *)sender;
        clickBtn.selected = !clickBtn.selected;
        switch (clickBtn.tag - YEAR_BASE_TAG) {
            case 0:
            {
                [self changYearButtonsToPresious];
                [self.monthBottomView didSelectedIndex:MAX_MONTH_INDEX];
                [self delegateForSuperView];
            }
                break;
            case 1:
            {
                
            }
                break;
            case 2:
            {
                [self changYearButtonsToNext];
                [self.monthBottomView didSelectedIndex:MIN_MONTH_INDEX];
                [self delegateForSuperView];
            }
                break;
                
            default:
                break;
        }
        _lastClickYearBtn = clickBtn;
    }
}


#pragma mark Nav Button Click Methods

- (void)previousButtonClick:(id)sender {
    if (self.monthBottomView) {
        NSInteger tmpMonthSelectedIndex = self.monthBottomView.selectedIndex;
        if ( tmpMonthSelectedIndex > MIN_MONTH_INDEX) {
            [self.monthBottomView didSelectedIndex:tmpMonthSelectedIndex -1];
        } else if (tmpMonthSelectedIndex == MIN_MONTH_INDEX) {
            [self.monthBottomView didSelectedIndex:MAX_MONTH_INDEX];
            [self changYearButtonsToPresious];
        }
        [self delegateForSuperView];
    }
}

- (void)nextButtonClick:(id)sender {
    NSLog(@"nextButtonClick");
    if (self.monthBottomView) {
        
        NSInteger tmpMonthSelectedIndex = self.monthBottomView.selectedIndex;
        if ( tmpMonthSelectedIndex < MAX_MONTH_INDEX) {
            [self.monthBottomView didSelectedIndex:tmpMonthSelectedIndex + 1];
        } else if (tmpMonthSelectedIndex == MAX_MONTH_INDEX) {
            [self.monthBottomView didSelectedIndex:MIN_MONTH_INDEX];
            [self changYearButtonsToNext];
        }
        [self delegateForSuperView];
    }
}

/*
 点击今天按钮触发事件
 */

- (void)todayButtonClick:(id)sender {
    NSDateComponents *currentComponents = [WSCurrentTime YMDComponents];
    NSInteger currentYearInteger =currentComponents.year;
    NSString *currentYear = [NSString stringWithFormat:@"%ld",(long)currentYearInteger];
    NSInteger  currentMonthInteger =currentComponents.month;
    
    [self.currentYearBtn setTitle:currentYear forState:UIControlStateNormal];
    [self.previousYearBtn setTitle:[NSString stringWithFormat:@"%ld",(long)currentYearInteger - 1] forState:UIControlStateNormal];
    [self.nextYearBtn setTitle:[NSString stringWithFormat:@"%ld",(long)currentYearInteger + 1] forState:UIControlStateNormal];
    [self.monthBottomView didSelectedIndex:currentMonthInteger - 1];
    [self delegateForSuperView];
}


#pragma mark UILongPressGestureRecognizer Methods

- (void) handleLongPressGestures:(UILongPressGestureRecognizer *)paramSender{
    if ([paramSender isEqual:self.nextLongPressGestureRecognizer]){
        if (paramSender.state == UIGestureRecognizerStateBegan) {
            if (paramSender.numberOfTouchesRequired == 1){
                self.nextLongPressTimer =[NSTimer  scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(nextButtonClick:) userInfo:nil repeats:YES];
            }
        }
        if (paramSender.state == UIGestureRecognizerStateEnded) {
            if ([self.nextLongPressTimer isValid]) {
                [self.nextLongPressTimer invalidate];
                self.nextLongPressTimer = nil;
            }
        }
        
    } else if ([paramSender isEqual:self.previousLongPressGestureRecognizer]) {
        if (paramSender.state == UIGestureRecognizerStateBegan) {
            if (paramSender.numberOfTouchesRequired == 1){
                self.previousLongPressTimer  =[NSTimer  scheduledTimerWithTimeInterval:0.2f target:self selector:@selector(previousButtonClick:) userInfo:nil repeats:YES];
            }
        }
        if (paramSender.state == UIGestureRecognizerStateEnded) {
            if ([self.previousLongPressTimer isValid]) {
                [self.previousLongPressTimer invalidate];
                self.previousLongPressTimer = nil;
            }
        }
    }
    [self delegateForSuperView];
}

#pragma mark WSMonthBottomViewDelegate Methods

- (void)monthBottomView:(WSMonthBottomView *)monthBottomView didSelectedIndex:(NSInteger)index {
    if (index < MAX_MONTH_INDEX + 1) {
        [self delegateForSuperView];
    }
}

/*
 对外数据接口
 */
- (void)delegateForSuperView {
    if ([_delegate respondsToSelector:@selector(yearCalenderBottomScrollView:selectedYear:month:)]) {
        NSString *selectedYear = self.currentYearBtn.currentTitle;
        NSString *selectedMonth = [NSString stringWithFormat:@"%ld",(long)self.monthBottomView.selectedIndex + 1];
        [_delegate yearCalenderBottomScrollView:self selectedYear:selectedYear month:selectedMonth];
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
