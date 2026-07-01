//
//  WSVideoMediaPanel.m
//  WinSFA
//
//  Created by winchannel on 15/4/15.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSVideoMediaPanel.h"
#import "I_Media_Info.h"
#import "I_Media.h"
#import "I_W_DataSource.h"
#import "I_W_BuildInfo.h"
#import <AVFoundation/AVFoundation.h>
#import <IAttachment.h>

#define kBottomViewHeight 60.0f

#define kBottomViewShowFrame CGRectMake(0, self.view.bounds.size.height - kBottomViewHeight, self.view.bounds.size.width, kBottomViewHeight)
#define kBottomViewHideFrame CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, kBottomViewHeight)

#define kProgressBarHeight 20.0f
#define kProgressBarLeftSpace (INTERFACE_IS_PAD ? 80.0f : 50.0f)
#define kProgressBarBottomSpace 20.0f
#define kPlayButtonLeftSpace (INTERFACE_IS_PAD ? 20.0f : 0.0f)

#define kTotalTimeLabelWidth (INTERFACE_IS_PAD ? 80.0f : 45.0f)

NSString * const kStatusKey = @"status";

NSString * const kRateKey	= @"rate";

static void *AVPlayerDemoPlaybackViewControllerRateObservationContext = &AVPlayerDemoPlaybackViewControllerRateObservationContext;

static void *AVPlayerDemoPlaybackViewControllerStatusObservationContext = &AVPlayerDemoPlaybackViewControllerStatusObservationContext;

@interface WSVideoMediaPanel ()
{
    AVPlayer *_player;
    
    AVPlayerLayer *_playerLayer;
    
    AVPlayerItem *_playerItem;
    
    id _timeObserver;
    
    BOOL _seekToZeroBeforePlay;
    
    float _restoreAfterScrubbingRate;
}


@property (nonatomic, strong) NSMutableArray *qstItemArray;

@property (nonatomic ,strong) UIView *bottomView;

@property (nonatomic, strong) UISlider *progressBar;

@property (nonatomic, strong) UIButton *playButton;

@property (nonatomic, strong) UIButton *pauseButton;

@property (nonatomic, strong) UIButton *stopButton;

@property (nonatomic, assign) double maxProgress;

@property (nonatomic, assign) double totalTime;

@property (nonatomic, assign) double currentProgress;

@property (nonatomic, assign) double lastTimePositon;

@property (nonatomic, strong) UILabel *totalTimeLabel;

@property (nonatomic, strong) UILabel *currentTimeLabel;

@property (nonatomic ,assign) NSTimeInterval barsAutoHideTimeInterval;


@end


@implementation WSVideoMediaPanel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.barsAutoHideTimeInterval = 8.0;
        self.totalTime = 0;
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if (_timeObserver) {
        
        [_player removeTimeObserver:_timeObserver];
    }
    
    [_player removeObserver:self forKeyPath:kRateKey];
    [_playerItem removeObserver:self forKeyPath:kStatusKey];
    
}

- (void)layoutSubviews
{
    _playerLayer.frame = self.bounds;
}


-(void)loadDataSource:(NSObject<I_W_DataSource> *)datasource{
    
    [super loadDataSource:datasource];
    
    
}

-(void)loadBuildInfo:(NSObject<I_W_BuildInfo> *)buildInfo{
    
    [super loadBuildInfo:buildInfo];
    
}


-(void)buildDisplayContent{
    
    NSString *filePath = [media_info getMediaFileSavePath];
    
    if (filePath == nil) {
        return;
    }
    
    _playerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:filePath]];
    
    _player = [AVPlayer playerWithPlayerItem:_playerItem];
    
    _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
    
    _playerLayer.frame = self.bounds;
    
    
    [self.layer addSublayer:_playerLayer];
    
    
    _lastTimePositon = _currentProgress;
    
    CMTime toTime=CMTimeMake(_currentProgress, _player.currentTime.timescale);
    
    [_player seekToTime:toTime];
    [_player seekToTime:toTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero];
    
    
    UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - kBottomViewHeight, self.bounds.size.width, kBottomViewHeight)];
    
    bottomView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
    
    bottomView.layer.borderWidth = 1.0;
    
    bottomView.layer.borderColor = [[UIColor blackColor] CGColor];
    
    bottomView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    
    self.bottomView = bottomView;
    
    [self addSubview:self.bottomView];
    
    [self bringSubviewToFront:self.bottomView];
    
    
    UIFont *font = [UIFont systemFontOfSize:UI_Font];
    
    self.progressBar = [[UISlider alloc] initWithFrame:CGRectMake(kProgressBarLeftSpace, (kBottomViewHeight - kProgressBarHeight)/2, self.bounds.size.width - kProgressBarLeftSpace - kTotalTimeLabelWidth*2, kProgressBarHeight)];
    
    self.progressBar.continuous = YES;
    
    UIColor *mainTintColor = MAIN_TINT_COLOT;
    if (!mainTintColor) {
        mainTintColor = [UIColor colorWithRed:0.0 green:156.0/255.0 blue:229.0/255.0 alpha:1.0];
    }
    [self.progressBar setMinimumTrackTintColor: mainTintColor];
//    [self.progressBar addTarget:self action:@selector(beginScrubbing:) forControlEvents:UIControlEventTouchDown];
//    [self.progressBar addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchCancel];
//    [self.progressBar addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpInside];
//    [self.progressBar addTarget:self action:@selector(endScrubbing:) forControlEvents:UIControlEventTouchUpOutside];
//    [self.progressBar addTarget:self action:@selector(scrub:) forControlEvents:UIControlEventValueChanged];
    self.progressBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.progressBar.userInteractionEnabled = NO;
    
    [self.bottomView addSubview:self.progressBar];
    
    self.playButton = [[UIButton alloc] initWithFrame:CGRectMake(kPlayButtonLeftSpace, 0, kBottomViewHeight, kBottomViewHeight)];
    [self.playButton setImage:[UIImage imageNamed:@"play_btn"] forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(playTheMeida) forControlEvents:UIControlEventTouchUpInside];
    
    
    self.pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(kPlayButtonLeftSpace, 0, kBottomViewHeight, kBottomViewHeight)];
    [self.pauseButton setImage:[UIImage imageNamed:@"pause_btn"] forState:UIControlStateNormal];
    [self.pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    
    self.totalTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - kProgressBarLeftSpace , 0, kTotalTimeLabelWidth, kBottomViewHeight)];
    self.totalTimeLabel.backgroundColor=[UIColor clearColor];
    self.totalTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.bottomView addSubview:self.totalTimeLabel];
    
    self.totalTimeLabel.font = font;
    
    
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.bounds.size.width - kProgressBarLeftSpace - kTotalTimeLabelWidth, 0, kTotalTimeLabelWidth, kBottomViewHeight)];
    self.currentTimeLabel.backgroundColor = [UIColor clearColor];
    self.currentTimeLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
    [self.bottomView addSubview:self.currentTimeLabel];
    self.currentTimeLabel.font = font;
    self.currentTimeLabel.textAlignment = NSTextAlignmentRight;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:_playerItem];
    
    
    [_playerItem addObserver:self
                  forKeyPath:kStatusKey
                     options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                     context:AVPlayerDemoPlaybackViewControllerStatusObservationContext];
    [_player addObserver:self
              forKeyPath:kRateKey
                 options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew
                 context:AVPlayerDemoPlaybackViewControllerRateObservationContext];
    
    [self addTimeObserver];
    
//    [self playTheMeida];
    
    [self syncPlayPauseButtons];
    
}

- (void)playTheMeida
{
    
    if (YES == _seekToZeroBeforePlay)
    {
        _seekToZeroBeforePlay = NO;
        
        [_player seekToTime:kCMTimeZero];
    }
    
    [_player play];

    [self showPauseButton];
    
    if ([self.mediaOperationDelegate respondsToSelector:@selector(beginPlayCurrentMedia:)]) {
        [self.mediaOperationDelegate beginPlayCurrentMedia:self];
    }
    
    if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaInPlay:)]) {
        [self.mediaOperationDelegate currentMediaInPlay:self];
    }
    
}


- (void)pause
{
    [_player pause];

    [self showPlayButton];
    
    if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaInPause:)]) {
        [self.mediaOperationDelegate currentMediaInPause:self];
    }
}



- (void)stop
{
    [_player pause];
    
    [_player seekToTime:kCMTimeZero];
    
    _seekToZeroBeforePlay = YES;
    
    [self.progressBar setValue:0 animated:YES];
    
}

- (void)addTimeObserver
{
    
    __weak typeof(self) bself = self;
    
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(0.2f, NSEC_PER_SEC)
                                                          queue:NULL
                                                     usingBlock:^(CMTime time) {
                                                         [bself syncScrubber];
                                                     }];
}



- (void)removeTimeObserver
{
    if (_timeObserver) {
        [_player removeTimeObserver:_timeObserver];
        _timeObserver = nil;
    }
    
}


- (BOOL)isPlaying
{
    return _restoreAfterScrubbingRate != 0.f || [_player rate] != 0.f;
}


#pragma mark - Play, Stop buttons

- (void)syncPlayPauseButtons
{
    if ([self isPlaying])
    {
        [self showPauseButton];
        
    }
    else
    {
        [self showPlayButton];
    }
}

-(void)showPauseButton
{
    [self.playButton removeFromSuperview];
    
    [self.bottomView addSubview:self.pauseButton];
}


-(void)showPlayButton
{
    [self.pauseButton removeFromSuperview];
    
    [self.bottomView addSubview:self.playButton];
}


-(void)enablePlayerButtons
{
    self.playButton.enabled = YES;
    
    self.pauseButton.enabled = YES;
}


-(void)disablePlayerButtons
{
    self.playButton.enabled = NO;
    
    self.pauseButton.enabled = NO;
}


#pragma mark - Movie scrubber control

- (CMTime)playerItemDuration
{
    
    AVPlayerItem *playerItem = [_player currentItem];
    
    if (playerItem.status == AVPlayerItemStatusReadyToPlay)
    {
        return([playerItem duration]);
        
    }
    
    return(kCMTimeInvalid);
    
}



- (void)syncScrubber
{
    
    CMTime playerDuration = [self playerItemDuration];
    
    if (CMTIME_IS_INVALID(playerDuration))
    {
        self.progressBar.minimumValue = 0.0;
        
        return;
    }

    
    double duration = CMTimeGetSeconds(playerDuration);
    
    if (duration)
        
    {
        
        float minValue = [self.progressBar minimumValue];
        
        float maxValue = [self.progressBar maximumValue];
        
        double time = CMTimeGetSeconds([_player currentTime]);
        
        if (time > _maxProgress) {
            
            _maxProgress = time;
            
        }
        
        self.currentProgress=time;
        
        
        
        [self.progressBar setValue:(maxValue - minValue) * time / duration + minValue];
        
    }

    int hours = self.currentProgress / 3600;
    int minutes = ((int)self.currentProgress / 60) % 60;
    int seconds = (int)self.currentProgress % 60;
    
    if(hours==0){
        
        self.currentTimeLabel.text=[NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
        
    }else{
        
        self.currentTimeLabel.text=[NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
        
    }
    
}



- (void)beginScrubbing:(id)sender
{
    _restoreAfterScrubbingRate = [_player rate];
    
    [_player setRate:0.f];
    
    [self removeTimeObserver];
}



- (void)scrub:(id)sender
{
    if ([sender isKindOfClass:[UISlider class]])
    {
        UISlider* slider = sender;
        
        CMTime playerDuration = [self playerItemDuration];
        
        if (CMTIME_IS_INVALID(playerDuration)) {
            
            return;
            
        }
        
        double duration = CMTimeGetSeconds(playerDuration);
        
        if (duration)
        {
            float minValue = [slider minimumValue];
            
            float maxValue = [slider maximumValue];
            
            float value = [slider value];
            
            double time = duration * (value - minValue) / (maxValue - minValue);
            
            [_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
        }
    }
}


- (void)endScrubbing:(id)sender
{
    
    if (!_timeObserver)
    {
        CMTime playerDuration = [self playerItemDuration];
        
        if (CMTIME_IS_INVALID(playerDuration))
        {
            return;
        }
        [self addTimeObserver];
        
    }

    
    if (_restoreAfterScrubbingRate)
    {
        [_player setRate:_restoreAfterScrubbingRate];
        
        _restoreAfterScrubbingRate = 0.f;
        
    }
}

-(void)enableScrubber
{
    self.progressBar.enabled = YES;
}


-(void)disableScrubber
{
    self.progressBar.enabled = NO;
    
}


#pragma mark - AVPlayerItem Notifications

- (void)playerItemDidReachEnd:(NSNotification *)notification
{
    
    _seekToZeroBeforePlay = YES;
    
    self.currentProgress = 0.0;
    
    [self.progressBar setValue:0 animated:YES];
    
    if ([self.mediaOperationDelegate respondsToSelector:@selector(currentMediaPlayEnd:)]) {
        [self.mediaOperationDelegate currentMediaPlayEnd:self];
    }
    
}


#pragma mark - Key Value Observer for player rate, player item status

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == AVPlayerDemoPlaybackViewControllerStatusObservationContext)
    {
        [self syncPlayPauseButtons];
        
 
        AVPlayerStatus status = [[change objectForKey:NSKeyValueChangeNewKey] integerValue];
        
        switch (status)
        {
                /* Indicates that the status of the player is not yet known because
                 
                 it has not tried to load new media resources for playback */
                
            case AVPlayerStatusUnknown:
            {
                [self removeTimeObserver];
                
                [self syncScrubber];
                
                [self disableScrubber];
                
                [self disablePlayerButtons];
                
            }
                
                break;
                
            case AVPlayerStatusReadyToPlay:
            {
                /* Once the AVPlayerItem becomes ready to play, i.e.
                 
                 [playerItem status] == AVPlayerItemStatusReadyToPlay,
                 
                 its duration can be fetched from the item. */
                
                
                [self addTimeObserver];
                
                CMTime playerDuration = [self playerItemDuration];
                
                self.totalTime = CMTimeGetSeconds(playerDuration);
                
                [self enableScrubber];
                
                [self enablePlayerButtons];
                
                
                int hours = self.currentProgress / 3600;
                
                int minutes = ((int)self.currentProgress / 60) % 60;
                
                int seconds = (int)self.currentProgress % 60;

                
                if(hours == 0){
                    self.currentTimeLabel.text=[NSString stringWithFormat:@"%02d:%02d",minutes,seconds];
                }else{
                    self.currentTimeLabel.text=[NSString stringWithFormat:@"%02d:%02d:%02d",hours,minutes,seconds];
                }
                
                CMTime totalTime = _player.currentItem.duration;
                
                CGFloat totalMovieDuration = (CGFloat)totalTime.value/(CGFloat)totalTime.timescale;
                

                hours = totalMovieDuration / 3600;
                minutes = ((int)totalMovieDuration / 60) % 60;
                seconds = (int)totalMovieDuration % 60;
                
  
                if(hours == 0){
                    self.totalTimeLabel.text=[NSString stringWithFormat:@"/%02d:%02d",minutes,seconds];
                }else{
                    self.totalTimeLabel.text=[NSString stringWithFormat:@"/%02d:%02d:%02d",hours,minutes,seconds];
                }
   
            }
                break;

            case AVPlayerStatusFailed:
            {
                AVPlayerItem *playerItem = (AVPlayerItem *)object;
                
                [self removeTimeObserver];
                
                [self syncScrubber];
                
                [self disableScrubber];
                
                [self disablePlayerButtons];
                
                LogError(@"status change:AVPlayerStatusFailed:%@",[playerItem error]);
                
            }
                break;
        }
    }
    
    /* AVPlayer "rate" property value observer. */
    
    else if (context == AVPlayerDemoPlaybackViewControllerRateObservationContext)
    {
        [self syncPlayPauseButtons];
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
