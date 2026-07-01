//
//  ORMHelper.m
//  lechat
//
//  Created by lizhenjie on 12-6-26.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ORMHelper.h"
#include <objc/message.h>
#import <objc/objc.h>
#import "objc/objc-api.h"


@interface ORMHelper (private)
//动态设置值
-(id)setValueFor:(NSString *)column datatypeind:(NSInteger)ind result:(FMResultSet *)result;
//确定要调用得方法
-(SEL)confirmWithMethodWillbeCalling:(Class)myclass methodName:(NSString *)name;
//获得数据类型
-(NSString *) getPropertyType:(objc_property_t )property;

@end


@implementation ORMHelper 
@synthesize typeind;

-(void)dealloc{
    
    [typeind release];
    [super dealloc];
}

+(ORMHelper *)DefaultOrmHelper{
    
    static ORMHelper *_ormhelper=nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
    
        _ormhelper=[[ORMHelper alloc] init];
    });
    return _ormhelper;
}


-(id)init{
    
    self=[super init];
    if (self) {
        
        typeind=[[NSMutableDictionary alloc] init];
        

        [typeind setValue:@"0" forKey:@"Ti"]; //for integer data type;
        
        [typeind setValue:@"1" forKey:@"Td"]; //for double data type;
        
        [typeind setValue:@"2" forKey:@"Tq"]; //for long long int data type;
        
        [typeind setValue:@"3" forKey:@"Tl"]; //for long data type;
        
        [typeind setValue:@"4" forKey:@"Tf"]; //for float data type;
        
        [typeind setValue:@"5" forKey:@"TQ"]; // for unsigned long long int data type;
        
        [typeind setValue:@"6" forKey:@"Tc"];// for BOOL datatype;
        
        [typeind setValue:@"7" forKey:@"T@\"NSString\""];//for NSString data type;
        
        [typeind setValue:@"8" forKey:@"T@\"NSDate\""]; // for NSDate data type;
        
        [typeind setValue:@"9" forKey:@"T@\"NSData\""];// for NSData data type;
        
        [typeind setValue:@"10" forKey:@"T@"];//for id data type;
        
        [typeind setValue:@"11" forKeyPath:@"T@\"NSNumber\""];
        
    }
    return self;
}




-(id)transformResult:(FMResultSet *)resultset ToObject:(NSString *)classname{
   
    Class defineclass=NSClassFromString(classname);
   
    id selfdefineobj=[[defineclass alloc] init];
    
    unsigned int outcount;
    int i;
    objc_property_t *propertyX=class_copyPropertyList(defineclass, &outcount);//获得属性列表
    for (i=0; i<outcount; i++) {
        objc_property_t  currentproperty=propertyX[i];
        const char* propertyname=property_getName(currentproperty);
        
       
        NSString *objcname=[[NSString alloc] initWithCString:propertyname encoding:NSUTF8StringEncoding];
        
      
        NSString *methodlowercase=[NSMutableString stringWithFormat:@"%@%@:",@"set",objcname];
        
        SEL mysel=[self confirmWithMethodWillbeCalling:defineclass methodName:methodlowercase];
        
        NSString *datatype=[self getPropertyType:currentproperty]; 
        
        NSString *tind=[typeind valueForKey:datatype];
      
        id values=[self setValueFor:objcname datatypeind:[tind intValue]  result:resultset] ;
     
        
        [objcname release];
        
        if (values!=nil &&  mysel) {
            
            [self doDynamicCalling:selfdefineobj method:mysel andParam:values];
           
        }
    }
    
    return selfdefineobj;
    
}


-(void)doDynamicCalling:(id)instance method:(SEL)selector andParam:(NSObject *)param{
    
    
    NSMethodSignature   *singlenature = [instance methodSignatureForSelector:selector];
    
    NSInvocation   *invocation = [NSInvocation invocationWithMethodSignature:singlenature];
    
    [invocation setTarget:instance];
    
    [invocation setSelector:selector];
    
    [invocation setArgument:&param atIndex:2];
    
    [invocation invoke];
    
    
    
}


-(id)setValueFor:(NSString *)column datatypeind:(NSInteger)ind result:(FMResultSet *)result{
    
    id returnvalue=nil;
    switch (ind) {
        case 0: //int
            
            returnvalue=[[NSNumber alloc] initWithInt:[result intForColumn:column]==0 ? 0 :[result intForColumn:column]];
            
            break;
        
            
        case 1: //double
            
            returnvalue=[[NSNumber alloc] initWithDouble:[result doubleForColumn:column]];
            
            break;
            
        case 2: //longlong 
            returnvalue=[[NSNumber alloc] initWithLongLong:[result longLongIntForColumn:column]==0 ? 0 :[result longLongIntForColumn:column]];
            break;
            
        case 3://long
            
            returnvalue=[[NSNumber alloc] initWithLong:[result longForColumn:column]==0 ? 0 : [result longForColumn:column]];
            
            break;
        case 4: //float
            
            returnvalue=[[NSNumber alloc] initWithFloat:[result doubleForColumn:column]];
            break;
        case 5: //unsignedlonglongint
            
            returnvalue=[[NSNumber alloc] initWithUnsignedLongLong:[result unsignedLongLongIntForColumn:column]==0 ? 0 : [result unsignedLongLongIntForColumn:column]];
            break;
        case 6: //bool
            returnvalue=[[NSNumber alloc] initWithBool:[result boolForColumn:column]==NO ? NO : [result unsignedLongLongIntForColumn:column]];
            break;
        case 7: //string
                  returnvalue=(id)[result stringForColumn:column]==nil ? @"" : (id)[result stringForColumn:column];
            break;
        case 8: //date
            returnvalue=(id)[result dateForColumn:column];
            break;
        case 9: //data
            returnvalue=(id)[result dataForColumn:column];
            break;
        case 10: //id
            returnvalue=[result objectForColumnName:column];
            break;
        case 11:{
            
            
            returnvalue = [result objectForColumnName:column];
            
        }
            
            
            break;
            
        default:
            break;
    }

    return returnvalue ;
}

-(SEL)confirmWithMethodWillbeCalling:(Class)myclass methodName:(NSString *)name{
    unsigned int outcount;
    Method *methods=class_copyMethodList(myclass, &outcount);
    int i;
    for(i=0;i<outcount;i++){
        Method methodx=methods[i];
        SEL mesel=method_getName(methodx);
        NSString *methodinfo=NSStringFromSelector(mesel);

        if([name compare:methodinfo options:NSCaseInsensitiveSearch|NSNumericSearch]==NSOrderedSame){
            free(methods);
            return mesel;
        }
    }
    free(methods);
    return nil;
}

-(NSString *) getPropertyType:(objc_property_t )property {
    
    const char *attributes = property_getAttributes(property);
    NSString *typestring=[NSMutableString stringWithCString:attributes encoding:NSUTF8StringEncoding];
    NSArray *typecomponent=[typestring componentsSeparatedByString:@","];
    
    if ([typecomponent count]>0) {
        return (NSString *)[typecomponent objectAtIndex:0];
    }    
    return @"";
}

-(NSMutableDictionary *)transformNsObjectToMap:(NSObject *)obj{
    
    NSMutableDictionary *dict=[[[NSMutableDictionary alloc] init] autorelease];
    
    unsigned int outcount;
    int i;
    
    objc_property_t *propertyX=class_copyPropertyList([obj class], &outcount);//获得属性列表
    for (i=0; i<outcount; i++) {
        
        objc_property_t  currentproperty=propertyX[i];
        
        const char* propertyname=property_getName(currentproperty);
        
        NSString *objcname=[[[NSString alloc] initWithCString:propertyname encoding:NSUTF8StringEncoding] autorelease];
        
        NSString *methodlowercase=objcname;
        
        SEL method=NSSelectorFromString(methodlowercase);
        
        id value=((id (*)(id, SEL))objc_msgSend)(obj,method);
        
        [dict setValue:value==nil ? @"" :value forKey:objcname ];
    
    }
    
    return dict;

}
@end
