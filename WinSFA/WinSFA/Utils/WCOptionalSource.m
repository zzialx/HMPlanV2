//
//  ViewControllerMappingManager.m
//  WinChannelFrameWork
//
//  Created by Cai Lei on 10/19/12.
//
//

#import "WCOptionalSource.h"
#import "WSPlistHelper.h"

static NSString * const kPlistName = @"WCOptionalSource";
static NSString * const kViewControllerName = @"ViewControllerName";
static NSString * const kParam = @"Param";

static WCOptionalSource *sharedInstance;

@interface WCOptionalSource ()
@property (nonatomic, strong) NSDictionary *propertyDict;
@end

@implementation WCOptionalSource
@synthesize propertyDict = propertyDict_;

+ (void)initialize {
    NSAssert([WCOptionalSource class] == self, @"Incorrect use of singleton : %@, %@", [WCOptionalSource class], [self class]);
    sharedInstance = [[WCOptionalSource alloc] init];
}

+ (WCOptionalSource *)sharedInstance {
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    self.propertyDict = [WSPlistHelper allPropertiesWithPlistName:kPlistName];
}

- (UIViewController *)viewControllerFromKey:(NSString *)aKey {
    if (!self.propertyDict) {
        return nil;
    }
    
    NSDictionary *vcDict = [self.propertyDict valueForKey:aKey];
    if ((!vcDict) || (![vcDict isKindOfClass:[NSDictionary class]])) {
        return nil;
    }
    
    NSString *viewControllerName = [vcDict valueForKey:kViewControllerName];
    if ((!viewControllerName) || (![viewControllerName isKindOfClass:[NSString class]])) {
        return nil;
    }
    
    UIViewController *vc = nil;
    vc = [[NSClassFromString(viewControllerName) alloc] init];
    
    if (![vc isKindOfClass:[UIViewController class]]) {
        return nil;
    }
    
    @try {
        NSDictionary *param = [vcDict valueForKey:kParam];
        [vc setValuesForKeysWithDictionary:param];
    }
    @catch (NSException *exception) {
        DDLogError(@"ViewControllerMapping Error : %@", exception.description);
    }
    
    return vc;
}

- (NSString *)getViewControllerNamebyKey:(NSString *)aKey
{
    
    if (!self.propertyDict)
    {
        return nil;
    }
    
    NSDictionary *vcDict = [self.propertyDict valueForKey:aKey];
    if (!vcDict)
    {
        return nil;
    }
    
    NSString *viewControllerName = [vcDict valueForKey:kViewControllerName];
    return viewControllerName;
}

- (void)setViewControllerParam:(UIViewController *)vc byKey:(NSString *)aKey
{
    if (!self.propertyDict)
    {
        return;
    }
    
    NSDictionary *vcDict = [self.propertyDict valueForKey:aKey];
    if (!vcDict)
    {
        return;
    }
    
    if (![vc isKindOfClass:[UIViewController class]])
    {
        return;
    }
    
    @try
    {
        NSDictionary *param = [vcDict valueForKey:kParam];
        [vc setValuesForKeysWithDictionary:param];
    }
    @catch (NSException *exception)
    {
        DDLogError(@"ViewControllerMapping Error : %@", exception.description);
    }
}

- (id)getValuebyKey:(NSString *)aKey
{
    return [self.propertyDict valueForKey:aKey];
}

@end
