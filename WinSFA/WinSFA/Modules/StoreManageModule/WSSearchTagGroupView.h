//
//  WSSearchTagGroupView.h
//  WinSFA
//
//  Created by yang on 16/3/9.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WSSearchTagGroupView : UIView

@property (nonatomic, strong, readonly) WSAcvtBean_qst *qstBean;

@property (nonatomic, copy, readonly) NSString *searchTagString;

@property (nonatomic, strong, readonly) NSMutableArray *selectedTagArray;

- (instancetype)initWithFrame:(CGRect)frame searchTagString:(NSString *)searchTagString;

- (instancetype)initWithFrame:(CGRect)frame qstBean:(WSAcvtBean_qst *)qstBean;

- (void)resetAllTags;

- (void)setSelectedTagArray:(NSMutableArray *)selectedTagArray;

@end
