//
//  WSHelpDocumentItem.m
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//

#import "WSHelpDocumentItem.h"

@implementation WSHelpDocumentItem
@synthesize empId = _empId;
@synthesize itemId = _itemId;
@synthesize title = _title;
@synthesize url = _url;
@synthesize descript = _descript;
@synthesize iconUrl = _iconUrl;
@synthesize sort = _sort;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id) parserObjectExcludeNull:(id)objectParam
{
    if (!objectParam || [objectParam isKindOfClass:[NSNull class]]) {
        return nil;
    }
    
    return objectParam;
}

- (id)initWithObjcet:(id)docItem {
    if (docItem == nil) {
        return nil;
    }
    self =[super init];
    if (self) {
        if ([docItem isKindOfClass:[NSDictionary class]]) {
            _empId = [self parserObjectExcludeNull: [docItem objectForKey:@"empId"]];
            _itemId = [self parserObjectExcludeNull: [docItem objectForKey:@"id"]];
            _title = [self parserObjectExcludeNull: [docItem objectForKey:@"title"]];
            _url = [self parserObjectExcludeNull: [docItem objectForKey:@"url"]];
            _descript = [self parserObjectExcludeNull: [docItem objectForKey:@"descript"]];
            _iconUrl = [self parserObjectExcludeNull: [docItem objectForKey:@"iconUrl"]];
            _sort = [self parserObjectExcludeNull: [docItem objectForKey:@"sort"]];
        }
    }
    return self;
}

@end
