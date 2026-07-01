//
//  WCDownLoadingAndShowingImageView.h
//  WinChannelFrameWork
//
//  Created by xiaotang.wang on 7/15/13.
//
//

#import <UIKit/UIKit.h>

@protocol WCDownLoadingAndShowingImageViewDelegate <NSObject>

- (void)touchShowImageViewEnd:(UIView *)view;

@end

@interface WCDownLoadingAndShowingImageView : UIView

@property (nonatomic, assign) BOOL removeOnTouch;
@property (nonatomic, assign) BOOL refreshLoadingOnTouch;       //点击刷新
@property (nonatomic, assign) BOOL isShowCloseButton;
@property (nonatomic, assign) id <WCDownLoadingAndShowingImageViewDelegate> delegate;
@property (nonatomic, strong)UIButton *closeButton;

- (id)initWithFrame:(CGRect)frame withImageURL:(NSString *)aUrl withProductName:(NSString *)name;
- (id)initWithFrame:(CGRect)frame andImage:(UIImage *)image;
- (id)initWithFrame:(CGRect)frame withImageURL:(NSString *)aUrl withImage:(UIImage*)image withDuration:(int)duration withProductName:(NSString *)name;

@end
