import SwiftUI
import UIKit

@objc public class SwiftUIHostingHelper: NSObject {
    
    @MainActor
    @objc public static func createNeuveChromeBrowserViewController() -> UIViewController {
        let contentView = NeuveChromeBrowserView()
        return UIHostingController(rootView: contentView)
    }
}