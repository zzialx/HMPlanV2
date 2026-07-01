//
//  WSMonthCollectionViewCell.m
//  WinSFA
//
//  Created by heju on 15/4/16.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMonthCollectionViewCell.h"
#import "WSMonthCollectionViewCellModel.h"

#define MONTH_CELL_COLOR_THEME1 [UIColor colorWithHexString:@"#272727"]//([UIColor redColor])//大红色
#define MONTH_CELL_COLOR_THEME [UIColor colorWithHexString:@"#272727"]//([UIColor colorWithRed:26/256.0  green:168/256.0 blue:186/256.0 alpha:1])
#define MONTH_CELL_BORDER_COLOR [UIColor colorWithRed:219.0f/255 green:220.0f/255 blue:221.0f/255 alpha:1.0f]
#define MONTH_STROLE_COLOR  [UIColor colorWithHexString:@"#d8d8d8"]//[UIColor colorWithRed:219.0f/255 green:219.0f/255 blue:219.0f/255 alpha:1.0f]

#define WEEKEND_BG_COLOR [UIColor colorWithHexString:@"#faf9f9"]

#define DUTY_CHAR_MAX 6
#define DUTY_CHAR_MIN_FONT 9.0f
#define DUTY_CHAR_NORMAL_FONT 12.0f

#define DUTY_LABEL_VERTICAL_GAP 10.0f
#define DUTY_LABEL_HORIZONTAL_GAP 2.0f
#define DUTY_LABEL_BOTTOM_SPACE 10.0f
#define DUTY_LABEL_LEFT_SPACE 20.0f



@interface WSMonthCollectionViewCell () {
}

@property (nonatomic, strong) WSCollectionCellMarkView *markView;
@property (nonatomic, strong) UILabel *dayLabel;
@property (nonatomic, strong) UILabel *forenoon;
@property (nonatomic, strong) UILabel *dutyforenoon;
@property (nonatomic, strong) UILabel *afternoon;
@property (nonatomic, strong) UILabel *dutyafternoon;
@property (nonatomic, strong) UILabel *allDay;
@property (nonatomic, strong) UILabel *dutyAllDay;
@property (nonatomic, strong) UIImageView *todayBGView;
@property (nonatomic, strong) UIImageView *pointViewForenoon;
@property (nonatomic, strong) UIImageView *pointViewAfternoon;
@property (nonatomic, strong) UILabel *rateLabel;

@end

@implementation WSMonthCollectionViewCell


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor whiteColor];
        [self initData];
        [self initView];
    }
    return self;
}

- (void)initData  {
    _model = [[WSMonthCollectionViewCellModel alloc] init];
}

- (void)createMarkViewWithFrame:(CGRect )rect type:(MarkViewType )type  {
    _markView = [[WSCollectionCellMarkView alloc] initWithFrame:rect  markStyle:type];
    [self addSubview:_markView];
}

- (void)initView {
    //日期
    _dayLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.bounds.size.width/2 - 10, 10, self.bounds.size.width/2, 20 )];
    _dayLabel.textAlignment = NSTextAlignmentRight;
    _dayLabel.font = [UIFont systemFontOfSize:16.0f];
    _dayLabel.backgroundColor = [UIColor clearColor];
    _dayLabel.textColor = [UIColor colorWithHexString:@"#272727"];
    [self addSubview:_dayLabel];
}

/*
 初始化考勤的视图
 */
- (void)initDutyAttendanceViews {
    
    UIImage *pointImage = [UIImage imageNamed:@"point_icon"];
    _pointViewForenoon = [[UIImageView alloc] initWithImage:pointImage];
    [self addSubview:_pointViewForenoon];
    _pointViewForenoon.hidden = YES;
    _pointViewAfternoon = [[UIImageView alloc] initWithImage:pointImage];
    [self addSubview:_pointViewAfternoon];
    _pointViewAfternoon.hidden = YES;
    
    
    _forenoon = [[UILabel alloc] initWithFrame:CGRectZero];
    _forenoon.backgroundColor = [UIColor clearColor];
    _forenoon.textAlignment = NSTextAlignmentLeft;
    _forenoon.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _forenoon.textColor = [UIColor blackColor];
    [self addSubview:_forenoon];
    
    _dutyforenoon = [[UILabel alloc] initWithFrame:CGRectZero];
    _dutyforenoon.backgroundColor = [UIColor clearColor];
    _dutyforenoon.textAlignment = NSTextAlignmentLeft;
    _dutyforenoon.font = [UIFont boldSystemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _dutyforenoon.textColor = [UIColor blackColor];
    _dutyforenoon.numberOfLines = 0;
    _dutyforenoon.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:_dutyforenoon];
    
    
    _afternoon = [[UILabel alloc] initWithFrame:CGRectZero];
    _afternoon.backgroundColor = [UIColor clearColor];
    _afternoon.textAlignment = NSTextAlignmentLeft;
    _afternoon.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _afternoon.textColor = [UIColor blackColor];
    [self addSubview:_afternoon];
    
    _dutyafternoon = [[UILabel alloc] initWithFrame:CGRectZero];
    _dutyafternoon.backgroundColor = [UIColor clearColor];
    _dutyafternoon.textAlignment = NSTextAlignmentLeft;
    _dutyafternoon.font = [UIFont boldSystemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _dutyafternoon.textColor = [UIColor blackColor];
    _dutyafternoon.numberOfLines = 0;
    _dutyafternoon.lineBreakMode = NSLineBreakByCharWrapping;
    [self addSubview:_dutyafternoon];
    
    // SFA-16095 添加
    _rateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _rateLabel.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    [self addSubview:_rateLabel];
}



- (void)setModel:(WSMonthCollectionViewCellModel *)model
{

    self.backgroundColor = [UIColor whiteColor];
    [self removeSubViews];
    switch (model.style) {
        case MonthCellDayTypeEmpty://不显示
            [self hidden_YES];
            break;
            
        case MonthCellDayTypePast://过去的日期
            [self hidden_NO];
            
            if (model.holiday) {
                _dayLabel.text = model.holiday;
                _dayLabel.textColor = [UIColor orangeColor];
            }else{
                _dayLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
                _dayLabel.textColor = [UIColor lightGrayColor];
            }
            break;
            
        case MonthCellDayTypeFutur://将来的日期
            [self hidden_NO];
            
            if (model.holiday) {
                _dayLabel.text = model.holiday;
                _dayLabel.textColor = [UIColor orangeColor];
            }else{
                _dayLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
                _dayLabel.textColor = MONTH_CELL_COLOR_THEME;
            }
            break;
            
        case MonthCellDayTypeWeek://周末
            [self hidden_NO];
            
            if (model.holiday) {
                _dayLabel.text = model.holiday;
                _dayLabel.textColor = [UIColor orangeColor];
            }else{
                _dayLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
                _dayLabel.textColor = MONTH_CELL_COLOR_THEME1;
            }
            
            self.backgroundColor = WEEKEND_BG_COLOR;
            
            break;
            
        case MonthCellDayTypeClick://被 开始计算的起始日期
            [self hidden_NO];
            
            if (model.holiday) {
                _dayLabel.text = model.holiday;
                _dayLabel.textColor = [UIColor orangeColor];
            }else{
                _dayLabel.text = [NSString stringWithFormat:@"%lu",(unsigned long)model.day];
                _dayLabel.textColor = MONTH_CELL_COLOR_THEME;
            }
            break;
            
        default:
            
            break;
    }
    
    
    NSDateComponents *currentComponents = [WSCurrentTime YMDComponents];
    NSInteger currentYearInteger = currentComponents.year;
    NSInteger currentMonthInteger = currentComponents.month;
    NSInteger currentDayInteger = currentComponents.day;
    if (!model.holiday && currentDayInteger == model.day && currentMonthInteger == model.month && currentYearInteger == model.year) {
        self.todayBGView = [[UIImageView alloc] initWithImage:[UIImage imageForName:@"today_bj"]];
        CGPoint center = CGPointMake(self.dayLabel.right - self.todayBGView.width/2 + 5, self.dayLabel.center.y);
        self.todayBGView.center = center;
        [self addSubview:self.todayBGView];
        [self bringSubviewToFront:self.dayLabel];
        self.dayLabel.textColor = [UIColor whiteColor];
    }else {
        self.dayLabel.textColor = MONTH_CELL_COLOR_THEME;
    }
    
    [self initDutyAttendanceViews];
    [self setDutyDataWith:model.dutyBean];
}


- (void)setDutyDataWith:(WSDutyBean *)dutybean {
    NSString *col3 = dutybean.col3;
    NSString *col4 = dutybean.col4;
    BOOL isCol3  = (col3 && [col3 isEqualToString:@"1"]);// 上午考勤有值
    BOOL isCol4 = (col4 && [col4 isEqualToString:@"1"]);// 下午考勤有值
    
    NSString *titleForenoon = [NSString stringWithFormat:@"%@：",NSLocalizedString(@"上午", nil)];
    NSString *titleAfternoon = [NSString stringWithFormat:@"%@：",NSLocalizedString(@"下午", nil)];
    
    CGSize titleForeSize = [titleForenoon ws_sizeWithFont:_forenoon.font constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
    CGSize titleAfterSize = [titleAfternoon ws_sizeWithFont:_afternoon.font constrainedToWidth:CGFLOAT_MAX lineBreakMode:NSLineBreakByCharWrapping];
    
    
    CGFloat titleForeWidth = titleForeSize.width;
    CGFloat titleAfterWidth = titleAfterSize.width;
    
    CGFloat titleHeight = titleAfterSize.height;
    
    CGFloat leftPadding = 10;
    if ([dutybean.rate length] > 0) {
        [self.rateLabel setText:dutybean.rate];
        if ([dutybean.rateColor length] > 0) {
            [self.rateLabel setTextColor:[UIColor colorFromHexCode:dutybean.rateColor]];
        } else {
            [self.rateLabel setTextColor:MONTH_CELL_COLOR_THEME];
        }
        CGFloat rateHeight = 24;
        self.rateLabel.frame = CGRectMake(leftPadding, self.height - titleHeight * 2 - DUTY_LABEL_BOTTOM_SPACE - DUTY_LABEL_VERTICAL_GAP - rateHeight, self.width - leftPadding * 2, rateHeight);
        [self.rateLabel setHidden:NO];
    } else {
        [self.rateLabel setHidden:YES];
    }
    
    
    if (isCol3) {
        [_forenoon setFrame:CGRectMake(DUTY_LABEL_LEFT_SPACE, self.height - titleHeight * 2 - DUTY_LABEL_BOTTOM_SPACE - DUTY_LABEL_VERTICAL_GAP, titleForeWidth, titleHeight)];
        _forenoon.text = titleForenoon;
        [self bringSubviewToFront:_forenoon];
        
        if (dutybean.morning &&[dutybean.morning length] >= DUTY_CHAR_MAX) {
            _dutyforenoon.font = [UIFont systemFontOfSize:DUTY_CHAR_MIN_FONT];
        }
        
        [_dutyforenoon setFrame:CGRectMake(_forenoon.right + DUTY_LABEL_HORIZONTAL_GAP, _forenoon.origin.y, self.width - _forenoon.right, titleHeight)];
        _dutyforenoon.text =  dutybean.morning;
        [self bringSubviewToFront:_dutyforenoon];
        
        
        self.pointViewForenoon.hidden = NO;
        self.pointViewForenoon.frame = CGRectMake(leftPadding, _forenoon.top + (_forenoon.height - _pointViewForenoon.height)/2, _pointViewForenoon.width, _pointViewForenoon.height);
    }
    
    if (isCol4) {
        if (dutybean.morning &&[dutybean.morning length] >= DUTY_CHAR_MAX) {
            _dutyafternoon.font = [UIFont systemFontOfSize:DUTY_CHAR_MIN_FONT];
        }
        [_afternoon setFrame:CGRectMake(DUTY_LABEL_LEFT_SPACE, self.height - titleHeight - DUTY_LABEL_BOTTOM_SPACE, titleAfterWidth, titleHeight)];
        _afternoon.text = titleAfternoon;
        [self bringSubviewToFront:_afternoon];
        
        [_dutyafternoon setFrame:CGRectMake(_afternoon.right + DUTY_LABEL_HORIZONTAL_GAP, _afternoon.origin.y,self.width - titleAfterWidth, titleHeight)];
        _dutyafternoon.text = dutybean.afternoon;
        [self bringSubviewToFront:_dutyafternoon];
        
        self.pointViewAfternoon.hidden = NO;
        self.pointViewAfternoon.frame = CGRectMake(leftPadding, _afternoon.top + (_afternoon.height - _pointViewForenoon.height)/2, _pointViewForenoon.width, _pointViewForenoon.height);
    }
    
    if (isCol3 || isCol4) {
        [self createMarkViewWithFrame:CGRectMake(0, 0,self.width, 5) type:MarkViewTrangleType];
    }

}

- (void)removeSubViews {
    for (UIView *subView in self.subviews) {
        if ([subView isKindOfClass:[UIView class]] && subView != _dayLabel) {
            [subView removeFromSuperview];
        }
    }
}

/*
 - (void)resetLabelFonts {
    _forenoon.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _dutyforenoon.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _afternoon.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _dutyafternoon.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _allDay.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
    _dutyAllDay.font = [UIFont systemFontOfSize:DUTY_CHAR_NORMAL_FONT];
}
 */

- (void)hidden_YES{
    _dayLabel.hidden = YES;
}


- (void)hidden_NO{
    _dayLabel.hidden = NO;
}


/*
 绘制item的边框
 */
- (void)drawRect:(CGRect)rect {
    CGContextRef  contextRef = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(contextRef, [MONTH_STROLE_COLOR CGColor]);
    CGContextSetLineWidth(contextRef, 1.0f);
    
    CGPoint pointRightUp = CGPointMake(self.bounds.size.width, 0);
    CGPoint pointLeftUp = CGPointMake(0, 0);
    CGPoint pointLeftDown = CGPointMake(0,self.bounds.size.height );
    CGPoint pointRightDown = CGPointMake(self.bounds.size.width , self.bounds.size.height);
    CGPoint points[] = {pointRightUp,pointLeftUp,pointLeftDown,pointRightDown};
    CGContextAddLines(contextRef, points, 4);
    
    CGContextClosePath(contextRef);
    CGContextStrokePath(contextRef);
}

@end
