//
//  WSPhotoBrowserView.h
//  WinSFA
//
//  Created by admin on 16/1/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSImageBrowserView : UIScrollView
- (id)initWithFrame:(CGRect)frame andImage:(NSArray *)imageArr andImageIndex:(NSInteger)imageIndex;
@end
