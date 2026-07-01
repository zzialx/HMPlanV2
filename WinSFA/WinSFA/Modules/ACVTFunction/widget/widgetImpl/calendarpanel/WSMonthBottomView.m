//
//  WSMonthBottomView.m
//  WinSFA
//
//  Created by heju on 15/4/24.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSMonthBottomView.h"

#define MONTH_COUNT 12
#define MONTH_LABEL_SELECTED_COLOR ([UIColor colorWithRed:17.0/255 green:127.0f/255 blue:196.0f/255 alpha:1.0f])


@interface WSMonthBottomView ()

@property (nonatomic, strong) NSMutableArray *monthLabelTitles;
@property (nonatomic, strong) NSMutableArray *monthLabels;
@property (nonatomic, assign) CGSize size;

@property (nonatomic,assign) CGFloat labelWidth;
@property (nonatomic,assign) CGFloat labelHeight;
@property (nonatomic,assign) CGFloat bgImageWidth;
@property (nonatomic,assign) CGFloat bgImageHeight;
@property (nonatomic,strong) UILabel *lastClickLabel;
@end

@implementation WSMonthBottomView


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // to do something
    }
    return self;
}


- (id)initWithFrame:(CGRect)frame index:(NSInteger)selectedIndex {
    self = [super initWithFrame:frame];
    if (self) {
        // to do something
        _size = frame.size;
        _selectedIndex = selectedIndex;
        [self initMonthLabelDatas];
        [self initSelectedBgImageView];
        [self initMonthLables];
        [self didSelectedIndex:selectedIndex];
        
    }
    return self;
}

- (void)initMonthLabelDatas {
    if (_monthLabelTitles ==  nil) {
        _monthLabelTitles = [[NSMutableArray alloc] init];
        for (NSInteger i = 0; i < MONTH_COUNT; i++) {
            NSString *monthString = [NSString stringWithFormat:@"%ld",(long)(i+1)];
            [_monthLabelTitles addObject:monthString];
        }
    }
    _labelWidth = _size.width/[_monthLabelTitles count];
    _labelHeight = _size.height;
}

- (void)initSelectedBgImageView {
    _bgImageWidth = 28.0f; //_labelWidth*4/5;
    _bgImageHeight = 28.0f; //_labelHeight*4/5;
    
//    CGFloat bgImage_x = self.selectedIndex *_labelWidth + (_labelWidth - _bgImageWidth)/2;
//    CGFloat bgImage_y = (_labelHeight - _bgImageHeight)/2;
    _selectedBgImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _bgImageWidth, _bgImageHeight)];
    [_selectedBgImageView setImage:[UIImage imageNamed:@"caleder_month_select.png"]];
    [self addSubview:self.selectedBgImageView];
}

- (void)initMonthLables {

    _monthLabels = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i< [_monthLabelTitles count]; i++) {
        UILabel *monthLabel = [[UILabel alloc] initWithFrame:CGRectMake(_labelWidth * i, 0, _labelWidth, _labelHeight)];
        monthLabel.textAlignment =NSTextAlignmentCenter;
        monthLabel.backgroundColor = [UIColor clearColor];
        monthLabel.font = [UIFont systemFontOfSize:12.0f];
        monthLabel.textColor = [UIColor whiteColor];
        monthLabel.contentMode = UIViewContentModeCenter;
        monthLabel.text = [_monthLabelTitles objectAtIndex:i];
        [self addSubview:monthLabel];
        [_monthLabels addObject:monthLabel];
    }
}

- (void)didSelectedIndex:(NSInteger)index {
    [self changLastClickLabelColor];
    self.selectedIndex = index;
    [self setCurrentClickLabelColorWith:index];
    [self setBgImageViewFrameWith:index];
    if ([_monthLabels count] > self.selectedIndex) {
         _lastClickLabel = [_monthLabels objectAtIndex:self.selectedIndex];
    }
   
}

- (void)setBgImageViewFrameWith:(NSInteger)selectedIndex {
    CGFloat bgImage_x = self.selectedIndex *_labelWidth + (_labelWidth - _bgImageWidth)/2;
    CGFloat bgImage_y = (_labelHeight - _bgImageHeight)/2;
    [self.selectedBgImageView setFrame:CGRectMake(bgImage_x, bgImage_y, _bgImageWidth, _bgImageHeight)];
    
    
}

- (void)changLastClickLabelColor {
    if (_lastClickLabel) {
        [_lastClickLabel setTextColor:[UIColor whiteColor]];
    }
}

- (void)setCurrentClickLabelColorWith:(NSInteger )index {
    UILabel *currentClickLabel = [_monthLabels objectAtIndex:index];
    [currentClickLabel setTextColor:MONTH_LABEL_SELECTED_COLOR];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (touch.view == self && touchPoint.x >= 0 && touchPoint.x < self.width) {
        
        [self changLastClickLabelColor];
        
       
        NSInteger index = (int)(touchPoint.x/_labelWidth);
        self.selectedIndex = index;
        
        [self setCurrentClickLabelColorWith:index];
        
        if (_selectedBgImageView) {
            [self setBgImageViewFrameWith:index];
        }
        
        _lastClickLabel = [_monthLabels objectAtIndex:self.selectedIndex];
        
        if ( [_delegate respondsToSelector:@selector(monthBottomView:didSelectedIndex:)]) {
            [_delegate monthBottomView:self didSelectedIndex:self.selectedIndex];
        }
        
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (touch.view == self && touchPoint.x < self.width && touchPoint.x >= 0) {
        
        [self changLastClickLabelColor];
        
        
        NSInteger index = (int)(touchPoint.x/_labelWidth);
        self.selectedIndex = index;
        
        [self setCurrentClickLabelColorWith:index];
        
        if (_selectedBgImageView) {
            [self setBgImageViewFrameWith:index];
        }
        _lastClickLabel = [_monthLabels objectAtIndex:self.selectedIndex];
    
    }

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    if (touch.view == self && touchPoint.x < self.width && touchPoint.x >= 0) {
        if ( [_delegate respondsToSelector:@selector(monthBottomView:didSelectedIndex:)]) {
            [_delegate monthBottomView:self didSelectedIndex:self.selectedIndex];
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
