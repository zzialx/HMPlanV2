
//
//  XNMainUser.m
//  xiaonei
//
//  Created by sam wang on 13-2-28.
//  Copyright (c) 2013年 winchannel.net. All rights reserved.
//


#import "WCMainUser.h"
#import "WCLogger.h"
#import "NSKeyedUnarchiver+ExceptionCatch.h"

// 最后一次登录的用户ID
#define kLastLoginUserId            @"kLastLoginUserId"
// mainUser持久化文件名
#define kMainUserFileName @"user"

static WCMainUser * _instance = nil;

@implementation WCMainUser

@synthesize loginAccount = _loginAccount;
@synthesize ticket = _ticket;
@synthesize sessionKey = _sessionKey;
@synthesize mprivateSecretKey = _mprivateSecretKey;
@synthesize md5Password = _md5Password;
@synthesize checkIsNewUser = _checkIsNewUser;
@synthesize needSetIndependentPwd = _needSetIndependentPwd;
@synthesize domainName = _domainName;
@synthesize sessionId = _sessionId;
@synthesize isFirstLogin = _isFirstLogin;
@synthesize userId = _userId;

+ (WCMainUser *) getInstance {
	@synchronized(self) {
        
		if (_instance == nil) {
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSNumber *userId = [defaults objectForKey:kLastLoginUserId];
            
            if (userId) {
                _instance = [WCMainUser readFromDisk:userId];
                if (!_instance) {
                    _instance = [[WCMainUser alloc] init]; // assignment not done here
                }
            } else {
                // 从未登录过的逻辑
                _instance = [[WCMainUser alloc] init];
            }
		}
	}
	return _instance;
}

- (id) init
{
	if (self = [super init]){
        [self clear];
        self.userId = [NSNumber numberWithInteger:0];
	}
	return self;
}


- (void) dealloc
{
}

- (void) clear
{
	self.ticket = nil;
	self.md5Password = nil;
    self.domainName = nil;
	
	self.isFirstLogin = nil;
	


	
    // 清空新用户引导判断
    self.checkIsNewUser = NO;
    
    self.needSetIndependentPwd = NO;
    // MainUser是被持久化的，如果新添加了成员一定要在注销时干掉它
    self.sessionId = nil;
}

#pragma mark -
#pragma mark Public
- (void)persist {
    NSNumber *userId = self.userId;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userId forKey:kLastLoginUserId];
    [defaults synchronize];
    
    if (userId) {
        NSString *persistPath = [WCMainUser persistPath:userId];
        [NSKeyedArchiver archiveRootObject:self toFile:persistPath];
    }
}

// 从持久化数据中读取mainUser
+ (WCMainUser *)readFromDisk:(NSNumber *)userId{
    NSString *userFile = [WCMainUser persistPath:userId];
    return [NSKeyedUnarchiver unarchiveObjectWithFile:userFile exception_p:NULL];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)logout {
    @synchronized(self)
    {
        WCMainUser *mainUser = _instance;
        NSNumber *userId = [self.userId copy];
        [mainUser clear];
        self.userId = nil;
        if (userId) {
            NSString *persistPath = [WCMainUser persistPath:userId];
            NSFileManager *fileMgr = [NSFileManager defaultManager];
            [fileMgr removeItemAtPath:persistPath error:nil];
        }
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:kLastLoginUserId];
        [defaults removeObjectForKey:@"lastUserTicket"];
        [defaults synchronize];
        
    }
}

- (BOOL)isMainUserId:(NSNumber*)anUserId {
	// 在没有id的情况的, 将默认是mainuser
	if (!anUserId) {
		return YES;
	}
	
	if (!self.userId) {
		return NO;
	}
	
	return NSOrderedSame == [self.userId compare:anUserId] ? YES : NO;
}

#pragma mark -
#pragma mark NSCoding methods
///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithCoder:(NSCoder *)decoder {
	if (self = [super init]) {
		self.ticket = [decoder decodeObjectForKey:@"ticket"];
		self.sessionKey = [decoder decodeObjectForKey:@"msessionKey"];
		self.mprivateSecretKey = [decoder decodeObjectForKey:@"mprivateSecretKey"];
		self.loginAccount = [decoder decodeObjectForKey:@"loginAccount"];
		self.md5Password = [decoder decodeObjectForKey:@"md5Password"];
        self.checkIsNewUser = [decoder decodeBoolForKey:@"checkIsNewUser"];
        self.needSetIndependentPwd = [decoder decodeBoolForKey:@"fillstage"];
        self.domainName = [decoder decodeObjectForKey:@"domainName"];
		self.isFirstLogin = [decoder decodeObjectForKey:@"isFirstLogin"];
	}
	return self;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)encodeWithCoder:(NSCoder*)encoder {
	[encoder encodeObject:self.loginAccount forKey:@"loginAccount"];
	[encoder encodeObject:self.md5Password forKey:@"md5Password"];
	[encoder encodeObject:self.ticket forKey:@"ticket"];
	[encoder encodeObject:self.sessionKey forKey:@"msessionKey"];
	[encoder encodeObject:self.mprivateSecretKey forKey:@"mprivateSecretKey"];
    [encoder encodeBool:self.checkIsNewUser forKey:@"checkIsNewUser"];
    [encoder encodeBool:self.needSetIndependentPwd forKey:@"fillstage"];
    [encoder encodeObject:self.domainName forKey:@"domainName"];
	[encoder encodeObject:self.isFirstLogin forKey:@"isFirstLogin"];
	
}

- (BOOL) checkLoginInfo
{
	if (self.sessionKey && self.mprivateSecretKey) {
		return YES;
	}
    else {	
        return NO;
    }
}



// App Document 路径
+ (NSString *)documentPath{
    NSArray *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [searchPath objectAtIndex:0];
    return path;
}
// 持久化路径
+ (NSString *)persistPath:(NSNumber *)userId{
    NSString *dirPath = [[WCMainUser documentPath] stringByAppendingPathComponent:[userId stringValue]];
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:dirPath]) {
        NSError *error = nil;
        [fileMgr createDirectoryAtPath:dirPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
        if (error) {
            NSLog(@"创建 userDocumentPath 失败 %@", error);
        }
    }
    
    NSString *path = [dirPath stringByAppendingPathComponent:kMainUserFileName];
    return path;
}


@end


