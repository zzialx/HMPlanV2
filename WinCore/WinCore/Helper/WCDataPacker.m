//
//  WCDataPacker.m
//  WinSFA
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//

#import "WCDataPacker.h"
#import "GTMBase64.h"
#import "NSData+ZIP.h"

const NSString *InitStreetCode = @"8F, Block E, Dazhongsi Zhongkun Plaza, No. A18 West Beisanhuan Road, Haidian District, Beijing";
const NSString *InitHttpCode = @"http://www.winchannel.net";

static WCDataPacker *sharedInstance;
@implementation WCDataPacker

+ (void)initialize {
    NSAssert([WCDataPacker class] == self, @"Incorrect use of singleton : %@, %@", [WCDataPacker class], [self class]);
    sharedInstance = [[WCDataPacker alloc] init];
}

+ (WCDataPacker *)sharedInstance {
    return sharedInstance;
}

- (id)init {
    self = [super init];
    if (self) {
        
    }
    
    return self;
}

- (NSData *)secretKey {
    NSData *firstPart = [InitStreetCode dataUsingEncoding:NSUTF8StringEncoding];
    NSData *secondPart = [InitHttpCode dataUsingEncoding:NSUTF8StringEncoding];
    if ((self.salt) && ([self.salt length])) {
        secondPart = [self.salt dataUsingEncoding:NSUTF8StringEncoding];
    }
    
    NSMutableData *code = [NSMutableData dataWithData:[firstPart MD5Sum]];
    [code appendData:[secondPart MD5Sum]];
    
    return [NSData dataWithData:code];
}

- (NSData *)packForPostBody:(NSData *)aData {
    // 1, zip
    NSData *zipData = [aData zip];
    
    // 2, encrypt
    CCCryptorStatus error = kCCSuccess;
    NSData *encryptData = [zipData dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
                                                           key:[self secretKey]
                                                       options:(kCCOptionECBMode | kCCOptionPKCS7Padding)
                                                         error:&error];
    if (kCCSuccess != error) {
        return nil;
    }
    
    return encryptData;
}

- (NSData *)packForPostBodyNoZip:(NSData *)aData{
    // 2, encrypt
    CCCryptorStatus error = kCCSuccess;
    NSData *encryptData = [aData dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
                                                         key:[self secretKey]
                                                     options:(kCCOptionECBMode | kCCOptionPKCS7Padding)
                                                       error:&error];
    if (kCCSuccess != error) {
        return nil;
    }
    
    return encryptData;
}


- (NSData *)unpackForPostBody:(NSData *)aData {
    // 1, decrypt
    CCCryptorStatus error = kCCSuccess;
#if 0
    Byte *test = [aData bytes];
    unsigned short type;
    unsigned short dataerror;
    unsigned int contentLen;
    char a[4] = {0};
    a[0] = test[1];
    a[1] = test[0];
    memcpy(&type, a, 2);
    a[0] = test[3];
    a[1] = test[2];
    memcpy(&dataerror, a, 2);
    a[0] = test[7];
    a[1] = test[6];
    a[2] = test[5];
    a[3] = test[4];
    memcpy(&contentLen, a, 4);
    NSData *aaa = [NSData dataWithBytes:(test+8) length:contentLen];
#endif
    NSData *decryptData = [aData decryptedDataUsingAlgorithm:kCCAlgorithmAES128
                                                         key:[self secretKey]
                                                     options:(kCCOptionECBMode | kCCOptionPKCS7Padding)
                                                       error:&error];
    if (kCCSuccess != error) {
        return nil;
    }
    
    // 2, unzip
    NSData *unzipData = [decryptData unzip];
    
    return unzipData;
}

- (NSString *)packForURLParam:(NSString *)aURLParam {
    NSData *orgData = [aURLParam dataUsingEncoding:NSUTF8StringEncoding];
    // 1, zip
    NSData *zipData = [orgData zip];
    
    // 2, encrypt
    CCCryptorStatus error = kCCSuccess;
    NSData *encryptData = [zipData dataEncryptedUsingAlgorithm:kCCAlgorithmAES128
                                                           key:[self secretKey]
                                                       options:(kCCOptionECBMode | kCCOptionPKCS7Padding)
                                                         error:&error];
    if (kCCSuccess != error) {
        return nil;
    }
    
    // 3, base64 URL encoding
    NSString *base64EncodeString = [GTMBase64 stringByWebSafeEncodingData:encryptData padded:YES];
    return base64EncodeString;
}

- (NSString *)unpackForURLParam:(NSString *)aURLParam {
    // 1, base64 URL decoding
    NSData *decodeData = [GTMBase64 webSafeDecodeString:aURLParam];
    
    // 2, decrypt
    CCCryptorStatus error = kCCSuccess;
    NSData *decryptData = [decodeData decryptedDataUsingAlgorithm:kCCAlgorithmAES128
                                                              key:[self secretKey]
                                                          options:(kCCOptionECBMode | kCCOptionPKCS7Padding)
                                                            error:&error];
    if (kCCSuccess != error) {
        return nil;
    }
    
    // 2, unzip
    NSData *unzipData = [decryptData unzip];
    NSString *unzipString = [[NSString alloc] initWithData:unzipData encoding:NSUTF8StringEncoding];
    
    return unzipString;
}

- (UInt16)getResponseTypeTwoBytes:(const char *)aResponse
                                   offset:(NSInteger)aOffset
{
    UInt16 type = 0;
    memcpy(&type, (aResponse+aOffset), 2);
    return [WCDataPacker checkCPULittleEndian]?(ntohs(type)):type;
}

- (UInt32)getResponseErrorCodeFourBytes:(const char *)aResponse
                                 offset:(NSInteger)aOffset
{
    UInt32 errorCode = 0;
    memcpy(&errorCode, (aResponse+aOffset), 4);
    return [WCDataPacker checkCPULittleEndian]?(ntohl(errorCode)):errorCode;
}

- (UInt16)getResponseErrorCodeTwoBytes:(const char *)aResponse
                                        offset:(NSInteger)aOffset
{
    UInt16 errorCode = 0;
    memcpy(&errorCode, (aResponse+aOffset), 2);
    return [WCDataPacker checkCPULittleEndian]?(ntohs(errorCode)):errorCode;
}

- (UInt32)getResponseContentLengthCodeFourBytes:(const char *)aResponse
                                                 offset:(NSInteger)aOffset
{
    UInt32 contentLength = 0;
    memcpy(&contentLength, (aResponse+aOffset), 4);
    return [WCDataPacker checkCPULittleEndian]?(ntohl(contentLength)):contentLength;
}

- (NSData *)getResponseContent:(const char *)aResponse
                        offset:(NSInteger)aOffset
                        length:(UInt32)aLength

{
    NSData *content = [NSData dataWithBytes:(aResponse+aOffset) length:aLength];
    return content;
}

- (void)getResponseInfo:(const char *)aResponse
                   type:(UInt16 *)aType
              errorCode:(UInt32 *)aErrorCode
          contentLength:(UInt32 *)aContentLength
                content:(NSData **)aContent
{
    *aType = [self getResponseTypeTwoBytes:aResponse offset:0];
    *aErrorCode = [self getResponseErrorCodeFourBytes:aResponse offset:2];
    *aContentLength = [self getResponseContentLengthCodeFourBytes:aResponse offset:6];
    if(*aErrorCode == 0 || *aErrorCode == *aType * 1000)
    {
        *aContent = [self getResponseContent:aResponse offset:10 length:*aContentLength];
    }
}

//Tcp/ip:big endian; host:little endian
+ (int)checkCPULittleEndian
{
    union
    {
        unsigned int a;
        unsigned char b;
    }c;
    c.a = 1;
    return (c.b == 1);
}

// type : 2
// content len : 4
// content
// file len : 4
// file
- (NSData *)generatePost:(NSData *)aContent forType:(UInt16)aType {
    NSUInteger totalLen = 2 + 4 + [aContent length];
    char totalBytes[totalLen];
    
    UInt16 type = [WCDataPacker checkCPULittleEndian]?(htons(aType)):aType;
    UInt32 len = [WCDataPacker checkCPULittleEndian]?(htonl([aContent length])):[aContent length];
    
    memcpy(totalBytes, &type, 2);
    memcpy((totalBytes + 2), &len, 4);
    memcpy((totalBytes + 2 + 4), [aContent bytes], [aContent length]);
    NSData *totalData = [[NSData alloc] initWithBytes:totalBytes length:totalLen];

    return totalData;
}

// not support yet
- (NSData *)generatePost:(NSData *)aContent forType:(UInt16)aType withFile:(NSData *)aFile {
    NSUInteger totalLen = 2 + 4 + [aContent length] + 4 + [aFile length];
//    char totalBytes[totalLen];
    char *totalBytes = (char*)malloc(totalLen);
    memset(totalBytes, 0, totalLen);
    
    UInt16 type = [WCDataPacker checkCPULittleEndian]?(htons(aType)):aType;
    UInt32 len = [WCDataPacker checkCPULittleEndian]?(htonl([aContent length])):[aContent length];
    UInt32 len2 = [WCDataPacker checkCPULittleEndian]?(htonl([aFile length])):[aFile length];
    memcpy(totalBytes, &type, 2);
    memcpy((totalBytes + 2), &len, 4);
    memcpy((totalBytes + 2 + 4), [aContent bytes], [aContent length]);
    memcpy((totalBytes + 2 + 4 + [aContent length]), &len2, 4);
    memcpy((totalBytes + 2 + 4 + [aContent length] + 4), [aFile bytes], [aFile length]);
    NSData *totalData = [[NSData alloc] initWithBytes:totalBytes length:totalLen];
    
    free(totalBytes);
    return totalData;
}

@end
