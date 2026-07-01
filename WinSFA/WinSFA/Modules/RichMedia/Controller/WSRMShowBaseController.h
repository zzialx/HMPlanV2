//
//  WSRMShowBaseController.h
//  WinSFA
//
//  Created by zhiqing on 16/9/1.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSRMShowBaseController.h"
@class WSRichItemModel;
@interface WSRMShowBaseController : UIViewController

@property(nonatomic,copy) NSString *filterName;
@property (nonatomic, strong) WSStoreBean   *m_currentStore;

@property(nonatomic,strong) NSArray *allItemModel;
-(NSArray * )getFilterItemsWiht:(NSString *)filter;
-(NSArray *)getAllItemWith:(NSString *)filter;
-(NSArray *)getAllItemWith:(NSString *)filter withFilterName:(NSString *)FilterName;
-(UIImage *)getImageWith:(NSString *)filePath wihtType:(NSString *)type;

- (void)itemClickCallH5WithItemModel:(WSRichItemModel *)item;
-(void)reloadData;
@end
