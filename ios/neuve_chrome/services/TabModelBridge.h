#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// Tab information structure
@interface TabInfo : NSObject
@property(nonatomic, readonly, copy) NSString* title;
@property(nonatomic, readonly, copy) NSURL* url;
@property(nonatomic, readonly) BOOL isLoading;
@property(nonatomic, readonly) BOOL canGoBack;
@property(nonatomic, readonly) BOOL canGoForward;

- (instancetype)initWithTitle:(NSString*)title 
                          url:(NSURL*)url
                    isLoading:(BOOL)isLoading
                    canGoBack:(BOOL)canGoBack
                 canGoForward:(BOOL)canGoForward;

@end

// Protocol for Tab Management Bridge
@protocol TabModelBridge <NSObject>
- (void)createNewTabWithURL:(NSURL*)url;
- (void)closeTabAtIndex:(NSInteger)index;
- (void)switchToTabAtIndex:(NSInteger)index;
@property(nonatomic, readonly) NSInteger tabCount;
@property(nonatomic, readonly) NSArray<TabInfo*>* tabs;
@end

// Implementation that bridges to C++ TabModel
@interface TabModelBridgeImpl : NSObject <TabModelBridge>
- (void)goBackAtIndex:(NSInteger)index;
- (void)goForwardAtIndex:(NSInteger)index;
- (void)reloadAtIndex:(NSInteger)index;
- (void)updateTabAtIndex:(NSInteger)index 
               withTitle:(nullable NSString*)title 
                     url:(nullable NSURL*)url;
@end

NS_ASSUME_NONNULL_END