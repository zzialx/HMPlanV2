//
//  PropertyManager.m
//  WinChannelIPhone
//
//  Created by Chen Angus on 11-7-20.
//  Copyright 2011年 dumbrock. All rights reserved.
//

#import "PropertyManager.h"
static PropertyManager *sharedDataManager = nil;

@implementation PropertyManager
@synthesize property;

+ (void)setDefaultPath
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"source" ofType:@"plist"];
    NSMutableDictionary* l_defaultDic = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    sharedDataManager.property = nil;
    sharedDataManager.property = l_defaultDic;
    l_defaultDic = nil;
    sharedDataManager->isDefaultPath = YES;
}

+ (PropertyManager *) sharedManager
{
    @synchronized(self)
    {
        if(sharedDataManager  ==  nil)
        {
            sharedDataManager = [[self alloc] init];
            [PropertyManager setDefaultPath];
        }
    }
    
    return sharedDataManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (sharedDataManager  ==  nil)
        {
            sharedDataManager  =  [super allocWithZone:zone];
            return  sharedDataManager;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    if (isDefaultPath) 
    {
        isDefaultPath = TRUE;
    }
    return self;
}

//- (id)retain
//{
//    return self;
//}
//
//- (unsigned)retainCount
//{
//    return UINT_MAX;  //denotes an object that cannot be released
//}
//
//- (oneway void)release
//{
//    //do nothing
//}
//
//- (id)autorelease
//{
//    return self;
//}

+ (id)getPropertybyKey:(NSString *)key{
    
    id l_object = [[self sharedManager].property objectForKey:key];
    if(!sharedDataManager->isDefaultPath)
        [PropertyManager setDefaultPath];
    return l_object;
}

+ (BOOL)setFilePath:(NSString*)aFileName
{
    NSString *path = [[NSBundle mainBundle] pathForResource:aFileName ofType:@"plist"];
    if(path == nil)
        return NO;
    NSMutableDictionary* l_defaultDic = [[NSMutableDictionary alloc]initWithContentsOfFile:path];
    sharedDataManager.property = nil;
    sharedDataManager.property = l_defaultDic;
    l_defaultDic = nil;
    sharedDataManager->isDefaultPath = NO;
    return YES;
}
@end
