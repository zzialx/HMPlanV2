//
//  OrderManagerGrideViewController.m
//  WinChannelFrameWork
//
//  Created by ZhengJiepeng on 13-4-26.
//
//

#import "WSOrderManagerGrideViewController.h"
#import "WSStoreBean_prod.h"
#import "WSProdBean.h"

@interface WSOrderManagerGrideViewController ()

@property (nonatomic, strong) NSDictionary *orderInfoDic;

@end

@implementation WSOrderManagerGrideViewController

@synthesize orderInfoDic = _orderInfoDic;


- (id)initWithFuncs:(WSFuncsBean*)funcs orderInfoDic:(NSDictionary *)aOrderInfoDic {
    self = [super initWithFuncs:funcs];
    if (self) {
        self.orderInfoDic = aOrderInfoDic;
    }
    return self;
}

- (void)loadView {
    [super loadView];
}

- (NSArray *)getDataBaseDatas {

    return nil;
}

- (NSArray *)getDatasSources {
    if(self.moreProductArray == nil) {
        self.m_moreProdsCount = 0;
        self.moreProductArray =[[NSMutableArray alloc] init];
    }
    
    if(self.m_store_prod == nil)
        self.m_store_prod = [[NSMutableArray alloc] init];
    
    NSMutableArray *products = [[NSMutableArray alloc] initWithArray:[self getProductsWithBrand:self.iBrandId]];
    
    NSArray *pTypArray = [self getProdTypeArray];
    NSMutableArray *filterProducts = [NSMutableArray arrayWithCapacity:1];
    if (pTypArray && [pTypArray count] > 0) {
        for (NSString *pTyp in pTypArray) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.pTyp = %@", pTyp];
            [filterProducts addObjectsFromArray:[products filteredArrayUsingPredicate:predicate]];
        }
    }
    products = filterProducts;
    
    
    NSArray *ordDtlArray = [self.orderInfoDic objectForKey:@"ordDtl"];
    NSIndexSet *idxset = [products indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        WSProdBean *pb = (WSProdBean *)obj;
        NSString *pId = pb.Id;
        __block BOOL bfind = NO;
        [ordDtlArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSDictionary *dic = (NSDictionary *)obj;
            NSString *ordPId = nil;
            id temp = [dic objectForKey:@"prodid"];
            if ([temp isKindOfClass:[NSString class]]) {
                ordPId = temp;
            } else if ([temp isKindOfClass:[NSNumber class]]) {
                ordPId = [((NSNumber *)temp) stringValue];
            }
            if ([pId isEqualToString:ordPId]) {
                bfind = YES;
                *stop = YES;
            }
        }];
        return bfind;
    }];
    NSArray *ordProductBeans = [products objectsAtIndexes:idxset];
    NSMutableArray *moreProd = [NSMutableArray arrayWithArray:products];
    [moreProd removeObjectsAtIndexes:idxset];
    self.moreProductArray = moreProd;
    
    return ordProductBeans;
}

- (NSString *)getDatasFromDataBaseWithParam:(WSFuncsBean_Param *)aParam Data:(WSProdBean *)aProd {
    NSArray *ordDtlArray = [self.orderInfoDic objectForKey:@"ordDtl"];
    NSIndexSet *indexSet = [ordDtlArray indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *dic = (NSDictionary *)obj;
        NSString *prodid = @"";
        id temp = [dic objectForKey:@"prodid"];
        if ([temp isKindOfClass:[NSString class]]) {
            prodid = temp;
        } else if ([temp isKindOfClass:[NSNumber class]]) {
            prodid = [((NSNumber *)temp) stringValue];
        }
        if ([prodid isEqualToString:aProd.Id]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    
    NSArray *ordDtlItems = [ordDtlArray objectsAtIndexes:indexSet];
    if ([ordDtlItems count] > 0) {
        NSDictionary *item = [ordDtlItems objectAtIndex:0];
        id value = [item objectForKey:aParam.col];
        if ([value isKindOfClass:[NSString class]]) {
            return value;
        } else if ([value isKindOfClass:[NSNumber class]]) {
            return [((NSNumber *)value) stringValue];
        }
        return nil;
    }
    return nil;
}

@end
