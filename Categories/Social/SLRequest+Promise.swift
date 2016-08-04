import Social
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `SLRequest` category:

    use_frameworks!
    pod "PromiseKit/Social"

 And then in your sources:

    import PromiseKit
*/
extension SLRequest {
    /**
     Performs the request asynchronously.

     - Returns: A promise that fulfills with the response.
     - SeeAlso: `URLDataPromise`
    */
    public func promise() -> URLDataPromise {
        return URLDataPromise.go(preparedURLRequest()) { completionHandler in
            perform(handler: completionHandler)
        }
    }
}
