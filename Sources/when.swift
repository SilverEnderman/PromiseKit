import Foundation.NSProgress

private func _when<T>(_ promises: [Promise<T>]) -> Promise<Void> {
    let root = Promise<Void>.pending()
    var countdown = promises.count
    guard countdown > 0 else {
        root.fulfill()
        return root.promise
    }

#if !PMKDisableProgress
    let progress = Progress(totalUnitCount: Int64(promises.count))
    progress.isCancellable = false
    progress.isPausable = false
#else
    var progress: (completedUnitCount: Int, totalUnitCount: Int) = (0, 0)
#endif
    
    let barrier = DispatchQueue(label: "org.promisekit.barrier.when", attributes: .concurrent)

    for (index, promise) in promises.enumerated() {
        promise.state.pipe { resolution in
            __dispatch_barrier_sync(barrier) {
                switch resolution {
                case .rejected(let error, let token):
                    token.consumed = true   // all errors are consumed by the parent Error.When
                    if root.promise.isPending {
                        progress.completedUnitCount = progress.totalUnitCount
                        root.reject(PMKError.when(index, error))
                    }
                case .fulfilled:
                    guard root.promise.isPending else { return }
                    progress.completedUnitCount += 1
                    countdown -= 1
                    if countdown == 0 {
                        root.fulfill()
                    }
                }
            }
        }
    }

    return root.promise
}

/**
 Wait for all promises in a set to resolve.

 For example:

     when(promise1, promise2).then { results in
         //…
     }.error { error in
         switch error {
         case Error.When(let index, NSURLError.NoConnection):
             //…
         case Error.When(let index, CLError.NotAuthorized):
             //…
         }
     }

 - Warning: If *any* of the provided promises reject, the returned promise is immediately rejected with that promise’s rejection. The error’s `userInfo` object is supplemented with `PMKFailingPromiseIndexKey`.
 - Warning: In the event of rejection the other promises will continue to resolve and, as per any other promise, will either fulfill or reject. This is the right pattern for `getter` style asynchronous tasks, but often for `setter` tasks (eg. storing data on a server), you most likely will need to wait on all tasks and then act based on which have succeeded and which have failed, in such situations use `join`.
 - Parameter promises: The promises upon which to wait before the returned promise resolves.
 - Returns: A new promise that resolves when all the provided promises fulfill or one of the provided promises rejects.
 - SeeAlso: `join()`
*/
public func when<T>(_ promises: [Promise<T>]) -> Promise<[T]> {
    return _when(promises).then(on: zalgo) { promises.map{ $0.value! } }
}

public func when<T>(_ promises: Promise<T>...) -> Promise<[T]> {
    return when(promises)
}

public func when(_ promises: Promise<Void>...) -> Promise<Void> {
    return _when(promises)
}

public func when(_ promises: [Promise<Void>]) -> Promise<Void> {
    return _when(promises)
}

public func when<U, V>(_ pu: Promise<U>, _ pv: Promise<V>) -> Promise<(U, V)> {
    return _when([pu.asVoid(), pv.asVoid()]).then(on: zalgo) { (pu.value!, pv.value!) }
}

public func when<U, V, X>(_ pu: Promise<U>, _ pv: Promise<V>, _ px: Promise<X>) -> Promise<(U, V, X)> {
    return _when([pu.asVoid(), pv.asVoid(), px.asVoid()]).then(on: zalgo) { (pu.value!, pv.value!, px.value!) }
}

/**
 Generate promises at a limited rate and wait for all to resolve.

 For example:
 
     func downloadFile(url: NSURL) -> Promise<NSData> {
         // ...
     }
 
     let urls: [NSURL] = /*…*/
     let urlGenerator = urls.generate()

     let generator = AnyGenerator<Promise<NSData>> {
         guard url = urlGenerator.next() else {
             return nil
         }

         return downloadFile(url)
     }

     when(generator, concurrently: 3).then { datum: [NSData] -> Void in
         // ...
     }

 - Warning: Refer to the warnings on `when(fulfilled:)`
 - Parameter promiseGenerator: Generator of promises.
 - Returns: A new promise that resolves when all the provided promises fulfill or one of the provided promises rejects.
 - SeeAlso: `join()`
 */

public func when<T, PromiseGenerator: IteratorProtocol where PromiseGenerator.Element == Promise<T> >(_ promiseGenerator: PromiseGenerator, concurrently: Int) -> Promise<[T]> {

    guard concurrently > 0 else {
        return Promise(error: PMKError.whenConcurrentlyZero)
    }

    var generator = promiseGenerator
    var root = Promise<[T]>.pending()
    var pendingPromises = 0
    var promises: [Promise<T>] = []

    let barrier = DispatchQueue(label: "org.promisekit.barrier.when", attributes: [.concurrent])

    func dequeue() {
        guard root.promise.isPending else { return }  // don’t continue dequeueing if root has been rejected

        var shouldDequeue = false
        barrier.sync {
            shouldDequeue = pendingPromises < concurrently
        }
        guard shouldDequeue else { return }

        var index: Int!
        var promise: Promise<T>!

        __dispatch_barrier_sync(barrier) {
            guard let next = generator.next() else { return }

            promise = next
            index = promises.count

            pendingPromises += 1
            promises.append(next)
        }

        func testDone() {
            barrier.sync {
                if pendingPromises == 0 {
                    root.fulfill(promises.flatMap{ $0.value })
                }
            }
        }

        guard promise != nil else {
            return testDone()
        }

        promise.state.pipe { resolution in
            __dispatch_barrier_sync(barrier) {
                pendingPromises -= 1
            }

            switch resolution {
            case .fulfilled:
                dequeue()
                testDone()
            case .rejected(let error, let token):
                token.consumed = true
                root.reject(PMKError.when(index, error))
            }
        }

        dequeue()
    }
        
    dequeue()

    return root.promise
}
