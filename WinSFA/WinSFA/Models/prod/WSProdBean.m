//
//  ProdBean.m
//  WinChannelFrameWork
//
//  Created by winchannel on 11-11-21.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "WSProdBean.h"

@implementation WSProdBean

@synthesize brand = _brand;
@synthesize cod = _cod;
@synthesize Id = _Id;
@synthesize name = _name;
@synthesize pTyp = _pTyp;
@synthesize searchcod = _searchcod;
@synthesize url = _url;
@synthesize brandType = _brandType;
@synthesize price = _price;



- (id)initWithObject:(id)object{
    
    if (nil == object) {
        return nil;
    }
    
    self = [super init];
    
    if (self) {
        if ([object isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dic = (NSDictionary *)object;
            _brand = [NSString stringWithValue:[dic objectForKey:PRODS_BRAND]];
            _series = [NSString stringWithValue:[dic objectForKey:PRODS_SERIES]];
            _cod = [NSString stringWithValue:[dic objectForKey:PRODS_COD]];
            _Id = [NSString stringWithValue:[dic objectForKey:PRODS_ID]];
            _name = [NSString stringWithValue:[dic objectForKey:PRODS_NAME]];
            _pTyp = [NSString stringWithValue:[dic objectForKey:PRODS_PTYP]];
            _searchcod = [NSString stringWithValue:[dic objectForKey:PRODS_SEARCHCOD]];
            // 2017-12-13 兼容后台下发实时节点url对应字段为img_url的情况
            if ([NSString stringWithValue:[dic objectForKey:PRODS_REALTIME_IMG_URL]].length > 0) {
                _url = [NSString stringWithValue:[dic objectForKey:PRODS_REALTIME_IMG_URL]];
            }else{
                _url = [NSString stringWithValue:[dic objectForKey:PRODS_URL]];
            }
            _brandType = [[NSString stringWithValue:[dic objectForKey:PRODS_BRANDTYPE]] copy];
            _memo5 = [[NSString stringWithValue:[dic objectForKey:PRODS_MEMO5]] copy];
            _prodName = [[NSString stringWithValue:[dic objectForKey:PRODS_PRODNAME]] copy];
            _brandname = [[NSString stringWithValue:[dic objectForKey:PRODS_BRANDNAME]] copy];
            
            _price = [[dic objectForKey:PRODS_PRICE] copy];
            
            _memo = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO]];

             _memo1 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO1]];
             _memo2 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO2]];
             _memo3 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO3]];
             _memo4 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO4]];
             _memo6 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO6]];
             _memo7 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO7]];
             _memo8 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO8]];
             _memo9 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO9]];
             _memo10 = [NSString stringWithValue:[dic objectForKey:PRODS_MEMO10]];
            
            _prodtrees = [[NSString stringWithValue:[dic objectForKey:PRODS_TREES]] copy];
            
            _barcod = @"";
            NSString *barcode = [NSString stringWithValue:[dic objectForKey:PRODS_BARCOD]];
            if (barcode && [barcode length] > 0) {
                _barcod = barcode;
            }
            barcode = [NSString stringWithValue:[dic objectForKey:PRODS_BARCODE]];
            if (barcode && [barcode length] > 0) {
                _barcod = barcode;
            }
            
            _pinyin = [NSString stringWithValue:[dic objectForKey:PRODS_PINYIN]];

            _expirydate = [NSString stringWithValue:[dic objectForKey:PRODS_EXPIRYDATE]];
            
            _bigage = [NSString stringWithValue:[dic objectForKey:PRODS_BIGAGE]];
            
            _barcode2 = @"";
            NSString *barcode2 = [NSString stringWithValue:[dic objectForKey:PRODS_BARCODE2]];
            if (barcode2 && [barcode2 length] > 0) {
                _barcode2 = barcode2;
            }

        };
    }
    
    return self;
}

-(NSString *)description{
    return [NSString stringWithFormat:@"WSProdBean{brand=%@, cod=%@, Id=%@, name=%@, pTyp=%@ \nsearchcod=%@,url=%@,brandType=%@,memo5=%@,\nprodName=%@,brandname=%@}",
            self.brand,self.cod,self.Id,self.name,self.pTyp,
            self.searchcod,self.url,self.brandType,self.memo5,
            self.prodName,self.brandname ];
}

-(id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

#pragma mark - I_W_OptionDataItem
- (NSString *)getDataItemID {
    return self.Id;
}

- (NSString *)getDataItemName {
    return self.name;
}

- (NSString *)getDataItemDescName {
    return self.prodName;
}

- (NSString *)getDataItemUrl {
    return self.url;
}
- (NSString *)getCacheKeyID {
    return self.cacheKeyId;
}
@end
