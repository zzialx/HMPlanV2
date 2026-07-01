//
//  WSCompositeImageView.h
//  WinSFA
//
//  Created by winchannel on 2018/1/4.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSStoreOtherBean.h"
#import "WSTouchImageView.h"
@class WSCompositeImageView;

@protocol WSCompositeImageViewDeleagte <NSObject>

@optional

- (void)selectItem:(NSInteger )row;

@end

@interface WSCompositeImageView : UIImageView<ImageViewDeleagte>

@property (nonatomic, weak) id<WSCompositeImageViewDeleagte> delegate;
@property (nonatomic, strong) NSArray *subImages;
@property (nonatomic, assign) float scale;
- (id)initWithFrame:(CGRect)frame withSubImageArray:(NSArray *)subImageArray withSubViewScale:(float)scale;
@end
