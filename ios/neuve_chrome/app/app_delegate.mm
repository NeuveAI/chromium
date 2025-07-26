//
//  app_delegate.mm
//  Neuve Chrome iOS App Delegate Implementation
//

#import "ios/neuve_chrome/app/app_delegate.h"
#import <SwiftUI/SwiftUI.h>

// Forward declare the Swift class
@interface SwiftUIHostingHelper : NSObject
+ (UIViewController *)createNeuveChromeBrowserViewController;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"iOS 26 Neuve Chrome starting");
    
    // Create window for iOS 26 - using windowScene will be handled by the system
    self.window = [[UIWindow alloc] init];
    self.window.backgroundColor = [UIColor systemBackgroundColor];
    
    // Start with fallback view
    [self createFallbackViewController];
    
    // Try to replace with SwiftUI view on main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        @try {
            Class swiftUIHelperClass = NSClassFromString(@"neuve_chrome_swift.SwiftUIHostingHelper");
            if (swiftUIHelperClass) {
                UIViewController *swiftUIController = [swiftUIHelperClass performSelector:@selector(createNeuveChromeBrowserViewController)];
                if (swiftUIController) {
                    self.window.rootViewController = swiftUIController;
                    NSLog(@"Successfully loaded SwiftUI interface");
                }
            } else {
                NSLog(@"Could not find SwiftUIHostingHelper class");
            }
        } @catch (NSException *exception) {
            NSLog(@"Failed to create SwiftUI view: %@", exception);
        }
    });
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)createFallbackViewController {
    UIViewController *viewController = [[UIViewController alloc] init];
    viewController.view.backgroundColor = [UIColor systemBlueColor];
    
    UILabel *label = [[UILabel alloc] init];
    label.text = @"Neuve Chrome";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    
    [viewController.view addSubview:label];
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:viewController.view.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:viewController.view.centerYAnchor]
    ]];
    
    self.window.rootViewController = viewController;
}

@end