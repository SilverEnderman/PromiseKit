import AssetsLibrary
import Foundation.NSData
#if !COCOAPODS
import PromiseKit
#endif
import UIKit.UIViewController

/**
 To import this `UIViewController` extension:

    use_frameworks!
    pod "PromiseKit/AssetsLibrary"

 And then in your sources:

    import PromiseKit
*/
extension UIViewController {
    /**
      - Returns: A promise that presents the provided UIImagePickerController and fulfills with the user selected media’s `NSData`.
     */
    public func promise(_ vc: UIImagePickerController, animated: Bool = false, completion: (() -> Void)? = nil) -> Promise<NSData> {
        let proxy = UIImagePickerControllerProxy()
        vc.delegate = proxy

        present(vc, animated: animated, completion: completion)

        return proxy.promise.then(on: zalgo) { info -> Promise<NSData> in
            let url = info[UIImagePickerControllerReferenceURL] as! URL
            
            return Promise { fulfill, reject in
                ALAssetsLibrary().asset(for: url, resultBlock: { asset in
                    let N = Int(asset!.defaultRepresentation().size())
                    let bytes = UnsafeMutablePointer<UInt8>.allocate(capacity: N)
                    var error: NSError?
                    asset!.defaultRepresentation().getBytes(bytes, fromOffset: 0, length: N, error: &error)

                    if let error = error {
                        reject(error)
                    } else {
                        fulfill(NSData(bytesNoCopy: bytes, length: N))
                    }
                }, failureBlock: { reject($0!) } )
            }
        }.always {
            self.dismiss(animated: animated, completion: nil)
        }
    }
}
