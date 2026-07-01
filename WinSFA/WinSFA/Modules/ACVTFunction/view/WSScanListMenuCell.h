//
//  WSScanListMenuCell.h
//  WinSFA
//
//  Created by winchannel on 15/10/20.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMenuPanel.h"

#define INTERFACE_IS_PAD     ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define kScanListMenuCellSpace (1? self.frame.size.width:self.frame.size.width)

#define kImageViewLeftSapce 15.0f
#define kImageViewWidth 28.0f
#define kImageViewHeight 28.0f
#define kLabelLeftGap 5.0f
#define kEventLabelWidth 22.0f
#define kEventLabelRightSpace 5.0f

@class WSScanListMenuCell;

@protocol WSScanListMenuCellDelegate <NSObject>

- (void)tableMenuDidShowInCell:(WSScanListMenuCell *)cell;//展示menu

- (void)tableMenuWillShowInCell:(WSScanListMenuCell *)cell;

- (void)tableMenuDidHideInCell:(WSScanListMenuCell *)cell;//隐藏menu

- (void)tableMenuWillHideInCell:(WSScanListMenuCell *)cell;

- (void)deleteCell:(WSScanListMenuCell *)cell;

- (void)addPhotosCell:(WSScanListMenuCell *)cell withIndex:(NSIndexPath *)index;

@end

@interface WSScanListMenuCell : UITableViewCell<UIGestureRecognizerDelegate,WSMenuPanelDelegate>

@property (nonatomic, strong) UIView *cellView;

@property (nonatomic, strong) WSMenuPanel *menuView;

@property (nonatomic, strong) UIButton *addPhotoBtn;

@property (nonatomic, assign) float startX;

@property (nonatomic, assign) float cellX;

@property (nonatomic, weak)   id<WSScanListMenuCellDelegate>delegate;

@property (nonatomic, strong) NSIndexPath *indexPathNum;

@property (nonatomic, assign) NSInteger menuCout;

@property (nonatomic, assign) BOOL menuViewHidden;

@property (nonatomic, strong) UILabel *mainTitle;

@property (nonatomic, strong) UILabel *subTitle;

@property (nonatomic, strong) UILabel *eventCountLabel;

@property (nonatomic ,strong) NSString  *photosCout;

@property (nonatomic, strong) NSString *isPhotoRequire;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andCellWidth:(CGFloat)width;

- (void)configWithData:(NSIndexPath *)indexPath mainTitle:(NSString *)mainTitle menuData:(NSArray *)menuData;

- (void)setMenuHidden:(BOOL)hidden animated:(BOOL)animated completionHandler:(void(^)(void))completionHandler;

+ (CGFloat )heightWithMainTitle:(NSString *)mainTitle withSubTitle:(NSString *)subTitle withCellFrame:(CGRect )aFrame;

@end
