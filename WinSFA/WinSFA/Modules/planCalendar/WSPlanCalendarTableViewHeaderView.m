//
//  WSPlanCalendarTableViewHeaderView.m
//  WinSFA
//
//  Created by 董宏 on 2020/4/27.
//  Copyright © 2020 WinChannel. All rights reserved.
//

#import "WSPlanCalendarTableViewHeaderView.h"

static CGFloat const kPlanCalendarViewHeaderViewOffset = 10;

@interface WSPlanCalendarTableViewHeaderView ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIView *linView;

@end

@implementation WSPlanCalendarTableViewHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self addControls];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self addControls];
    }
    return self;
}

#pragma mark - Controls
- (void)addControls {
    
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:15];
    titleLabel.textColor = [UIColor blackColor];
    titleLabel.text =  @"拜访计划：";
    self.titleLabel = titleLabel;
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor colorWithHexString:@"c4c4c4"];
    [self.contentView addSubview:titleLabel];
    [self.contentView addSubview:view];
    self.linView = view;
    
    [self.contentView addSubview:self.setAttendanceBtn];
    self.setAttendanceBtn.hidden = YES;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    [self layoutControls];
}

- (void)layoutControls {
    
    CGFloat viewWidth = self.bounds.size.width;
    CGFloat viewHeight = self.bounds.size.height;
    CGFloat offsetX = kPlanCalendarViewHeaderViewOffset;
    CGFloat offsetY = 0;
    
    self.titleLabel.frame = CGRectMake(offsetX, offsetY , viewWidth  - offsetX , viewHeight);
    self.linView.frame = CGRectMake(0, viewHeight - 1, viewWidth, 1);
    self.setAttendanceBtn.frame = CGRectMake(viewWidth - kPlanCalendarViewHeaderViewOffset - 50, (viewHeight-25)/2, 50, 25);
}

- (UIButton *)setAttendanceBtn {
    
    if (!_setAttendanceBtn) {
        
        _setAttendanceBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_setAttendanceBtn setTitle:@"设置" forState:UIControlStateNormal];
        _setAttendanceBtn.backgroundColor = [UIColor colorWithHexString:@"#31EA00"];
        [_setAttendanceBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _setAttendanceBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [_setAttendanceBtn addTarget:self action:@selector(attendanceAction) forControlEvents:UIControlEventTouchUpInside];
        _setAttendanceBtn.layer.cornerRadius = 4.0;
        _setAttendanceBtn.layer.borderColor = [UIColor clearColor].CGColor;
        _setAttendanceBtn.layer.borderWidth = 1.0f;
        //_setAttendanceBtn.hidden = YES;
    }
    return _setAttendanceBtn;
}

- (void)attendanceAction {
    
    if (self.jumpAttendanceVC) {
        self.jumpAttendanceVC();
    }
}

- (void)setWithTitle:(NSString *)title {
    
    self.titleLabel.text = title;
}

- (void)setAttendanceWithIsValidState:(BOOL)isValidState {
    
    self.setAttendanceBtn.hidden = NO;
    if (isValidState) {
        
        self.setAttendanceBtn.backgroundColor = [UIColor colorWithHexString:@"#31EA00"];
        self.setAttendanceBtn.userInteractionEnabled = YES;
    }
    else {
        
        self.setAttendanceBtn.backgroundColor = [UIColor colorWithHexString:@"#C0C0C0"];
        self.setAttendanceBtn.userInteractionEnabled = NO;
    }
}

@end

