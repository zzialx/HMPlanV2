//
//  WSAnnotation.m
//  WinSFA
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSAnnotation.h"
#import "WSSalePersonModel.h"
#import "WSPerson4Store.h"
@implementation WSAnnotation

-(void)setSaleModel:(WSSalePersonModel *)saleModel{

    _saleModel = saleModel;
    
    self.coordinate = saleModel.coordinate;

}

-(void)setPersonModel:(WSPerson4Store *)personModel{
    
    _personModel = personModel;
    self.coordinate = personModel.coordinate;
    
}

@end
