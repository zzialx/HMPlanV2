//
//  WSHeaderSearchView.m
//  WinSFA
//
//  Created by heju on 14-10-23.
//  Copyright (c) 2014年 WinChannel. All rights reserved.
//

#import "WSHeaderSearchView.h"
#import "WSAddStoreTable.h"
#import "WSAddStoreQstTable.h"
#import "WSAcvtBean_qst_opt.h"
#import "WSSearchTagFilterView.h"


#define k_LocalShowCount 0
#define k_SearchBarHeight 44
#define k_ScrollViewHeight 26

#define k_ButtonSpace 20.0f
#define k_MargeWidth  10.0f


#define k_SearchAlertLabel_yOffset  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : 40)
#define k_SearchAlertLabel_Width  ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : 170)

#define k_SearchAlertLabelHeight k_ScrollViewHeight

#define k_ScrollView_xOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 0 : 170)

#define k_ScrollView_yOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? k_SearchBarHeight : 40.)

#define k_ScrollView_Width ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 320 : 516)

#define k_ScrollView_CornerRadius ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 5.0f : 10.f)


#define k_TagButton_YOffset ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) ? 5 : 5)

#define k_FilterButton_Width (INTERFACE_IS_PAD ? 60.0f : 60.0f)

#define k_SearchTagView_Width (INTERFACE_IS_PAD ? 320.0f : 275.0f)

@interface WSHeaderSearchView () <WSSearchTagFilterViewDelegate>
@property (nonatomic, strong) NSMutableString *searchContent;
@property (nonatomic, strong) NSMutableArray *databaseStoreList;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *searchTags;
@property (nonatomic, strong) NSString *searchTagText;
@property (nonatomic, assign) CGFloat scrollViewContentWidth;
@property (nonatomic, strong) WSAcvtBean *filterdAcvtBean;
@property (nonatomic, strong) NSArray *searchFilterViewSelectedTagArray;
@end

@implementation WSHeaderSearchView

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (id)initWithFrame:(CGRect)frame  funcs:(WSFuncsBean*)funcs isSearchable:(NSString *)searchable  searchTag:(NSString *)searchTagText nativeStoreList:(NSArray *)storeList;

{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        if ( !_currentFuncs) {
            self.currentFuncs = [[WSFuncsBean alloc]init];
        }
        self.currentFuncs = funcs;
        _storeList = [(NSMutableArray *)storeList copy];
        _databaseStoreList = [(NSMutableArray *)storeList copy];
        _searchTagText = searchTagText;
        self.currentSearchType = WSDefaultSearchType;
        
        NSInteger serverCount = k_LocalShowCount;
        if (self.currentFuncs.opt.serverCount) {
            serverCount = [self.currentFuncs.opt.serverCount integerValue];
        }
        if (searchable) {
            if (([searchable isEqualToString:FUNCS_OPT_Local] && self.storeList && [self.storeList count] > serverCount)) {
                self.currentSearchType = WSLocalSearchType;
            } else if ([searchable isEqualToString:FUNCS_OPT_Auto]) {
                self.currentSearchType = WSAutoSearchType;
            } else if ([searchable isEqualToString:FUNCS_OPT_Remote ]) {
                self.currentSearchType = WSRemoteSearchType;
            }else if ([searchable isEqualToString:FUNCS_OPT_MultilevelMenuSearch ]) {
                self.currentSearchType = WSMultilevelMenuSearchType;
            }
            
        }
        
        if (self.currentSearchType == WSDefaultSearchType) {
            return nil;
        }

        self.backgroundColor = k_SearchBarBgColor;
        _searchBar =  [self createSearchBarWithFrame:frame];
        [self addSubview:_searchBar];
        
        if ([searchTagText length] > 0) {
            

            UIButton *button = [self createFilterButton];
            CGRect frame = _searchBar.frame;
            frame.size.width -= button.width + 5;
            _searchBar.frame = frame;
            [self addSubview:button];
        }
        
        
        /*区别于中间的搜索标签，是对其搜索标签的说明*/
        UILabel *leftAlterLabel = [self createLeftSearchAlterLabel];
        if (leftAlterLabel && INTERFACE_IS_PAD) {
            [self addSubview:leftAlterLabel];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    return self;
}

- (WSSearchBar *)createSearchBarWithFrame:(CGRect)frame {
    WSSearchBar *searchBar = [[WSSearchBar alloc] initWithFrame:CGRectMake(0.0, 0.0,frame.size.width, k_SearchBarHeight) isResetTextField:NO isResetBackgroundColor:YES isTop:NO isNotAutoresizingFlexible:YES];
    searchBar.searchBar.delegate = self;
    searchBar.searchBar.placeholder = self.currentFuncs.opt.searchHint;

    if(INTERFACE_IS_PAD){
        self.searchBar.searchBar.placeholder = NSLocalizedString(@"query_label", nil);
    }
    return  searchBar;
}

- (UILabel *)createLeftSearchAlterLabel {
    NSString *alertText = self.currentFuncs.opt.searchTagAlert;
    if (alertText) {
        UILabel *alertLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, k_SearchAlertLabel_yOffset ,k_SearchAlertLabel_Width, k_SearchAlertLabelHeight)];
        alertLabel.textAlignment = NSTextAlignmentCenter;
        alertLabel.text = alertText;
        return alertLabel;
    }
    return nil;
}

- (UIButton *)createFilterButton {
    
    CGFloat x;
    if (INTERFACE_IS_PHONE) {
        x = self.width - k_FilterButton_Width - 5;
    }else {
        x = self.searchBar.right - k_FilterButton_Width -5;
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, 5, k_FilterButton_Width, k_SearchBarHeight - 10)];
    [button setBackgroundColor:MAIN_TINT_COLOT];
    [button setTitle:NSLocalizedString(@"w_filter", nil) forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:UI_Font];
    [button addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 5.0f;
    
    return button;
    
}

- (void)filterAction:(UIButton *)sender {
    
    if ([_searchBar isFirstResponder]) {
        [_searchBar resignFirstResponder];
    }
    
    UIView *rootView ;
    

    WSAppDelegate *delegate = (WSAppDelegate *)[UIApplication sharedApplication].delegate;
    if (delegate.window.rootViewController.presentedViewController) {
        rootView = delegate.window.rootViewController.presentedViewController.view;
    }else{
        rootView = delegate.window.rootViewController.view;
    }
   
    WSSearchTagFilterView *searchTagView = [[WSSearchTagFilterView alloc] initWithFrame:CGRectMake(rootView.bounds.size.width - k_SearchTagView_Width, 0, k_SearchTagView_Width, rootView.bounds.size.height) searchTagString:_searchTagText];
    [searchTagView setSelectedSearchTagArray:self.searchFilterViewSelectedTagArray];
    searchTagView.delegate = self;
    [searchTagView showOnView:rootView];
    
}


- (void)createScorllViewWithFrame:(CGRect)frame {
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(k_ScrollView_xOffset, k_ScrollView_yOffset,k_ScrollView_Width, k_ScrollViewHeight)];
    CGFloat contentWith = [self scrollViewContentWidth:self.searchTagText];
    _scrollView.contentSize = CGSizeMake(contentWith,k_ScrollViewHeight);
    /*
    _scrollView.pagingEnabled = YES;
     */
    _scrollView.layer.borderColor = [[UIColor lightGrayColor] CGColor];
    _scrollView.layer.borderWidth = 1.0f;
    _scrollView.layer.cornerRadius = k_ScrollView_CornerRadius;
    _scrollView.scrollEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.clipsToBounds = YES;
    _scrollView.bounces = NO;
}

- (CGFloat)scrollViewContentWidth:(NSString *)searchTagText {
    _scrollViewContentWidth= 2*k_MargeWidth;
    CGFloat tagBtnX = 0;
    if (!_searchTags) {
        self.searchTags = [[NSArray alloc] init];
    }
    if (searchTagText && [searchTagText length] > 0) {
        self.searchTags = [searchTagText componentsSeparatedByString:@"@"];
    }
    // create subButtons
    for (NSInteger i = 0; i < [self.searchTags count]; i++) {
        NSString *subSearchTag = [self.searchTags objectAtIndex:i];
        if (i == 0) {
            tagBtnX += k_MargeWidth;
        }
        CGFloat searchButtonWidth = [self buttonWidthWith:subSearchTag];
        UIButton *subTagButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        [subTagButton setFrame:CGRectMake(tagBtnX, 5, searchButtonWidth, k_ScrollViewHeight - 5*2)];
        tagBtnX += searchButtonWidth + k_ButtonSpace;
        if (i != [self.searchTags count] - 1) {
            _scrollViewContentWidth += searchButtonWidth + k_ButtonSpace;
        } else {
            _scrollViewContentWidth += searchButtonWidth;
        }
        [subTagButton setTitle:subSearchTag forState:UIControlStateNormal];
        [subTagButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        subTagButton.tag = i;
        [subTagButton addTarget:self action:@selector(searchTagButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:subTagButton];
    }
    return _scrollViewContentWidth;
}

- (CGFloat)buttonWidthWith:(NSString *)title {
    CGSize bSize = [title ws_sizeWithFont:[UIFont systemFontOfSize:UI_Font] constrainedToHeight:CGRectGetHeight(_scrollView.frame) lineBreakMode:NSLineBreakByWordWrapping];
    
    return bSize.width;
}

- (BOOL)isUploadGeoLocationInfo {
    
    if ([self.currentFuncs.opt.isOpenGeo isEqualToString:@"Y"]){
        return YES;
    }
    return NO;
}


#pragma mark SearchTagButton Clicked Methods

- (void)searchTagButtonClicked:(id)sender {
    
    if ([_searchBar canBecomeFirstResponder]) {
        if (![_searchBar isFirstResponder] ) {
            
            UIWindow *currentWindow = [[UIApplication sharedApplication] keyWindow];
            
            NSLog(@"currentWindow---%@",currentWindow);
            
            
             NSLog(@"_searchBar.window---%@",_searchBar.window);
            [_searchBar.window makeKeyAndVisible];
            [_searchBar becomeFirstResponder];
        }
    }
    if (sender) {
        if (!_searchContent) {
            self.searchContent =[NSMutableString string];
        }
        UIButton *clickBtn = (UIButton *)sender;
        clickBtn.selected = !clickBtn.selected;
        NSInteger clickTag = clickBtn.tag;
        NSString *searchTag = [self.searchTags objectAtIndex:clickTag];
        if (clickBtn.selected) {
            if ([self.searchContent length] == 0) {
                [self.searchContent appendString:[NSString stringWithFormat:@"%@ ",searchTag]];
            } else {
                NSString *lastCharacter = [self.searchContent substringFromIndex:[self.searchContent length]-1];
                if (![lastCharacter isEqualToString:@" "]) {
                    [self.searchContent appendString:[NSString stringWithFormat:@" %@ ",searchTag]];
                } else {
                    [self.searchContent appendString:[NSString stringWithFormat:@"%@ ",searchTag]];
                }
            }
            
        } else {
            NSString *removeSearchTag = [NSString stringWithFormat:@"%@ ",searchTag];
            NSRange removeSearchTagRang = [self.searchContent rangeOfString:removeSearchTag];
            if (removeSearchTagRang.location != NSNotFound) {
                [self.searchContent replaceOccurrencesOfString:[NSString stringWithFormat:@"%@ ",searchTag] withString:@"" options:NSLiteralSearch range:NSMakeRange(0, [self.searchContent length])];
            }
        }
        self.searchBar.searchBar.text = self.searchContent;
    }
    
}

- (void)changeSearchTagButtonsStateNormal {
    for (UIButton *subButton in self.scrollView.subviews) {
        if (subButton.selected) {
            subButton.selected =  NO;
        }
    }
}

#pragma UISearchBarDelegate Methods
- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    if ([searchBar.text isEqualToString:@" "]) {
        searchBar.text = nil;
    }
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:YES animated:YES];
    
    
    if ([self isUploadGeoLocationInfo]) {
        searchBar.text = @" ";
    }
    
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText{
    if (!_searchContent) {
        self.searchContent =[NSMutableString string];
    }
    if ([self.searchContent length] == 0) {
        self.searchContent = [NSMutableString stringWithString:searchText];
    } else if ([self.searchContent length] > 0) {
        self.searchContent = [NSMutableString stringWithFormat:@"%@",searchText];
    }
    if ( [searchText length] == 0) {
        [self changeSearchTagButtonsStateNormal];
    }
    
    if (self.currentSearchType == WSLocalSearchType) {
        if ([_delegate respondsToSelector:@selector(headerSearchView:nativeSearch:)]) {
            [_delegate headerSearchView:self nativeSearch:searchBar.text];
        }
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
    
    [self searchWithText:searchBar.text isFromSearchLabels:NO];
}



- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.text = @"";
    self.searchContent =  [NSMutableString stringWithString:@""];
    [self changeSearchTagButtonsStateNormal];
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];

    if ([_delegate respondsToSelector:@selector(headerSearchViewCancelButtonClicked:)]) {
        [_delegate headerSearchViewCancelButtonClicked:self];
    }
}


- (void)searchWithText:(NSString *)searchText isFromSearchLabels:(BOOL)isFromTag
{
    switch (self.currentSearchType) {
        case WSLocalSearchType:{
            if ([_delegate respondsToSelector:@selector(headerSearchView:nativeSearch:)]) {
                [_delegate headerSearchView:self nativeSearch:searchText];
            }
        }
            break;
        case WSAutoSearchType: {
            [self autoSearchStores:searchText isFromSearchLables:isFromTag];
        }
            break;
        case WSRemoteSearchType: {
            if ([_delegate respondsToSelector:@selector(headerSearchView:remoteSearch: isFromSearchLables:)]) {
                [_delegate headerSearchView:self remoteSearch:searchText isFromSearchLables:isFromTag];
            }
        }
            break;
            
        case WSMultilevelMenuSearchType:{
            if ([_delegate respondsToSelector:@selector(headerSearchView:nativeSearch:)]) {
                [_delegate headerSearchView:self nativeSearch:searchText];
            }
        }
            break;
        default:
            break;
    }
}

- (void)keyboardWillShow:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    
    if ([_delegate respondsToSelector:@selector(headerSearchViewTriggerKeyboardWillShowWithHeight:)]) {
        [_delegate performSelector:@selector(headerSearchViewTriggerKeyboardWillShowWithHeight:) withObject:[NSNumber numberWithFloat:kbSize.height]];
    }
    
}

- (void)keyboardWillHide:(NSNotification *)notification {
    
    NSDictionary *info = [notification userInfo];
    
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;//得到键盘的高度
    
    if ([_delegate respondsToSelector:@selector(headerSearchViewTriggerKeyboardWillHideWithHeight:)]) {
        [_delegate performSelector:@selector(headerSearchViewTriggerKeyboardWillHideWithHeight:) withObject:[NSNumber numberWithFloat:kbSize.height]];
    }
    
}

//  自动搜索:若本地没有搜出来数据则服务器搜索
- (void)autoSearchStores:(NSString *)searchText isFromSearchLables:(BOOL)isFromLabels{

    NSArray *localResult;
    if ([_delegate respondsToSelector:@selector(headerSearchView:nativeSearch:)]) {
         localResult = [_delegate headerSearchView:self nativeSearch:searchText];
    }
    
    if (!localResult || [localResult count] == 0) {
        if ([_delegate respondsToSelector:@selector(headerSearchView:remoteSearch: isFromSearchLables:)]) {
            [_delegate headerSearchView:self remoteSearch:searchText isFromSearchLables:isFromLabels];
        }
    }
    
}

#pragma mark - WSSearchTagFilterViewDelegate

- (void)searchTagView:(WSSearchTagFilterView *)searchTagView searchButtonClicked:(NSArray *)searchTagArray
{
    _searchFilterViewSelectedTagArray = searchTagArray;
    [self searchWithText:[searchTagArray componentsJoinedByString:@" "] isFromSearchLabels:YES];
}

@end
