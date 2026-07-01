//
//  WSTextViewEditTool.h
//  WinSFA
//
//  Created by zhangmin on 2018/8/27.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^WSTextViewEditToolBlock)(NSString *textStr);

@interface WSTextViewEditTool : UIView
@property (nonatomic, copy) WSTextViewEditToolBlock textEditBlock;

- (id)initWithFrame:(CGRect)frame andText:(NSString *)text title: (NSString *)title;

@end
