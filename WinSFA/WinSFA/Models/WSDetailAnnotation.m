//
//  WSDetailAnnotation.m
//  WinSFA
//
//  Created by admin on 15/11/11.
//  Copyright © 2015年 WinChannel. All rights reserved.
//

#import "WSDetailAnnotation.h"
#import <CoreLocation/CoreLocation.h>
#import "WSSalePersonModel.h"
#import "WSPerson4Store.h"
@implementation WSDetailAnnotation

-(void)setSaleModle:(WSSalePersonModel *)saleModle{

    _saleModle = saleModle;
    
    self.coordinate = saleModle.coordinate;
    

}

-(void)setPersonModel:(WSPerson4Store *)personModel{
    
    _personModel = personModel;
    self.coordinate = personModel.coordinate;
    
}
@end
