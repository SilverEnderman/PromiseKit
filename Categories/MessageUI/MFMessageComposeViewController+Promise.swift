import Foundation
import MessageUI.MFMessageComposeViewController
import UIKit.UIViewController
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import this `UIViewController` category:

    use_frameworks!
    pod "PromiseKit/MessageUI"

 And then in your sources:

    import PromiseKit
*/
extension UIViewController {
    public func promiseViewController(vc: MFMessageComposeViewController, animated: Bool = true, completion:(() -> Void)? = nil) -> Promise<Void> {
        let proxy = PMKMessageComposeViewControllerDelegate()
        proxy.retainCycle = proxy
        vc.messageComposeDelegate = proxy
        present(vc, animated: animated, completion: completion)
        _ = proxy.promise.always {
            vc.dismiss(animated: animated, completion: nil)
        }
        return proxy.promise
    }
}

extension MFMessageComposeViewController {
    /// Errors representing PromiseKit MFMailComposeViewController failures
    public enum Error: CancellableError {
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

private class PMKMessageComposeViewControllerDelegate: NSObject, MFMessageComposeViewControllerDelegate, UINavigationControllerDelegate {

    let (promise, fulfill, reject) = Promise<Void>.pending()
    var retainCycle: NSObject?

    @objc func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        defer { retainCycle = nil }

        switch result {
        case .sent:
            fulfill()
        case .failed:
            var info = [NSObject: AnyObject]()
            info[NSLocalizedDescriptionKey] = "The attempt to save or send the message was unsuccessful."
            info[NSUnderlyingErrorKey] = NSNumber(value: result.rawValue)
            reject(NSError(domain: PMKErrorDomain, code: PMKOperationFailed, userInfo: info))
        case .cancelled:
            reject(MFMessageComposeViewController.Error.cancelled)
        }
    }
}

public enum MessageUIError: Error {
    case failed
}
