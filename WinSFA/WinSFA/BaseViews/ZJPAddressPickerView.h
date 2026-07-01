//
//  CityPicker.h
//  CityPicker
//
//  Created by Jiepeng Zheng on 12-9-11.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SelectListControl.h"

#define kProvinceID         @"provinceID"
#define kCityID             @"cityID"
#define kAreaID             @"areaID"
#define kProvinceName       @"provinceName"
#define kCityName           @"cityName"
#define kAreaName           @"areaName"
#define kStreetName         @"streetName"
#define kAddress            @"address"

@class ZJPAddressPickerView;

@protocol ZJPAddressPickerViewDelegate <NSObject>

@optional

- (void)addressPickerViewAddressChanged:(ZJPAddressPickerView *)aView;

@end

@interface ZJPAddressPickerView : UIView <SelectListDelegate, UITextFieldDelegate>

@property (weak, nonatomic, readonly) NSString *address;
@property (weak, nonatomic, readonly) NSString *codeAddress;

@property (nonatomic, strong) UITextField *streetTextField;

@property (nonatomic, weak) id<ZJPAddressPickerViewDelegate> addressPickerDelegate;

- (id)initWithFrame:(CGRect)frame withPreInfoDic:(NSDictionary *)preInfoDic;
- (NSDictionary *)resultWithDic;

@end
