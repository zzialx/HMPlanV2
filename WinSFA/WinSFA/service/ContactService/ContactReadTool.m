//
//  ContactReadTool.m
//  
//
//  Created by 李 振杰 on 13-7-17.
//  Copyright (c) 2013年 新视星空. All rights reserved.
//

#import "ContactReadTool.h"
#import "ContactModel.h"
#import "ChineseToPinyin.h"
#import "pinyin.h"


static ContactReadTool *readTool = nil;
@implementation ContactReadTool
@synthesize PersonAry;
+ (ContactReadTool *) getContactReadTool{
    if (readTool == nil) {
        readTool = [[self alloc ]init];
    }
    return readTool;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.PersonAry = [NSMutableArray array];
    }
    return self;
}
- (void)dealloc
{
    [PersonAry release];
    [super dealloc];
}

//读取联系人，并装入联系人模型中
- (void)reReadContact{

    if(ABAddressBookGetAuthorizationStatus()==kABAuthorizationStatusDenied){        
        NSString *message =[NSString stringWithFormat:NSLocalizedString(@"请到系统设置中的隐私->通讯录->%@,并打开相应设置，这样才能访问您的通讯录！", nil),APP_DISPLAY_NAME];
        
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:APP_DISPLAY_NAME message:message delegate:nil cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"confirm", nil), nil];
        
        [alert show];
        
        [alert release];
        return  ;
    }
    ABAddressBookRef abRef = nil;
    //IOS 6.0通讯录读取改变，判断版本后读取
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 6.0)
    {
        abRef = ABAddressBookCreateWithOptions(NULL, NULL);
        //等待同意后向下执行
        dispatch_semaphore_t sema = dispatch_semaphore_create(0);
        ABAddressBookRequestAccessWithCompletion(abRef, ^(bool granted, CFErrorRef error)
                                                 {
                                                     dispatch_semaphore_signal(sema);
                                                 });
        
        dispatch_semaphore_wait(sema, DISPATCH_TIME_FOREVER);
        dispatch_release(sema);
    }
    else
    {
        abRef = ABAddressBookCreate();
    }
    NSMutableArray * contactMutableAry = (NSMutableArray *)  ABAddressBookCopyArrayOfAllPeople(abRef);
    [PersonAry removeAllObjects];
    for (int i = 0; i < [contactMutableAry count]; i++) {
        NSAutoreleasePool * pol = [[NSAutoreleasePool alloc] init];
        ABRecordRef person = (ABRecordRef)[contactMutableAry objectAtIndex:i];
        ContactModel * contactModel = [[ContactModel alloc] init];
        //ID
        contactModel.PersonID = (NSInteger)ABRecordGetRecordID(person);
        
        //name
        NSString *firstName, *lastName, *middleName,*fullName;
        NSString * sysFirstName = (NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if(nil != sysFirstName){
            firstName = sysFirstName;
        }else{
            firstName = @"" ;
        }
        NSString * sysMiddleName = (  NSString *)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
        if (nil != sysMiddleName) {
            middleName = sysMiddleName;
        }else {
            middleName = @"" ;
        }
        NSString * sysLastName = (  NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if(nil != sysLastName){
            lastName = sysLastName;
        }else{
            lastName = @"";
        }
        
        fullName = [NSString stringWithFormat:@"%@%@%@",lastName,middleName,firstName];
        [sysFirstName release];
        [sysMiddleName release];
        [sysLastName release];
        
        
        //首字母 和 姓名拼音
        NSString * FirstLetter = nil;
        NSString * NameLetter = nil;
        NSAutoreleasePool * po = [[NSAutoreleasePool alloc] init];
        if (fullName.length == 0 || fullName == nil) {
            fullName =@"无姓名";
            NameLetter = @"";
            FirstLetter = @"#";
        }else {
            FirstLetter = [[NSString stringWithFormat:@"%c",pinyinFirstLetter([fullName characterAtIndex:0])] uppercaseString];
            NameLetter = [ChineseToPinyin pinyinFromChiniseString:fullName];
        }
        if (![self isValidateName:FirstLetter]) {
            FirstLetter = @"#";
        }
        contactModel.PersonName = fullName;
        contactModel.PersonNameFirstLetter = FirstLetter;
        contactModel.PersonNameLetter = NameLetter;
        [po drain];
        //头像
        NSData *imageData = (NSData * )ABPersonCopyImageData(person);
        contactModel.PersonImageData = imageData;
        [imageData release];
        ABMultiValueRef phone =  (ABMultiValueRef)ABRecordCopyValue(person, kABPersonPhoneProperty);
        if ((phone != nil)&&ABMultiValueGetCount(phone)>0) {
            for (int m = 0; m < ABMultiValueGetCount(phone); m++) {
                //aPhone stringByReplacingOccurrencesOfString 返回一个autorelease对象，所以此处只能为它加Autorelease且添加释放池。
                NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
                NSString * aPhone = [(NSString *)ABMultiValueCopyValueAtIndex(phone, m) autorelease];
                aPhone = [aPhone stringByReplacingOccurrencesOfString :@" " withString:@""];
                aPhone = [aPhone stringByReplacingOccurrencesOfString :@"(" withString:@""];
                aPhone = [aPhone stringByReplacingOccurrencesOfString :@")" withString:@""];
                aPhone = [aPhone stringByReplacingOccurrencesOfString :@"-" withString:@""];
                NSString * phoneLab = nil;
                NSString * aLabel = (NSString *)ABMultiValueCopyLabelAtIndex(phone, m);
                if ([aLabel isEqualToString:@"_$!<Mobile>!$_"]) {
                    phoneLab = @"mobile";
                }
                else if([aLabel isEqualToString:@"_$!<Home>!$_"]){
                    phoneLab = @"tel";
                }
                else if([aLabel isEqualToString:@"_$!<Work>!$_"]){
                    phoneLab = @"worktel";
                }
                else if([aLabel isEqualToString:@"_$!<Main>!$_"]){
                    phoneLab = @"maintel";
                }
                else if([aLabel isEqualToString:@"_$!<HomeFAX>!$_"]){
                    phoneLab = @"homefax";
                }
                else if([aLabel isEqualToString:@"_$!<WorkFAX>!$_"]){
                    phoneLab = @"workfax";
                }
                else {
                    phoneLab = @"othernumber";
                }
               
                [aLabel release];
                PhoneAndLabel * phoneRow = [[PhoneAndLabel alloc] init];
                phoneRow.phoneNum = aPhone;
                phoneRow.phoneLabel = phoneLab;
                [contactModel.PhoneLabelAry addObject:phoneRow];
                [phoneRow release];
                [pool drain];
            }
        }
       CFRelease(phone);
        [PersonAry addObject:contactModel];
        [contactModel release];
        [pol drain];
    }
    [contactMutableAry release];
    
}

-(BOOL)isValidateName:(NSString *)name {
    NSString *nameRegex = @"[A-Z]";
    NSPredicate *namelTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", nameRegex];
    return [namelTest evaluateWithObject:name];
}



@end
