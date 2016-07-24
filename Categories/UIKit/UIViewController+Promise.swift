import Foundation.NSError
import UIKit
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import this `UIViewController` category:

    use_frameworks!
    pod "PromiseKit/UIKit"

 Or `UIKit` is one of the categories imported by the umbrella pod:

    use_frameworks!
    pod "PromiseKit"

 And then in your sources:

    import PromiseKit
*/
extension UIViewController {

    public enum Error: Swift.Error {
        case navigationControllerEmpty
        case noImageFound
        case notPromisable
        case notGenericallyPromisable
        case nilPromisable
    }

    public enum FulfillmentType {
        case onceDisappeared
        case beforeDismissal
    }

    public func promise<T>(_ vc: UIViewController, animate animationOptions: PMKAnimationOptions = [.appear, .disappear], fulfills: FulfillmentType = .onceDisappeared, completion: (() -> Void)? = nil) -> Promise<T> {
        let pvc: UIViewController

        switch vc {
        case let nc as UINavigationController:
            guard let vc = nc.viewControllers.first else { return Promise(error: Error.navigationControllerEmpty) }
            pvc = vc
        default:
            pvc = vc
        }

        let promise: Promise<T>

        if !(pvc is Promisable) {
            promise = Promise(error: Error.notPromisable)
        } else if let p = pvc.value(forKeyPath: "promise") as? Promise<T> {
            promise = p
        } else if let _: AnyObject = pvc.value(forKeyPath: "promise") {
            promise = Promise(error: Error.notGenericallyPromisable)
        } else {
            promise = Promise(error: Error.nilPromisable)
        }

        if promise.isPending {
            present(vc, animated: animationOptions.contains(.appear), completion: completion)
            _ = promise.always {
                vc.presentingViewController?.dismiss(animated: animationOptions.contains(.disappear), completion: nil)
            }
        }

        return promise
    }

    @available(*, deprecated: 3.4, renamed: "promise(_:animate:fulfills:completion:)")
    public func promiseViewController<T>(_ vc: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) -> Promise<T> {
        return promise(vc, animate: animated ? [.appear, .disappear] : [], completion: completion)
    }

    @available(*, deprecated: 3.4, renamed: "promise(_:animate:fulfills:completion:)")
    public func promiseViewController(_ vc: UIImagePickerController, animated: Bool = true, completion: (() -> Void)? = nil) -> Promise<UIImage> {
        return promise(vc, animate: animated ? [.appear, .disappear] : [], completion: completion)
    }

    @available(*, deprecated: 3.4, renamed: "promise(_:animate:fulfills:completion:)")
    public func promiseViewController(_ vc: UIImagePickerController, animated: Bool = true, completion: (() -> Void)? = nil) -> Promise<[String: AnyObject]> {
        return promise(vc, animate: animated ? [.appear, .disappear] : [], completion: completion)
    }

    public func promise(_ vc: UIImagePickerController, animate: PMKAnimationOptions = [.appear, .disappear], completion: (() -> Void)? = nil) -> Promise<UIImage> {
        let animated = animate.contains(.appear)
        let proxy = UIImagePickerControllerProxy()
        vc.delegate = proxy
        vc.mediaTypes = ["public.image"]  // this promise can only resolve with a UIImage
        present(vc, animated: animated, completion: completion)
        return proxy.promise.then(on: zalgo) { info -> UIImage in
            if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
                return img
            }
            if let img = info[UIImagePickerControllerOriginalImage] as? UIImage {
                return img
            }
            throw Error.noImageFound
        }.always {
            vc.presentingViewController?.dismiss(animated: animated, completion: nil)
        }
    }

    public func promise(_ vc: UIImagePickerController, animate: PMKAnimationOptions = [.appear, .disappear], completion: (() -> Void)? = nil) -> Promise<[String: AnyObject]> {
        let animated = animate.contains(.appear)
        let proxy = UIImagePickerControllerProxy()
        vc.delegate = proxy
        present(vc, animated: animated, completion: completion)
        return proxy.promise.always {
            vc.presentingViewController?.dismiss(animated: animated, completion: nil)
        }
    }
}

@objc(Promisable) public protocol Promisable {
    /**
     Provide a promise for promiseViewController here.

     The resulting property must be annotated with @objc.

     Obviously return a Promise<T>. There is an issue with generics and Swift and
     protocols currently so we couldn't specify that.
    */
    var promise: AnyObject! { get }
}

// internal scope because used by ALAssetsLibrary extension
@objc class UIImagePickerControllerProxy: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    let (promise, fulfill, reject) = Promise<[String : AnyObject]>.pending()
    var retainCycle: AnyObject?

    required override init() {
        super.init()
        retainCycle = self
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        fulfill(info)
        retainCycle = nil
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        reject(UIImagePickerController.Error.cancelled)
        retainCycle = nil
    }
}


extension UIImagePickerController {
    public enum Error: CancellableError {
        case cancelled

        public var isCancelled: Bool {
            switch self {
                case .cancelled: return true
            }
        }
    }
}
