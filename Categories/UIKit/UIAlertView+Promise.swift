import Foundation
import UIKit.UIAlertView
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `UIActionSheet` category:

    use_frameworks!
    pod "PromiseKit/UIKit"

 Or `UIKit` is one of the categories imported by the umbrella pod:

    use_frameworks!
    pod "PromiseKit"

 And then in your sources:

    import PromiseKit
*/
extension UIAlertView {
    /**
     Displays the alert view.

        let alert = UIAlertView()
        alert.title = "OHAI"
        alert.addButtonWithTitle("OK")
        alert.cancelButtonIndex = sheet.addButtonWithTitle("Cancel")
        alert.promise().then { dismissedButtonIndex -> Void in
            // index won't be the cancelled button index!
        }

     - Important: If a cancelButtonIndex is set the promise will be *cancelled* if that button is pressed. Cancellation in PromiseKit has special behavior, see the relevant documentation for more details.
     - Returns: A promise that fulfills with the pressed button index.
     */
    public func promise() -> Promise<Int> {
        let proxy = PMKAlertViewDelegate()
        delegate = proxy
        proxy.retainCycle = proxy
        show()
        
        if numberOfButtons == 1 && cancelButtonIndex == 0 {
            NSLog("PromiseKit: An alert view is being promised with a single button that is set as the cancelButtonIndex. The promise *will* be cancelled which may result in unexpected behavior. See http://promisekit.org/PromiseKit-2.0-Released/ for cancellation documentation.")
        }
        
        return proxy.promise
    }

    /// Errors representing PromiseKit UIAlertView failures.
    public enum Error: CancellableError {
        /// The user cancelled the action sheet.
        case cancelled
        /// - Returns: true
        public var isCancelled: Bool {
            switch self {
            case .cancelled:
                return true
            }
        }
    }
}

private class PMKAlertViewDelegate: NSObject, UIAlertViewDelegate {
    let (promise, fulfill, reject) = Promise<Int>.pending()
    var retainCycle: NSObject?

    @objc func alertView(_ alertView: UIAlertView, didDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != alertView.cancelButtonIndex {
            fulfill(buttonIndex)
        } else {
            reject(UIAlertView.Error.cancelled)
        }
    }
}
