//
//  WSSearchTagView.h
//  WinSFA
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WSSearchTagView;

@protocol WSSearchTagViewDelegate <NSObject>

- (void)selectChanged:(WSSearchTagView *)searchTagView;

@end

@interface WSSearchTagView : UIView

@property (nonatomic, copy, readonly) NSString *searchTag;

@property (nonatomic, assign) BOOL selected;

@property (nonatomic, weak) id<WSSearchTagViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame searchTag:(NSString *)searchTag;

@end
