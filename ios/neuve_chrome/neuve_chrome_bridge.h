//
//  neuve_chrome_bridge.h
//  Neuve Chrome
//
//  Bridging header to expose Chromium C++ APIs to Swift
//

#ifndef neuve_chrome_bridge_h
#define neuve_chrome_bridge_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Forward declarations for Chromium C++ types
// These would normally be included from the actual Chromium headers

#ifdef __cplusplus
extern "C" {
#endif

// Tab Model Bridge Functions
// These functions would bridge to the actual C++ TabModel
void* CreateTabModel(void);
void DestroyTabModel(void* tab_model);
void TabModel_InsertWebState(void* tab_model, NSString* url);
void TabModel_CloseWebStateAt(void* tab_model, int index);
void TabModel_ActivateWebStateAt(void* tab_model, int index);
int TabModel_GetCount(void* tab_model);
NSString* TabModel_GetTitleAt(void* tab_model, int index);
NSString* TabModel_GetUrlAt(void* tab_model, int index);

// Bookmark Model Bridge Functions
void* CreateBookmarkModel(void);
void DestroyBookmarkModel(void* bookmark_model);
void BookmarkModel_AddBookmark(void* bookmark_model, NSString* title, NSString* url, NSString* parent_id);
void BookmarkModel_RemoveBookmark(void* bookmark_model, NSString* bookmark_id);
NSArray* BookmarkModel_GetAllBookmarks(void* bookmark_model);

// History Service Bridge Functions
void* CreateHistoryService(void);
void DestroyHistoryService(void* history_service);
void HistoryService_AddURL(void* history_service, NSString* url, NSString* title);
NSArray* HistoryService_GetRecentHistory(void* history_service, int limit);
NSArray* HistoryService_SearchHistory(void* history_service, NSString* query, int limit);

// Browser State Functions
void* CreateBrowserState(void);
void DestroyBrowserState(void* browser_state);

// Web State Functions
void* CreateWebState(void* browser_state, NSString* url);
void DestroyWebState(void* web_state);
void WebState_LoadURL(void* web_state, NSString* url);
NSString* WebState_GetTitle(void* web_state);
NSString* WebState_GetVisibleURL(void* web_state);
BOOL WebState_CanGoBack(void* web_state);
BOOL WebState_CanGoForward(void* web_state);
void WebState_GoBack(void* web_state);
void WebState_GoForward(void* web_state);
void WebState_Reload(void* web_state);

#ifdef __cplusplus
}
#endif

#endif /* neuve_chrome_bridge_h */