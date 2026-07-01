//
//  WSFeatureVideoViewController.m
//  WinSFA
//
//  Created by Alicia on 2017/9/12.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSFeatureVideoViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#define kButtonWidth        112
#define kButtonHeight       35
#define kPaddingTop         (0.757 * SCREEN_HEIGHT)

@interface WSFeatureVideoViewController ()

@property (nonatomic, strong) MPMoviePlayerController *moviePlayerController;

@end

@implementation WSFeatureVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViews];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    self.delegate = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupViews {
    self.moviePlayerController = [[MPMoviePlayerController alloc] init];
    self.moviePlayerController.movieSourceType = MPMovieSourceTypeFile;
    self.moviePlayerController.controlStyle = MPMovieControlStyleNone;
    self.moviePlayerController.view.frame = [UIScreen mainScreen].bounds;
    [self.moviePlayerController setFullscreen:YES];
    [self.moviePlayerController setShouldAutoplay:YES];
    [self.moviePlayerController setRepeatMode:MPMovieRepeatModeNone];
    [self.view addSubview:self.moviePlayerController.view];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];

    
    NSString *moviePath = [[NSBundle mainBundle] pathForResource:@"guide" ofType:@"mp4"];
    self.moviePlayerController.contentURL = [[NSURL alloc] initFileURLWithPath:moviePath];
    [self.moviePlayerController play];
    
    UIImage *skipImage = [UIImage imageNamed:@"btn_enter"];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:skipImage forState:UIControlStateNormal];
    [button addTarget:self action:@selector(skipAction:) forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake((self.view.width - skipImage.size.width) / 2, kPaddingTop, skipImage.size.width, skipImage.size.height);
    [self.view addSubview:button];
}

- (void)skipAction:(id)sender {
    if (self.delegate) {
        [self.delegate donePlaying];
    }
}

#pragma mark - NSNotificationCenter
- (void)playbackDidFinish:(NSNotification *)aNotification{
    int value = [[aNotification.userInfo valueForKey:MPMoviePlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    if (value == MPMovieFinishReasonUserExited || value == MPMovieFinishReasonPlaybackEnded) {
        if (self.delegate) {
            [self.delegate donePlaying];
        }
    }
}

@end
