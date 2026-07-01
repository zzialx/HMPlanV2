//
//  WSCellContentViewFactory.m
//  WinSFA
//
//  Created by winchannel on 15/5/6.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSCellContentViewFactory.h"
#import "I_W_BuildInfo.h"
#import "WSConstant.h"
#import "WSCellContentView.h"

@implementation WSCellContentViewFactory

+(id)shareInstance{
    static WSCellContentViewFactory  *_factory;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
       
        _factory =[[WSCellContentViewFactory alloc] init];
        
        
    });
    
    
    return _factory;
}

-(id)init{
    
    self =[super init];
    if (self) {
        
        [self registSpecialType];
        
         cellViewConfig =[[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cellViewMapping" ofType:@"plist"]];
    
        return self;
    
    }
    return nil;
}

-(void)setDefaultWidth:(CGFloat)width{
    
    default_width = width;
}

-(void)setParentAcvtType:(NSString *)parentType{
    
    parentAcvtType = parentType;
    
}



-(WSCellContentView *)createWidgetByWidgetInfo:(NSMutableArray *)cellcontentin{
    
    
    WSCellContentView  *cellcontentview=nil;
   
    NSString *keytype= [self hasKeyType:cellcontentin];
    
    NSString *mainType=@"";
    
    if (keytype!=nil && [keytype length]>0) {
        
        mainType = [NSString  stringWithFormat:@"%@_%@",parentAcvtType,keytype];
        
    }else{
        
        mainType = parentAcvtType;
    }
    
    NSString  *classname = [cellViewConfig valueForKey:mainType];
    
    cellcontentview = [[NSClassFromString(classname) alloc] initWithFrame:WSRect(0, 0,default_width,40)];
    
    NSString  *contentviewId=[NSString uniqueString];
    
    cellcontentview.assignedViewId = contentviewId;
    
    return cellcontentview;
}

-(void)registSpecialType{
    
    key_type_dict =[[NSMutableDictionary alloc] init];
    
    [key_type_dict setValue:@"LC" forKey:@"LC"];
    
}

-(NSString *)hasKeyType:(NSMutableArray *)array{
    
    for (int i=0; i<[array count]; i++) {
        
        NSObject<I_W_BuildInfo>  *buildInfo = [array objectAtIndex:i];
        
        NSString  *value=[key_type_dict valueForKey:[buildInfo getWidgetId]];
        if (value!=nil) {
            
            return value;
        }
    }
    return @"";
}


@end
