//
//  WSAcvtFactory.m
//  WinSFA
//
//  Created by winchannel on 15/3/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSWidgetFactory.h"
#import "WSWidgetObject.h"
#import "I_W_BuildInfo.h"
#import "WSWidget.h"

#define WIDGET_CONFIG_FILE [[NSBundle mainBundle]pathForResource:@"widget" ofType:@"plist"]

#define WIDGET_CLASS_KEY @"widget_class"

#define WIDGET_DATA_SOURCE_CLASS @"datasource_class"

#define WIDGET_DISPLAY_VALUE_KEY  @"displayvalue_class"

#define WIDGET_DATA_SOURCE_CLASS_M @"datasource_class_m"

#define WIDGET_VALIDATE_CLASS @"validate_class"

#define WIDGET_GROUP_VALIDATE_CLASS @"group_validate_class"

#define WIDGET_DESC_KEY  @"description"

#define DEFAULT_DATA_SOURCE @"Default"

@interface WSWidgetFactory (private)

-(void)initMappConfig;

@end

@implementation WSWidgetFactory


+(id)shareInstance{
    
    static WSWidgetFactory  *_factory;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        _factory = [[WSWidgetFactory alloc] init];
    
    });
    return _factory;
}


-(id)init{
    
    self = [super init];
    if (self) {
        
        [self initMappConfig];
        
        return self;
    }
    return nil;
}


-(void)initMappConfig{
    
    mapping_dict =[[NSMutableDictionary alloc] init];
    
    NSDictionary  *config_dict = [[NSDictionary alloc] initWithContentsOfFile:WIDGET_CONFIG_FILE];
    
    NSArray  *config_key_array  = [config_dict allKeys];
    
    for (int i=0; i<[config_key_array count]; i++) {
        WSWidgetObject *widgetobject = [[WSWidgetObject alloc] init];
        
        NSString *widgetkey =[config_key_array objectAtIndex:i];
        
        NSDictionary  *current_config_dict =[config_dict valueForKey:widgetkey];
        
        if (current_config_dict!=nil) {
            
            [widgetobject setWidgetId:widgetkey];
            
            [widgetobject setWidget_class:[current_config_dict valueForKey:WIDGET_CLASS_KEY]==nil ? @"" : [current_config_dict valueForKey:WIDGET_CLASS_KEY]];
            
            [widgetobject setDescriptionInfo:[current_config_dict valueForKey:WIDGET_DESC_KEY]==nil ? @"" : [current_config_dict valueForKey:WIDGET_DESC_KEY]];
            
            [widgetobject setDisplayValue_class:[current_config_dict valueForKey:WIDGET_DISPLAY_VALUE_KEY]==nil ? @"" : [current_config_dict valueForKey:WIDGET_DISPLAY_VALUE_KEY]];
            
            [widgetobject setValidate_class:[current_config_dict valueForKey:WIDGET_VALIDATE_CLASS]==nil ? @"" :[current_config_dict valueForKey:WIDGET_VALIDATE_CLASS]];
            
            [widgetobject setDatasource_class_m:[current_config_dict valueForKey:WIDGET_DATA_SOURCE_CLASS_M]==nil ? @"" : [current_config_dict valueForKey:WIDGET_DATA_SOURCE_CLASS_M]];
            
            [widgetobject setGroup_validate_class:[current_config_dict valueForKey:WIDGET_GROUP_VALIDATE_CLASS] == nil ? @"":[current_config_dict valueForKey:WIDGET_GROUP_VALIDATE_CLASS]];
            
            [mapping_dict setObject:widgetobject forKey:widgetkey];
            
        }
    }
}

-(WSWidget *)createWidgetByWidgetInfo:(NSObject<I_W_BuildInfo> *)widgetInfo{
    
    if (widgetInfo==nil) {
        
        return nil;
        
    }
    
    
    WSWidgetObject *object = [mapping_dict valueForKey:[widgetInfo getWidgetId]];
    
    if (object==nil) {
        
        return nil;
    }
    
    NSString  *widget_class_name = [object widget_class];
    
    WSWidget  *widget =(WSWidget *)[[NSClassFromString(widget_class_name) alloc] initWithFrame:[widgetInfo getLayOutInfo]];
    
    if ([widgetInfo isKindOfClass:[WSAcvtBean_qst class]]) {
        WSAcvtBean_qst *qstBean = (WSAcvtBean_qst *)widgetInfo;
        widget.widgetType = qstBean.widgetType;
    }

    [widget loadBuildInfo:widgetInfo];
  
    NSString *dsFormBuildInfo = [widgetInfo getDataSource];
    
    if ([object datasource_class_m]!=nil) {
        NSString *datasource_class = @"";

        if(dsFormBuildInfo == nil || [dsFormBuildInfo length] == 0){
            
            dsFormBuildInfo = DEFAULT_DATA_SOURCE;
        }
        
        datasource_class =[[object datasource_class_m] valueForKey:dsFormBuildInfo];   //结合考虑多个数据源的情况
        
        if (datasource_class && [datasource_class length] > 0) {
            NSObject<I_W_DataSource>  *datasource = [[NSClassFromString(datasource_class) alloc] init];  //结合考虑多个数据源的情况
            
            [widget loadDataSource:datasource];
        }
        
    }
    
    if ([object displayValue_class]!=nil && [[object displayValue_class] length]>0) {
        
        
        NSObject<I_W_DisplayValue> *displayValue = [[NSClassFromString([object displayValue_class]) alloc] init];
        
        [widget loadDisplayValue:displayValue];
        
    }
    
    if ([object validate_class]!=nil && [[object validate_class] length]>0) {
        
        
        NSObject<I_W_Validate> *validate = [[NSClassFromString([object validate_class]) alloc] init];
        
        [widget loadValidator:validate];
    }
    
    if ([object group_validate_class]!= nil && [[object group_validate_class] length] >0) {
        
        NSObject<I_W_Group_Validate> *groupValidate =[[NSClassFromString([object group_validate_class]) alloc]init];
        
        [widget loadGroupValidator:groupValidate];
    }
    [widget buildDisplayContent];
    
    return widget;
}

@end
