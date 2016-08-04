import Foundation
// When using Carthage add `github "mxcl/OMGHTTPURLRQ"` to your Cartfile.
import OMGHTTPURLRQ
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `NSURLConnection` category:

    use_frameworks!
    pod "PromiseKit/Foundation"

 Or `NSURLConnection` is one of the categories imported by the umbrella pod:

    use_frameworks!
    pod "PromiseKit"

 And then in your sources:

    import PromiseKit
*/
extension NSURLConnection {
    /**
     Makes a **GET** request to the provided URL.

         let p = NSURLConnection.GET("http://placekitten.com/320/320", query: ["foo": "bar"])
         p.then { data -> Void  in
             //…
         }
         p.asImage().then { image -> Void  in
            //…
         }
         p.asDictionary().then { json -> Void  in
            //…
         }

     - Parameter url: The URL to request.
     - Parameter query: The parameters to be encoded as the query string for the GET request.
     - Returns: A promise that represents the GET request.
     - SeeAlso: `URLDataPromise`
     */
    public class func GET(_ url: String, query: [NSObject:AnyObject]? = nil) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.get(url, query) as URLRequest)
    }

    /**
     Makes a POST request to the provided URL passing form URL encoded
     parameters.

     Form URL-encoding is the standard way to POST on the Internet, so
     probably this is what you want. If it doesn’t work, try the `+POST:JSON`
     variant.

         let url = "http://jsonplaceholder.typicode.com/posts"
         let params = ["title": "foo", "body": "bar", "userId": 1]
         NSURLConnection.POST(url, formData: params).asDictionary().then { json -> Void  in
             //…
         }

     - Parameter url: The URL to request.
     - Parameter formData: The parameters to be form URL-encoded and passed as the POST body.
     - Returns: A promise that represents the POST request.
     - SeeAlso: `URLDataPromise`
     */
    public class func POST(_ url: String, formData: [NSObject: AnyObject]? = nil) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.post(url, formData) as URLRequest)
    }

    /**
     Makes a POST request to the provided URL passing JSON encoded
     parameters.

     Most web servers nowadays support POST with either JSON or form
     URL-encoding. If in doubt try form URL-encoded parameters first.

         let url = "http://jsonplaceholder.typicode.com/posts"
         let params = ["title": "foo", "body": "bar", "userId": 1]
         NSURLConnection.POST(url, json: params).asDictionary().then { json -> Void  in
             //…
         }

     - Parameter url: The URL to request.
     - Parameter json: The parameters to be JSON-encoded and passed as the POST body.
     - Returns: A promise that represents the POST request.
     - SeeAlso: `URLDataPromise`
     */
    public class func POST(_ url: String, json: [NSObject: AnyObject]) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.post(url, json: json) as URLRequest)
    }

    /**
     Makes a POST request to the provided URL passing multipart form-data.

        let formData = OMGMultipartFormData()
        let imgData = Data(contentsOfFile: "image.png")
        formData.addFile(imgdata, parameterName: "file1", filename: "myimage1.png", contentType: "image/png")

        NSURLConnection.POST(url, multipartFormData: formData).then { data in
            //…
        }

     - Parameter url: The URL to request.
     - Parameter multipartFormData: The parameters to be multipart form-data encoded and passed as the POST body.
     - Returns: A promise that represents the POST request.
     - SeeAlso: [https://github.com/mxcl/OMGHTTPURLRQ](OMGHTTPURLRQ)
     */
    public class func POST(_ url: String, multipartFormData: OMGMultipartFormData) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.post(url, multipartFormData) as URLRequest)
    }

    /**
     Makes a PUT request to the provided URL passing form URL-encoded
     parameters.

         let url = "http://jsonplaceholder.typicode.com/posts"
         let params = ["title": "foo", "body": "bar", "userId": 1]
         NSURLConnection.PUT(url, formData: params).asDictionary().then { json -> Void  in
             //…
         }

     - Parameter url: The URL to request.
     - Parameter formData: The parameters to be form URL-encoded and passed as the PUT body.
     - Returns: A promise that represents the PUT request.
     - SeeAlso: `URLDataPromise`
     */
    public class func PUT(_ url: String, formData: [NSObject:AnyObject]? = nil) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.put(url, formData) as URLRequest)
    }

    /**
     Makes a PUT request to the provided URL passing JSON encoded parameters.

         let url = "http://jsonplaceholder.typicode.com/posts"
         let params = ["title": "foo", "body": "bar", "userId": 1]
         NSURLConnection.PUT(url, json: params).asDictionary().then { json -> Void  in
             //…
         }

     - Parameter url: The URL to request.
     - Parameter json: The parameters to be JSON-encoded and passed as the PUT body.
     - Returns: A promise that represents the PUT request.
     - SeeAlso: `URLDataPromise`
     */
    public class func PUT(_ url: String, json: [NSObject:AnyObject]) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.put(url, json: json) as URLRequest)
    }

    /**
     Makes a DELETE request to the provided URL passing form URL-encoded
     parameters.

         let url = "http://jsonplaceholder.typicode.com/posts/1"
         NSURLConnection.DELETE(url).then.asDictionary() { json -> Void in
             //…
         }

     - Parameter url: The URL to request.
     - Returns: A promise that represents the PUT request.
     - SeeAlso: `URLDataPromise`
     */
    public class func DELETE(_ url: String) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.delete(url, nil) as URLRequest)
    }

    /**
     Makes a PATCH request to the provided URL passing the provided JSON parameters.

         let url = "http://jsonplaceholder.typicode.com/posts/1"
         let params = ["foo": "bar"]
         NSURLConnection.PATCH(url, json: params).asDictionary().then { json -> Void in
             //…
         }
     - Parameter url: The URL to request.
     - Parameter json: The JSON parameters to encode as the PATCH body.
     - Returns: A promise that represents the PUT request.
     - SeeAlso: `URLDataPromise`
     */
    public class func PATCH(_ url: String, json: NSDictionary) -> URLDataPromise {
        return go(try OMGHTTPURLRQ.patch(url, json: json) as URLRequest)
    }

    /**
     Makes an HTTP request using the parameters specified by the provided URL
     request.

     This variant is less convenient, but provides you complete control over
     your `URLRequest`. Often this is necessary if your API requires
     authentication in the HTTP headers.

     We recommend the use of [OMGHTTPURLRQ] which allows you to construct correct REST requests.

        let rq = OMGHTTPURLRQ.POST(url, json: parameters)
        NSURLConnection.promise(rq).asDictionary().then { json in
            //…
        }

     - Parameter request: The URL request.
     - Returns: A promise that represents the URL request.
     - SeeAlso: `URLDataPromise`
     - SeeAlso: [OMGHTTPURLRQ]
     
     [OMGHTTPURLRQ]: https://github.com/mxcl/OMGHTTPURLRQ
     */
    public class func promise(_ request: URLRequest) -> URLDataPromise {
        return go(request)
    }
}

private func go(_ body: @autoclosure () throws -> URLRequest) -> URLDataPromise {
    do {
        var request = try body()

        if request.value(forHTTPHeaderField: "User-Agent") == nil {
            request.setValue(OMGUserAgent(), forHTTPHeaderField: "User-Agent")
        }

        return URLDataPromise.go(request) { completionHandler in
            NSURLConnection.sendAsynchronousRequest(request, queue: Q, completionHandler: { completionHandler($1, $0, $2) })
        }
    } catch {
        return URLDataPromise(error: error)
    }
}

private let Q = OperationQueue()
