//
//  WebStateBridge.mm
//  Neuve Chrome WebState Bridge Implementation
//

#import "ios/neuve_chrome/services/WebStateBridge.h"
#import <WebKit/WebKit.h>

@implementation WebTabInfo
@end

@interface WebStateBridge() <WKNavigationDelegate> {
  NSMutableArray<WKWebView*>* _webViews;
  NSMutableArray<WebTabInfo*>* _tabInfos;
  NSInteger _activeIndex;
}
@end

@implementation WebStateBridge

- (instancetype)init {
  self = [super init];
  if (self) {
    _webViews = [[NSMutableArray alloc] init];
    _tabInfos = [[NSMutableArray alloc] init];
    _activeIndex = 0;
    
    // Create a default tab
    [self createDefaultTab];
  }
  return self;
}

- (void)createDefaultTab {
  // Create default web view
  WKWebView* webView = [[WKWebView alloc] init];
  webView.navigationDelegate = self;
  [_webViews addObject:webView];
  
  // Create default tab info
  WebTabInfo* tabInfo = [[WebTabInfo alloc] init];
  tabInfo.title = @"New Tab";
  tabInfo.url = [NSURL URLWithString:@"about:blank"];
  tabInfo.isLoading = NO;
  tabInfo.canGoBack = NO;
  tabInfo.canGoForward = NO;
  [_tabInfos addObject:tabInfo];
}

- (NSArray<WebTabInfo*>*)getAllTabs {
  return [_tabInfos copy];
}

- (NSInteger)getActiveTabIndex {
  return _activeIndex;
}

- (NSInteger)getTabCount {
  return _tabInfos.count;
}

- (void)createNewTabWithURL:(NSURL*)url {
  // Create new web view
  WKWebView* webView = [[WKWebView alloc] init];
  webView.navigationDelegate = self;
  [_webViews addObject:webView];
  
  // Create new tab info
  WebTabInfo* tabInfo = [[WebTabInfo alloc] init];
  tabInfo.title = @"Loading...";
  tabInfo.url = url;
  tabInfo.isLoading = YES;
  tabInfo.canGoBack = NO;
  tabInfo.canGoForward = NO;
  [_tabInfos addObject:tabInfo];
  
  // Switch to new tab and load URL
  _activeIndex = _tabInfos.count - 1;
  [webView loadRequest:[NSURLRequest requestWithURL:url]];
}

- (void)closeTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)_tabInfos.count) {
    [_webViews removeObjectAtIndex:index];
    [_tabInfos removeObjectAtIndex:index];
    
    // Ensure we always have at least one tab
    if (_tabInfos.count == 0) {
      [self createDefaultTab];
      _activeIndex = 0;
    } else if (_activeIndex >= (NSInteger)_tabInfos.count) {
      _activeIndex = _tabInfos.count - 1;
    }
  }
}

- (void)switchToTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)_tabInfos.count) {
    _activeIndex = index;
  }
}

- (UIView*)getWebViewForTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)_webViews.count) {
    return _webViews[index];
  }
  return [[UIView alloc] init];
}

- (void)loadURL:(NSURL*)url inTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)_webViews.count) {
    WKWebView* webView = _webViews[index];
    [webView loadRequest:[NSURLRequest requestWithURL:url]];
    
    // Update tab info
    WebTabInfo* tabInfo = _tabInfos[index];
    tabInfo.url = url;
    tabInfo.isLoading = YES;
    tabInfo.title = @"Loading...";
  }
}

- (void)goBackInTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)_webViews.count) {
    WKWebView* webView = _webViews[index];
    if (webView.canGoBack) {
      [webView goBack];
    }
  }
}

- (void)goForwardInTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)_webViews.count) {
    WKWebView* webView = _webViews[index];
    if (webView.canGoForward) {
      [webView goForward];
    }
  }
}

- (void)reloadTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)_webViews.count) {
    WKWebView* webView = _webViews[index];
    [webView reload];
  }
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
  NSInteger index = [_webViews indexOfObject:webView];
  if (index != NSNotFound && index < (NSInteger)_tabInfos.count) {
    WebTabInfo* tabInfo = _tabInfos[index];
    tabInfo.isLoading = YES;
    tabInfo.title = @"Loading...";
  }
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  NSInteger index = [_webViews indexOfObject:webView];
  if (index != NSNotFound && index < (NSInteger)_tabInfos.count) {
    WebTabInfo* tabInfo = _tabInfos[index];
    tabInfo.isLoading = NO;
    tabInfo.url = webView.URL ?: tabInfo.url;
    tabInfo.title = webView.title.length > 0 ? webView.title : tabInfo.url.absoluteString;
    tabInfo.canGoBack = webView.canGoBack;
    tabInfo.canGoForward = webView.canGoForward;
  }
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSInteger index = [_webViews indexOfObject:webView];
  if (index != NSNotFound && index < (NSInteger)_tabInfos.count) {
    WebTabInfo* tabInfo = _tabInfos[index];
    tabInfo.isLoading = NO;
    tabInfo.title = @"Failed to load";
  }
}

@end