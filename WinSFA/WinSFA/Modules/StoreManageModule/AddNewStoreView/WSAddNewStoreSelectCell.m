//
//  WSAddNewStoreSelectCell.m
//  WinSFA
//
//  Created by Alicia on 17/2/22.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSAddNewStoreSelectCell.h"
#import "WSStoreBean.h"
#import "PureLayout.h"
#import "NSString+Additions.h"
#import "WSTouchImageView.h"
#import "WSPhotoBrowserViewController.h"
#import "WSRequestHelper.h"

@interface WSAddNewStoreSelectCell () <ImageViewDeleagte>

@property (nonatomic, strong) WSTouchImageView *storeImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *locationLabel;
@property (nonatomic, strong) UILabel *phoneLabel;
@end

@implementation WSAddNewStoreSelectCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.storeImageView = [WSTouchImageView newAutoLayoutView];
        [self.contentView addSubview:self.storeImageView];
        [self.storeImageView autoSetDimensionsToSize:CGSizeMake(kAddNewStoreImageWH, kAddNewStoreImageWH)];
        [self.storeImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:MAIN_PADDING];
        [self.storeImageView autoAlignAxisToSuperviewAxis:ALAxisHorizontal];
        self.storeImageView.userInteractionEnabled = YES;
        self.storeImageView.delegate = self;
        
        self.nameLabel = [UILabel newAutoLayoutView];
        self.nameLabel.font = [UIFont systemFontOfSize:kAddNewStoreCellFontSize];
        self.nameLabel.numberOfLines = 0;
        [self.nameLabel setTextColor:MAIN_TEXT_COLOR];
        [self.contentView addSubview:self.nameLabel];
        [self.nameLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.storeImageView withOffset:MAIN_PADDING];
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:MAIN_PADDING];
        [self.nameLabel autoPinEdgeToSuperviewEdge:ALEdgeTop withInset:MAIN_PADDING];
        
        UIImageView *locationImageView = [UIImageView newAutoLayoutView];
        [self.contentView addSubview:locationImageView];
        [locationImageView setImage:[UIImage imageNamed:@"info_dizhi_icon"]];
        [locationImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.nameLabel];
        [locationImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameLabel];
        [locationImageView autoSetDimension:ALDimensionWidth toSize:kAddNewStoreIconWH];
        [locationImageView autoSetDimension:ALDimensionHeight toSize:kAddNewStoreIconWH];
        
        self.locationLabel = [UILabel newAutoLayoutView];
        self.locationLabel.font = [UIFont systemFontOfSize:kAddNewStoreCellFontSize];
        self.locationLabel.numberOfLines = 0;
        [self.locationLabel setTextColor:MAIN_TEXT_COLOR];
        [self.contentView addSubview:self.locationLabel];
        [self.locationLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:locationImageView];
        [self.locationLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.nameLabel];
        [self.locationLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.nameLabel];
      
        UIImageView *phoneImageView = [UIImageView newAutoLayoutView];
        [self.contentView addSubview:phoneImageView];
        [phoneImageView setImage:[UIImage imageNamed:@"info_tel_icon"]];
        [phoneImageView autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.nameLabel];
        [phoneImageView autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.locationLabel];
        [phoneImageView autoSetDimension:ALDimensionWidth toSize:kAddNewStoreIconWH];
        [phoneImageView autoSetDimension:ALDimensionHeight toSize:kAddNewStoreIconWH];
        
        self.phoneLabel = [UILabel newAutoLayoutView];
        self.phoneLabel.font = [UIFont systemFontOfSize:kAddNewStoreCellFontSize];
        [self.phoneLabel setTextColor:MAIN_TEXT_COLOR];
        [self.contentView addSubview:self.phoneLabel];
        [self.phoneLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeLeft ofView:self.locationLabel];
        [self.phoneLabel autoPinEdge:ALEdgeRight toEdge:ALEdgeRight ofView:self.nameLabel];
        [self.phoneLabel autoPinEdge:ALEdgeTop toEdge:ALEdgeBottom ofView:self.locationLabel];
        [self.phoneLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom withInset:MAIN_PADDING];
        [self.phoneLabel autoSetDimension:ALDimensionHeight toSize:kAddNewStoreIconWH];
    }
    return self;
}

- (void)setStoreBean:(WSStoreBean *)storeBean {
    _storeBean = storeBean;
    if ((![storeBean.storeImg isKindOfClass:[NSNull class]]) && storeBean.storeImg.length > 0) {
        [[WSRequestHelper shareInstance] downloadImageWithUrl:[WSHttpURLHelper getImageCompleteURL:storeBean.storeImg] imageView:self.storeImageView placeholderImage:[UIImage imageNamed:@"place_holder"]];
    } else {
        [self.storeImageView setImage:[UIImage imageNamed:@"place_holder"]];
    }
    
    self.nameLabel.text = storeBean.name;
    
    NSString *addr = storeBean.addr ? storeBean.addr : NSLocalizedString(@"empty_instruction_sheet_label", nil);
    self.locationLabel.text = addr;
    
    NSString *phone = storeBean.phone ? storeBean.phone : NSLocalizedString(@"empty_instruction_sheet_label", nil);
    self.phoneLabel.text = phone;
}



- (void)imageTouch:(WSTouchImageView *)imageView {
    NSMutableArray *imagesArray = [NSMutableArray arrayWithObject:imageView.image];
    WSPhotoBrowserViewController *photoBrowser = [[WSPhotoBrowserViewController alloc] initWithImages:imagesArray];
    photoBrowser.isAllowDeletePhoto = NO;
    photoBrowser.enableEdit = NO;
   
    [[self viewController] presentViewController:photoBrowser animated:YES completion:nil];
}

@end
