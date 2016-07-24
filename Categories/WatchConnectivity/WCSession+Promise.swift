import Foundation
import WatchConnectivity
#if !COCOAPODS
import PromiseKit
#endif

@available(iOS 9.0, *)
@available(iOSApplicationExtension 9.0, *)
extension WCSession {

    public func sendMessage(_ message: [String: AnyObject]) -> Promise<[String: AnyObject]> {
        return Promise { resolver, error in
            sendMessage(message, replyHandler: resolver, errorHandler: error)
        }
    }

    public func sendMessageData(_ data: Data) -> Promise<Data> {
        return Promise { resolver, error in
            sendMessageData(data, replyHandler: resolver, errorHandler: error)
        }
    }
}
