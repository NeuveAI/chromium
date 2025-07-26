#import "TabModelBridge.h"
#import "base/logging.h"

@implementation TabInfo
- (instancetype)initWithTitle:(NSString*)title 
                          url:(NSURL*)url
                    isLoading:(BOOL)isLoading
                    canGoBack:(BOOL)canGoBack
                 canGoForward:(BOOL)canGoForward {
  if ((self = [super init])) {
    _title = [title copy];
    _url = [url copy];
    _isLoading = isLoading;
    _canGoBack = canGoBack;
    _canGoForward = canGoForward;
  }
  return self;
}
@end

@implementation TabModelBridgeImpl {
  NSMutableArray<TabInfo*>* _tabInfos;
}

- (instancetype)init {
  if ((self = [super init])) {
    _tabInfos = [[NSMutableArray alloc] init];
    // Initialize with a default tab
    TabInfo* defaultTab = [[TabInfo alloc] 
        initWithTitle:@"New Tab"
                  url:[NSURL URLWithString:@"about:blank"]
            isLoading:NO
            canGoBack:NO
         canGoForward:NO];
    [_tabInfos addObject:defaultTab];
  }
  return self;
}

- (void)createNewTabWithURL:(NSURL*)url {
  TabInfo* newTab = [[TabInfo alloc] 
      initWithTitle:@"Loading..."
                url:url
          isLoading:YES
          canGoBack:NO
       canGoForward:NO];
  [_tabInfos addObject:newTab];
  
  // In real implementation, this would call:
  // self.cppTabModel->InsertWebState(url);
}

- (void)closeTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)[_tabInfos count]) {
    [_tabInfos removeObjectAtIndex:index];
    
    // In real implementation:
    // self.cppTabModel->CloseWebStateAt(index);
  }
}

- (void)switchToTabAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)[_tabInfos count]) {
    // In real implementation:
    // self.cppTabModel->ActivateWebStateAt(index);
  }
}

- (NSInteger)tabCount {
  return [_tabInfos count];
}

- (NSArray<TabInfo*>*)tabs {
  return [_tabInfos copy];
}

- (void)goBackAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)[_tabInfos count]) {
    // In real implementation: self.cppTabModel->GetWebStateAt(index)->GoBack();
  }
}

- (void)goForwardAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)[_tabInfos count]) {
    // In real implementation: self.cppTabModel->GetWebStateAt(index)->GoForward();
  }
}

- (void)reloadAtIndex:(NSInteger)index {
  if (index >= 0 && index < (NSInteger)[_tabInfos count]) {
    // In real implementation: self.cppTabModel->GetWebStateAt(index)->Reload();
  }
}

- (void)updateTabAtIndex:(NSInteger)index 
               withTitle:(NSString*)title 
                     url:(NSURL*)url {
  if (index >= 0 && index < (NSInteger)[_tabInfos count]) {
    TabInfo* currentTab = _tabInfos[index];
    TabInfo* updatedTab = [[TabInfo alloc] 
        initWithTitle:title ?: currentTab.title
                  url:url ?: currentTab.url
            isLoading:NO
            canGoBack:currentTab.canGoBack
         canGoForward:currentTab.canGoForward];
    
    _tabInfos[index] = updatedTab;
  }
}

@end