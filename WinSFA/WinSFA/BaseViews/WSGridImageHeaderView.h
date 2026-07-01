//
//  WSGridImageHeaderView.h
//  WinSFA
//
//  Created by Stephanie on 16/9/8.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>


#define kGridImageHeaderViewImageWith 80

@interface WSGridImageHeaderView : UIView

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *textLabel;

@property (nonatomic, strong) NSString *productID;

@property (nonatomic, strong) NSString *imageURL;

@property (nonatomic, strong) NSString *text;

@end
