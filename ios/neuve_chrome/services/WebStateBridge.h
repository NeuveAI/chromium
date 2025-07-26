//
//  WebStateBridge.h
//  Neuve Chrome WebState Bridge Interface
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class NSURL;

// Information about a single web tab
@interface WebTabInfo : NSObject
@property(nonatomic, strong) NSString* title;
@property(nonatomic, strong) NSURL* url;
@property(nonatomic, assign) BOOL isLoading;
@property(nonatomic, assign) BOOL canGoBack;
@property(nonatomic, assign) BOOL canGoForward;
@end

// Bridge interface to Chrome's WebState system
@interface WebStateBridge : NSObject

// Initialize the bridge
- (instancetype)init;

// Tab management
- (NSArray<WebTabInfo*>*)getAllTabs;
- (NSInteger)getActiveTabIndex;
- (NSInteger)getTabCount;

// Create new tab
- (void)createNewTabWithURL:(NSURL*)url;

// Close tab
- (void)closeTabAtIndex:(NSInteger)index;

// Switch to tab
- (void)switchToTabAtIndex:(NSInteger)index;

// Get web view for tab (for SwiftUI integration)
- (UIView*)getWebViewForTabAtIndex:(NSInteger)index;

// Navigation
- (void)loadURL:(NSURL*)url inTabAtIndex:(NSInteger)index;
- (void)goBackInTabAtIndex:(NSInteger)index;
- (void)goForwardInTabAtIndex:(NSInteger)index;
- (void)reloadTabAtIndex:(NSInteger)index;

@end