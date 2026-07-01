//
//  WSTableViewCell.m
//  WinSFA
//
//  Created by winchannel on 15/4/21.
//  Copyright (c) 2015年 WinChannel. All rights reserved.
//

#import "WSTableViewCell.h"
#import "I_W_Cell.h"
#import "I_W_BuildInfo.h"
#import "WSCellContentView.h"
#import "WSConstant.h"

#define DEFAULT_TYPE @"default";


@interface WSTableViewCell (private)

-(NSString *)hasKeyType:(NSMutableArray *)array;

@end

@implementation WSTableViewCell
@synthesize acvt_type;
@synthesize cell_delegate;


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier andAcvtType:(NSString *)acvt_typein{

    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    if (self) {
        
        [self registSpecialType];
        
        acvt_type = acvt_typein;
        
        cellViewConfig =[[NSMutableDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"cellViewMapping" ofType:@"plist"]];
        
        
        return self;
    }
    
    
    return nil;

}

-(void)registSpecialType{
    
    key_type_dict =[[NSMutableDictionary alloc] init];
    
    [key_type_dict setValue:@"LC" forKey:@"LC"];
    
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    
    [super setSelected:selected animated:animated];


}


-(void)clearDisplayContent{
    
    [cellcontentview clearContent];
    
}

-(void)loadDisplayContent:(NSObject<I_W_Cell> *)contentobject{
   

    [cellcontentview loadDisplayContent:contentobject];
    
}

-(void)setCellContent:(NSMutableArray *)cellcontentsin{
 
    cellcontents = cellcontentsin;
    
    NSString *keytype= [self hasKeyType:cellcontents];
    
    NSString *mainType=@"";
    
    if (keytype!=nil && [keytype length]>0) {
    
        mainType = [NSString  stringWithFormat:@"%@_%@",acvt_type,keytype];
    
    }else{
        
        mainType = acvt_type;
    }
    
    NSString  *classname = [cellViewConfig valueForKey:mainType];
    
    cellcontentview = [[NSClassFromString(classname) alloc] initWithFrame:WSRect(0, 0, self.frame.size.width, 40)];
    
    NSString  *contentviewId=[NSString uniqueString];
    
    cellcontentview.assignedViewId = contentviewId;
    
    cellcontentview.delegate = self;

    [self addSubview:cellcontentview];

    self.frame = WSRect(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, cellcontentview.size.height);
    
    
}



-(WSCellContentView *)getContentView{
    
    return cellcontentview;
}

//是否含有关键类型

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

#pragma mark -
#pragma mark WSWidgetDelegate method

-(void)executeInterAction:(WSInterAction *)interaction{
    

    if ([cell_delegate respondsToSelector:@selector(executeInterAction:)]) {
        
        [cell_delegate executeInterAction:interaction];
    }
    
}

-(void)showActionButton
{

}

@end
