//
//  WSAliyunUtil.m
//  WinSFA
//
//  Created by Alicia on 2017/4/19.
//  Copyright © 2017年 WinChannel. All rights reserved.
//

#import "WSAliyunUtil.h"
#import <AliyunOSSiOS/OSSService.h>
#import "WCLogger.h"

@implementation WSAliyunUtil {
    OSSClient *client;
}

+ (instancetype)sharedAliyunUtil {
    static WSAliyunUtil *aliyun = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        aliyun = [[WSAliyunUtil alloc] init];
    });
    return aliyun;
}


- (instancetype)init{
    self = [super init];
    if (self) {
        [self setupOSSClient];
    }
    return self;
}

- (void)setupOSSClient {
    NSString *keyId = [WSPlistHelper valueForKey:kAliyunAccessKey withPlistName:kConfilgFileName];
    NSString *keySecret = [WSPlistHelper valueForKey:kAliyunSecretKey withPlistName:kConfilgFileName];
    NSString *endPoint = [WSPlistHelper valueForKey:kAliyunEndPoint withPlistName:kConfilgFileName];
    
//#warning  明文设置secret的方式建议只在测试时使用，更多鉴权模式请参考后面的`访问控制`章节
//    id<OSSCredentialProvider> credential = [[OSSPlainTextAKSKPairCredentialProvider alloc]
//                                            initWithPlainTextAccessKey:keyId
//                                            secretKey:keySecret];

    
    id<OSSCredentialProvider> credential = [[OSSCustomSignerCredentialProvider alloc] initWithImplementedSigner:^NSString *(NSString *contentToSign, NSError *__autoreleasing *error) {
        NSString *signature = [OSSUtil calBase64Sha1WithData:contentToSign withSecret:keySecret];
        if (signature != nil) {
            *error = nil;
        } else {
            // construct error object
            *error = [NSError errorWithDomain:@"<your error domain>" code:OSSClientErrorCodeSignFailed userInfo:nil];
            return nil;
        }
        return [NSString stringWithFormat:@"OSS %@:%@", keyId, signature];
    }];
    
    client = [[OSSClient alloc] initWithEndpoint:endPoint credentialProvider:credential];
}



- (void)uploadImageToAliCloud:(NSString*)cloudKey localPath:(NSString*)localPath block:(void(^)(BOOL isSuccess, NSString* refCloudKey, NSError *error)) block {
    
    @try {
        
        NSData *uploadData = [[NSData alloc] initWithContentsOfFile:localPath];
        if (uploadData==nil) {
            @throw [[NSException alloc]initWithName:@"nofile" reason:@"file not exists" userInfo:nil];
        }
        
        
        OSSPutObjectRequest * put = [OSSPutObjectRequest new];
        put.bucketName = [WSPlistHelper valueForKey:kAliyunBucket withPlistName:kConfilgFileName];
        put.objectKey = cloudKey;
        put.uploadingData = uploadData;
        

//        put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
//            NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
//        };
        
        OSSTask * putTask = [client putObject:put];
        [putTask continueWithBlock:^id(OSSTask *task) {
            BOOL isSuccess;
            if (!task.error) {
                isSuccess = YES;
            } else {
                isSuccess = NO;
                LogError(@"upload object failed, error: %@", task.error);
            }
            
            if (block) {
                block(isSuccess,cloudKey,task.error);
            }
    
            return nil;
        }];
    }
    @catch (NSException *exception) {
        if (block) {
            NSError *error = [[NSError alloc]initWithDomain:exception.reason code:[exception.name isEqualToString:@"nofile"]?-100:-1 userInfo:nil];
            block(NO, cloudKey, error);
        }
    }
}


// 异步方式下载图片
-(void)downLoadAliCloudImage:(NSString*)cloudKey category:(NSString*)category localFileName:(NSString*)localFileName progress:(void(^)(NSInteger receivedSize, NSInteger expectedSize)) progressBlock completed:(void(^)(UIImage *image, NSError *error))completeBlock {
    @try {
        OSSGetObjectRequest * request = [OSSGetObjectRequest new];

        request.bucketName = [WSPlistHelper valueForKey:kAliyunBucket withPlistName:kConfilgFileName];
        request.objectKey = cloudKey;
      
        request.downloadProgress = ^(int64_t bytesWritten, int64_t totalBytesWritten, int64_t totalBytesExpectedToWrite) {
            if (progressBlock) {
                if (totalBytesExpectedToWrite > 0) {
                    progressBlock(totalBytesWritten, totalBytesExpectedToWrite);
                }
            }
        };
        if (localFileName && [localFileName length] > 0) {
            // 如果需要直接下载到文件，需要指明目标文件地址
            request.downloadToFileURL = [NSURL fileURLWithPath:localFileName];
        }
        
        OSSTask * getTask = [client getObject:request];
        [getTask continueWithBlock:^id(OSSTask *task) {
            if (!task.error) {
                OSSGetObjectResult * getResult = task.result;
                if (completeBlock) {
                    NSData *data = getResult.downloadedData;
                    UIImage *image = [UIImage imageWithData:data];
                    completeBlock(image, nil);
                }
            } else {
                LogError(@"download object failed, error: %@" ,task.error);
            }
            return nil;
        }];
    }
    @catch (NSException *exception) {
        if(completeBlock) {
            NSError *error = [NSError errorWithDomain:exception.description code:-1 userInfo:nil];
            completeBlock(nil, error);
        }
    }
}



@end
