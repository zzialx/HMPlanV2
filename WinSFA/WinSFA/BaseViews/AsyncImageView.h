//
//  AsyncImageView.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

//TODO:用SDWebImage替换掉

#import <UIKit/UIKit.h>

@interface AsyncImageView : UIView {
    NSURLConnection         *connection;
    NSMutableData           *ImageData;
    UIActivityIndicatorView *aiv;
}

- (void)loadImageFromURL:(NSURL *)url;

@end
