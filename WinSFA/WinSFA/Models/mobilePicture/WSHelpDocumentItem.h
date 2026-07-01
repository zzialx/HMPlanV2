//
//  WSHelpDocumentItem.h
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WSHelpDocumentItem : NSObject

@property (nonatomic ,strong) NSString *empId;
@property (nonatomic ,strong) NSString *itemId;
@property (nonatomic ,strong) NSString *title;
@property (nonatomic ,strong) NSString *url;
@property (nonatomic ,strong) NSString *descript;
@property (nonatomic ,strong) NSString *iconUrl;
@property (nonatomic ,strong) NSString *sort;

- (id)initWithObjcet:(id)docItem;

@end
