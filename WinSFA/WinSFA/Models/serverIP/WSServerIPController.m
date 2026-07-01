//
//  ServerIPController.m
//  WinChannelFrameWork
//
//  Created by ygs on 6/18/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "WSServerIPController.h"

@interface WSServerIPController ()

@end

@implementation WSServerIPController
@synthesize ServerIPString = _ServerIPString;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (id)initWithObject:(id)object
{
    if (nil == object) 
    {
        return nil;
    }
    self = [super init];
    if (self) 
    {
        if ([object isKindOfClass:[NSDictionary class]]) 
        {
            NSDictionary *dic = (NSDictionary *)object;
            self.ServerIPString = [[NSString stringWithValue:[dic objectForKey:ServerIP]] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        }
    }
    
    return self;

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
