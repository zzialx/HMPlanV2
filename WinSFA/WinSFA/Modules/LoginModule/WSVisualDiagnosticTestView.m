//
//  WSVisualDiagnosticTestView.m
//  WinSFA
//
//  Created by HZH on 16/10/17.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WSVisualDiagnosticTestView.h"

#define H_TEST_WIDTH_SPACE 5.0
#define H_TEST_HEIGHT_SPACE 5.0

@interface WSVisualDiagnosticTestView ()
{
    UILabel *_contentLabel;
    UIProgressView *_progressView;
    UILabel *_timeLabel;
    UILabel *_stateLabel;
}

@end

@implementation WSVisualDiagnosticTestView

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithFrame:frame andTestContentString:nil];
        
        return self;
    }
    return nil;
    
}

-(id)initWithFrame:(CGRect)frame andTestContentString:(NSString *)contentString{
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviewsWithFrame:frame andTestContentString:contentString];
        
        return self;
    }
    return nil;
    
}

- (void)setupSubviewsWithFrame:(CGRect)frame andTestContentString:(NSString *)contentString
{
    CGFloat aWidth = frame.size.width - H_TEST_WIDTH_SPACE*5;
    
    _contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(H_TEST_WIDTH_SPACE, 0, aWidth/3, 40)];
    _contentLabel.font = [UIFont systemFontOfSize:14.0];
    _contentLabel.text = contentString;
    _contentLabel.numberOfLines = 0;
    
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(aWidth/3 + H_TEST_WIDTH_SPACE*2, H_TEST_HEIGHT_SPACE*3 + 3, aWidth/3, 30)];
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, 4.0f);
    _progressView.transform = transform;
    _progressView.progressImage = [UIImage imageNamed:@"loading_yellow"];
    _progressView.trackImage = [UIImage imageNamed:@"loading_gray"];
    
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(aWidth/3*2 + H_TEST_WIDTH_SPACE*4, H_TEST_HEIGHT_SPACE, aWidth/3/2, 30)];
    _timeLabel.font = [UIFont systemFontOfSize:14.0];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.text = @"   -";

    _stateLabel = [[UILabel alloc] initWithFrame:CGRectMake(aWidth/3/2 + aWidth/3*2 + H_TEST_WIDTH_SPACE*5, H_TEST_HEIGHT_SPACE, aWidth/3/2, 30)];
    _stateLabel.font = [UIFont systemFontOfSize:14.0];
    _stateLabel.textAlignment = NSTextAlignmentCenter;
    _stateLabel.text = @"   -";
    
    [self addSubview:_contentLabel];
    [self addSubview:_progressView];
    [self addSubview:_timeLabel];
    [self addSubview:_stateLabel];
    
}

- (void)setProgressAndTextWhenTestFinishedWithUseTime:(long)testUseTime
{
    if (testUseTime > 0 && testUseTime < 30000) {
        _timeLabel.text = [NSString stringWithFormat:@"%.2fs", (float)testUseTime/1000];
        _stateLabel.text = NSLocalizedString(@"complete", nil) ;
        [UIView animateWithDuration:testUseTime/1000 animations:^{
            [_progressView setProgress:1.0 animated:NO];
        } completion:^(BOOL finished) {

        }];
    }else if (testUseTime <= 0) {
        _timeLabel.text = @"0s";
        _stateLabel.text = NSLocalizedString(@"failure", nil) ;
        [_progressView setProgress:0.2 animated:YES];
    }else if (testUseTime >= 30000) {
        _timeLabel.text = @"30s";
        _stateLabel.text = NSLocalizedString(@"timeout", nil)  ;
        [_progressView setProgress:0.9 animated:YES];
    }

}

- (void)setProgress:(CGFloat)progress andTextWhenTestFinishedWithUseTime:(long)testUseTime
{
    if (progress == 1.0) {
        if (testUseTime > 0 && testUseTime < 30000) {
            _timeLabel.text = [NSString stringWithFormat:@"%.2fs", (float)testUseTime/1000];
            _stateLabel.text = NSLocalizedString(@"complete", nil);
            //        [UIView animateWithDuration:testUseTime/1000 animations:^{
            //            [_progressView setProgress:1.0 animated:NO];
            //        } completion:^(BOOL finished) {
            //
            //        }];
            [_progressView setProgress:progress animated:NO];
        }else if (testUseTime <= 0) {
            _timeLabel.text = @"0s";
            _stateLabel.text = NSLocalizedString(@"failure", nil);
            [_progressView setProgress:0.2 animated:YES];
        }else if (testUseTime >= 30000) {
            _timeLabel.text = @"30s";
            _stateLabel.text = NSLocalizedString(@"timeout", nil);
            [_progressView setProgress:0.9 animated:YES];
        }

    }else{
        if (testUseTime > 0 && testUseTime < 30000) {
            _timeLabel.text = [NSString stringWithFormat:@"%.2fs", (float)testUseTime/1000];
            [_progressView setProgress:progress animated:NO];
        }else if (testUseTime <= 0) {
            _timeLabel.text = @"0s";
            _stateLabel.text = NSLocalizedString(@"failure", nil);
            [_progressView setProgress:0.2 animated:YES];
        }else if (testUseTime >= 30000) {
            _timeLabel.text = @"30s";
            _stateLabel.text = NSLocalizedString(@"timeout", nil);
            [_progressView setProgress:0.9 animated:YES];
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
