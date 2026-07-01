//
//  WSCheckBoxView.h
//  WinSFA
//
//  Created by dujinfeng481 on 14/12/22.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WSCheckBoxViewDelegate;

@interface WSCheckBoxView : UIView<WSValidateData>

@property (nonatomic, strong, readonly) WSAcvtBean_qst    *acvtBeanQstObject;
@property (nonatomic, strong, readonly) NSArray           *sourceArray;           //下拉列表数据源 WSStoreBean or WSDictBean
@property (nonatomic, strong) NSMutableArray              *optNameArray;
@property (nonatomic, assign) BOOL isValueChange;

- (id)initWithAcvtQstObject:(WSAcvtBean_qst*)qstObj
                      withX:(CGFloat)x
                      withY:(CGFloat)y
                  withWidth:(CGFloat)width
                withReqSign:(BOOL)isSign
     withSelectListDelegate:(id<WSCheckBoxViewDelegate>)delegate;

- (void) initializationOptionViewWithSouceArray:(NSArray*)array
                          withRedisplayContents:(NSArray*)redisplayStrs;

@end

@protocol WSCheckBoxViewDelegate <NSObject>

- (void) checkBoxView:(WSCheckBoxView*)checkBoxView didSelectIndexs:(NSArray*)selectIndexs;

@end
