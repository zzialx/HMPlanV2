//
//  WSPhotoTypeView.h
//  WinSFA
//
//  Created by yang on 13-12-10.
//  Copyright (c) 2013年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSValidateData.h"

//带类型的拍照（PT）

@class WSPhotoTypeItem,WSPhotoTypeArrayItem;
@protocol WSPhotoTypeViewDelegate;


@interface WSPhotoTypeView : UIView<WSValidateData>

@property (nonatomic, strong) WSPhotoTypeArrayItem *photoTypeArrayItem;

@property (nonatomic, strong) WSStoreBean *currentStore;

@property (nonatomic, weak) UIViewController *viewController;

@property (nonatomic, weak) id<WSPhotoTypeViewDelegate> delegate;

@property (nonatomic, assign) BOOL isValueChange;

- (id)initWithFrame:(CGRect)frame andPhotoTypeArrayItem:(WSPhotoTypeArrayItem *)item;

+ (CGFloat)getViewHeightWithItemCount:(NSInteger)count;

@end

@protocol WSPhotoTypeViewDelegate <NSObject>

@optional

- (void)photoTypeView:(WSPhotoTypeView *)photoTypeView didSelectedIndex:(NSInteger)index;

@end
