//
//  WSHelpDocument.m
//  WinSFA
//
//  Created by heju on 3/7/14.
//  Copyright (c) 2014 WinChannel. All rights reserved.
//



#import "WSHelpDocument.h"

@implementation WSHelpDocument

@synthesize items = _items;


- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (id)initWithObject:(id)helpDoc
{
    if (helpDoc == nil) {
        return nil;
    }
    self = [super init];
    
    if (self) {
        if (helpDoc != nil && [helpDoc isKindOfClass:[NSArray class]]) {
            _items = [NSMutableArray array];
            for (NSInteger i = 0; i < [helpDoc count]; i++) {
                NSDictionary *itemDictionary = [helpDoc objectAtIndex:i];
                WSHelpDocumentItem *item = [[WSHelpDocumentItem alloc]initWithObjcet:itemDictionary];
                [_items addObject:item];
            }
        }
    }
    
    return self;
}


@end
