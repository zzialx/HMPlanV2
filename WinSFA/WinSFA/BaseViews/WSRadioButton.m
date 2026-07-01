//
//  WSRadioButton.m
//  WinSFA
//
//  Created by heju on 14-4-17.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSRadioButton.h"


@interface WSRadioButton ()


@property (nonatomic, assign)BOOL iIsObserver;
@property (nonatomic, assign)BOOL isRequired;

@end

@implementation WSRadioButton

@synthesize iNotificationPrefix = _iNotificationPrefix;
@synthesize iRow = _iRow;
@synthesize iColumn = _iColumn;
@synthesize iDataType = _iDataType;
@synthesize iDicNotificationName = _iDicNotificationName;
@synthesize iLogicType = _iLogicType;
@synthesize m_nRow = _m_nRow;
@synthesize m_nColumn = _m_nColumn;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

}

- (void)setNotificationPrefix:(NSString *)aNotificationPrefix
                       andRow:(unsigned int)aRow
                    andColumn:(unsigned int)aColumn
                  andDataType:(WSValidateDataDependType)aDataType
{
//    NSLog(@"%d--%s", __LINE__, __FUNCTION__);
    if (aNotificationPrefix == nil) return;
    
    self.iNotificationPrefix = aNotificationPrefix;
    //    self.iRow = aRow;
    //    self.iColumn = aColumn;
    self.m_nRow = aRow;
    self.m_nColumn = aColumn;
    self.iDataType = aDataType;
    
    if (self.iDataType == WSValidateDataDependOtherData){
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, aRow, aColumn];
        //        NSLog(@"notifyname = %@", notifyName);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateState:) name:notifyName object:nil];
    }
}

- (void)startObservingEntity
{
//    NSLog(@"%s---%d", __FUNCTION__, __LINE__);
}

- (void)updateState:(NSNotification *)sender
{
//    NSLog(@"%d--%s, %@", __LINE__, __FUNCTION__, sender);
    NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.m_nRow, self.m_nColumn];
    if (sender.name != nil && [sender.name isEqualToString:notifyName]) {
        NSNumber *number = (NSNumber *)sender.object;
        self.isRequired = [number boolValue];;
        [self setEnabled:self.isRequired];
    }
}

- (BOOL)entityIsEnable
{
    return [self isEnabled];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}

-(void)setCurSelected:(BOOL)selected
{
//    NSLog(@"setCurSelected :%d, col:%d, row:%d", selected, self.iColumn, self.iRow);
    [self setSelected:selected];
    
    if (self.iDataType == WSValidateDataIsDepended) {
        NSString *notifyName = [NSString stringWithFormat:@"%@-%d-%d", self.iNotificationPrefix, self.iRow, self.iColumn];
        [[NSNotificationCenter defaultCenter] postNotificationName:notifyName object:[NSNumber numberWithBool:selected]];
    }
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    _isClicked = YES;
}

//- (BOOL)isValueLegal
//{
//    return self.isRequired;
//}

@end
