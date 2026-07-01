//
//  AsyncImageView.m
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-22.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "AsyncImageView.h"

@implementation AsyncImageView

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        aiv = [[UIActivityIndicatorView alloc] 
               initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        aiv.frame = CGRectMake(0.0f, 0.0f, 40.0f, 40.0f);
        aiv.hidesWhenStopped = YES;
        aiv.center = self.center;
        [self addSubview:aiv];
    }
    return self;
}
- (void)loadImageFromURL:(NSURL*)url
{
    [aiv startAnimating];
    NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy  timeoutInterval:30.0];
    connection= [[NSURLConnection alloc] initWithRequest:request delegate:self];
    //TODO error handling, what if connection is nil?
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if(ImageData==nil) {
        ImageData=[[NSMutableData alloc]initWithCapacity:2048];
    }
    [ImageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
    [aiv stopAnimating];
    connection=nil;
    if([[self subviews]count]>0) {
        [[[self subviews] objectAtIndex:0] removeFromSuperview];
    }
    UIImageView*imageView= [[UIImageView alloc]initWithImage:[UIImage imageWithData:ImageData]];
    imageView.contentMode=UIViewContentModeScaleAspectFit;
    imageView.autoresizingMask= (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
    [self  addSubview:imageView];
    imageView.frame=self.bounds;
    [imageView setNeedsLayout];
    [self setNeedsLayout];
    ImageData=nil;
}

- (UIImage*) image {
    UIImageView *iv = [[self subviews]objectAtIndex:0];
    return[iv image];
}



- (void)dealloc {
    [connection cancel];
}

@end
