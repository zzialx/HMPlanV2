//
//  WSHelpDocument.h
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "WSHelpDocumentItem.h"

@interface WSHelpDocument : NSObject

@property (nonatomic ,strong)NSMutableArray *items;

- (id)initWithObject:(id)helpDoc;

@end
