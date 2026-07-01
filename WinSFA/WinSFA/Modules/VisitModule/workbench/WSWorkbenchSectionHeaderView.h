//
//  WSWorkbenchSectionHeaderView.h
//  WinSFA
//
//  Created by yang on 16/12/26.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kWorkbenchSectionHeaderBackgroudColor RGBCOLOR(249, 249, 249)
#define kWorkbenchSectionHeaderViewTextColor HColorFromHex(0x3c3c3c)

@interface WSWorkbenchSectionHeaderView : UICollectionReusableView

- (void)setTitle:(NSString *)title;

@end
