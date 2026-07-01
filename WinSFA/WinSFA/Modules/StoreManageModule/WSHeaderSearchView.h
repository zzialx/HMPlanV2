//
//  WSHeaderSearchView.h
//  WinSFA
//
//  Created by heju on 14-10-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WSMappingObject.h"
#import "WSSearchBar.h"

typedef enum
{
    WSDefaultSearchType = 0,
    WSLocalSearchType = 1,
    WSAutoSearchType= 2,
    WSRemoteSearchType = 3,
    WSMultilevelMenuSearchType = 4,
    
}WSSearchRedisDataType;

@protocol WSHeaderSearchViewDelegate;


@interface WSHeaderSearchView : UIView <UISearchBarDelegate>

@property (nonatomic, strong) NSMutableArray *storeList;
@property (nonatomic, strong) WSFuncsBean *currentFuncs;
@property (nonatomic, strong) WSSearchBar *searchBar;
@property (nonatomic, assign)WSSearchRedisDataType currentSearchType;
@property (nonatomic, weak) id<WSHeaderSearchViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame  funcs:(WSFuncsBean*)funcs isSearchable:(NSString *)searchable  searchTag:(NSString *)searchTagText nativeStoreList:(NSArray *)storeList;


/*过滤后 在上传返回数据后 重新过滤*/
//- (NSMutableArray *)refilterDataIfSearchTagClickWith:(NSArray*)dbStores;
@end

@protocol WSHeaderSearchViewDelegate <NSObject>

- (NSArray *)headerSearchView:(WSHeaderSearchView *)view nativeSearch:(NSString *)text;

- (void)headerSearchView:(WSHeaderSearchView *)view remoteSearch:(NSString *)text isFromSearchLables:(BOOL)isFromLables;

- (void)headerSearchViewCancelButtonClicked:(WSHeaderSearchView *)view;

@optional
- (void)headerSearchViewTriggerKeyboardWillShowWithHeight:(NSNumber *)keyboardHeightNumber;

- (void)headerSearchViewTriggerKeyboardWillHideWithHeight:(NSNumber *)keyboardHeightNumber;

@end
