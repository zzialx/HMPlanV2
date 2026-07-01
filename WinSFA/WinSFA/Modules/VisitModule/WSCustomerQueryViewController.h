//
//  CustomerQueryViewController.h
//  WinChannelFrameWork
//
//  Created by winchannel on 12-3-15.
//  Copyright 2012年 __MyCompanyName__. All rights reserved.
//

#import "WSAllStoresViewController.h"
#import "WSLocationManager.h"
#import "WSLocationSelectViewController.h"
#import "WSSelectListTableViewCell.h"
#import "WSSearchStoreViewController.h"

@interface WSCustomerQueryViewController : WSAllStoresViewController <WSLocationSelectViewControllerDelegate,WSSelectListTableViewCellDelegate,WSSearchStoreViewControllerDelegate>
{}
@property (nonatomic, strong) NSMutableString *m_searchResult;


//-(void)startUpdataManager:(WSStoreBean*)store;

-(BOOL)isesqDefaulet:(NSArray *)array;

- (NSString*)getObjIDToStoreList;

@end
