//
//  WCDataPacker2.m
//  winCRM
//
//  Created by HZH on 16/9/11.
//  Copyright © 2016年 WinChannel. All rights reserved.
//

#import "WCDataPacker2.h"
#import "GTMBase64.h"
#import "NSData+ZIP.h"
#import "NSData+CommonCrypto.h"
#import "FBEncryptorAES.h"
#import "DecompressUtil.h"

static WCDataPacker2 *sharedInstance;
const NSString *InitStreetCode2 = @"8F, Block E, Dazhongsi Zhongkun Plaza, No. A18 West Beisanhuan Road, Haidian District, Beijing";

const UInt32 TypeCodeLength=2;
const UInt32 ErrorCodeLength=4;
const UInt32 ContentLenghtCodeLength=4;
const UInt32 FileLenghtCodeLength=4;

@implementation WCDataPacker2

+ (void)initialize {
    
    NSAssert([WCDataPacker2 class] == self, @"Incorrect use of singleton : %@, %@", [WCDataPacker2 class], [self class]);
    sharedInstance = [[WCDataPacker2 alloc] init];
}

+ (WCDataPacker2 *)sharedInstance {
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (NSData *)towPartSecretKey {
    NSData *firstPart = [InitStreetCode2 dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secondPart = [_InitHttpCode2 dataUsingEncoding:NSUTF8StringEncoding];
    if ((self.salt) && ([self.salt length])) {
        secondPart = [self.salt dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSMutableData *code = [NSMutableData dataWithData:[firstPart MD5Sum]];
    [code appendData:[secondPart MD5Sum]];
    
    return [NSData dataWithData:code];
}

- (NSData *)singlePartSecretKey {
    
    NSData *firstPart = [InitStreetCode2 dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *code = [NSMutableData dataWithData:[firstPart MD5Sum]];
    return [NSData dataWithData:code];
}


- (NSData *)secretKey:(BOOL)isTowPartKey {
    
    NSData *key = nil;
    
    if (isTowPartKey) {
        key = [self towPartSecretKey];
    }else {
        key = [self singlePartSecretKey];
    }
    
    return key;
    
}


- (NSData *)packForURLParam01:(NSString *)aURLParam
{
    return [self packForURLParam01:aURLParam isTowPartKey:YES];
}

- (NSData *)packForURLParam01:(NSString *)aURLParam isTowPartKey:(BOOL)isTowPartKey {
    
    NSData *key = [self secretKey:isTowPartKey];
    
    NSData *orgData = [aURLParam dataUsingEncoding:NSUTF8StringEncoding];
    // 1, zip
    NSData *zipData = [orgData zip];
    
    //    NSLog(@"[self secretKey] = %@", [self secretKey]);
    // 2, encrypt
    NSData *encryptData = [FBEncryptorAES encryptData:zipData key:key iv:nil keySize:key.length];
    
    return encryptData;
    
}

- (NSString *)unpackForResponseData:(NSData*)responseData
{

    NSData *key = [self secretKey:YES];
    
    NSString *tmpResponse = [[NSString alloc]
                   initWithData:responseData
                   encoding:NSUTF8StringEncoding];
    NSLog(@"tmpResponse = %@", tmpResponse);
    
//    NSLog(@"[self secretKey] = %@", [self secretKey]);
    // 1, decrypt
    NSData *decryptData01 = [FBEncryptorAES decryptData:responseData key:key iv:nil keySize:key.length];
    
    // 2, unzip
    NSData *unzipData01 = [decryptData01 unzip];
    
    NSString *deStr01 = [[NSString alloc] initWithData:unzipData01 encoding:NSUTF8StringEncoding];
    
    return deStr01;
}

- (NSData *)unpackForNormalResponseData:(NSData*)responseData
{
    return [self unpackForNormalResponseData:responseData isTowPartKey:YES];
}

- (NSData *)unpackForNormalResponseData:(NSData *)responseData isTowPartKey:(BOOL)isTowPartKey {
    
    NSData *key = [self secretKey:isTowPartKey];
    
    
    // 1, decrypt
    NSData *decryptData01 = [FBEncryptorAES decryptData:responseData key:key iv:nil keySize:key.length];
    
    // 2, unzip
    NSData *unzipData01 = [DecompressUtil uncompressZippedData:decryptData01];
    
    
    return unzipData01;
    
}

@end

