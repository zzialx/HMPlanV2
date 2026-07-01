//
//  WSHelpDocumentItemView.h
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSHelpDocumentItem.h"
#import "WSAppConfig.h"

@class WSHelpDocumentItemView;


@protocol WSHelpDocumentItemViewDelegate <NSObject>

- (void)helpDocumentItemViewCicked:(WSHelpDocumentItemView *)itemView;

@end

@interface WSHelpDocumentItemView : UIView

@property (nonatomic ,weak) id<WSHelpDocumentItemViewDelegate> itemViewDelegate;

@property (nonatomic ,strong) WSHelpDocumentItem *documentItem;

@property (nonatomic ,strong)UIImageView *itemImageView;

@property (nonatomic ,strong) UILabel *descriptLabel;

@property (nonatomic ,assign) BOOL showDescript;

- (id)initWithFrame:(CGRect)frame item:(WSHelpDocumentItem *)item  showDescript:(BOOL)des;


@end
