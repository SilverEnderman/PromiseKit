import MapKit
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `MKDirections` category:

    use_frameworks!
    pod "PromiseKit/MapKit"

 And then in your sources:

    import PromiseKit
*/
extension MKDirections {
    /// Begins calculating the requested route information asynchronously.
    public func promise() -> Promise<MKDirectionsResponse> {
        return Promise.wrap(resolver: calculate)
    }

    /// Begins calculating the requested travel-time information asynchronously.
    public func promise() -> Promise<MKETAResponse> {
        return Promise.wrap(resolver: calculateETA)
    }
}
