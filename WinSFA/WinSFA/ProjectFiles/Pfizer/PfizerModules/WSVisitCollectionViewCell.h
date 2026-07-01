//
//  WSVisitCollectionViewCell.h
//  WinSFA
//
//  Created by winchannel on 2018/3/12.
//  Copyright © 2018年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WSHosBean;
@interface WSVisitCollectionViewCell : UICollectionViewCell

- (void)setDataWithFuncsBean:(WSFuncsBean *)aFuncsBean
                 withHosBean:(WSHosBean *)aHosBean
           visitActionStatus:(VisitActionStatus)visitActionStatus
        isContaintDepartment:(BOOL)isContaint
                    isDoctor:(BOOL)isDoctor;
@end
