import CloudKit.CKDatabase
#if !COCOAPODS
import PromiseKit
#endif

/**
 To import the `CKDatabase` category:

    use_frameworks!
    pod "PromiseKit/CloudKit"
 
 And then in your sources:

    @import PromiseKit;
*/
extension CKDatabase {
    /// Fetches one record asynchronously from the current database.
    public func fetchRecordWithID(_ recordID: CKRecordID) -> Promise<CKRecord> {
        return Promise.wrap { fetch(withRecordID: recordID, completionHandler: $0) }
    }

    /// Fetches one record zone asynchronously from the current database.
    public func fetchRecordZoneWithID(_ recordZoneID: CKRecordZoneID) -> Promise<CKRecordZone> {
        return Promise.wrap { fetch(withRecordZoneID: recordZoneID, completionHandler: $0) }
    }

    /// Fetches one record zone asynchronously from the current database.
    public func fetchSubscriptionWithID(_ subscriptionID: String) -> Promise<CKSubscription> {
        return Promise.wrap { fetch(withSubscriptionID: subscriptionID, completionHandler: $0) }
    }

    /// Fetches all record zones asynchronously from the current database.
    public func fetchAllRecordZones() -> Promise<[CKRecordZone]> {
        return Promise.wrap { fetchAllRecordZones(completionHandler: $0) }
    }

    /// Fetches all subscription objects asynchronously from the current database.
    public func fetchAllSubscriptions() -> Promise<[CKSubscription]> {
        return Promise.wrap { fetchAllSubscriptions(completionHandler: $0) }
    }

    /// Saves one record zone asynchronously to the current database.
    public func save(_ record: CKRecord) -> Promise<CKRecord> {
        return Promise.wrap { save(record, completionHandler: $0) }
    }

    /// Saves one record zone asynchronously to the current database.
    public func save(_ recordZone: CKRecordZone) -> Promise<CKRecordZone> {
        return Promise.wrap { save(recordZone, completionHandler: $0) }
    }

    /// Saves one subscription object asynchronously to the current database.
    public func save(_ subscription: CKSubscription) -> Promise<CKSubscription> {
        return Promise.wrap { save(subscription, completionHandler: $0) }
    }

    /// Delete one subscription object asynchronously from the current database.
    public func deleteRecordWithID(_ recordID: CKRecordID) -> Promise<CKRecordID> {
        return Promise.wrap { delete(withRecordID: recordID, completionHandler: $0) }
    }

    /// Delete one subscription object asynchronously from the current database.
    public func deleteRecordZoneWithID(_ zoneID: CKRecordZoneID) -> Promise<CKRecordZoneID> {
        return Promise.wrap { delete(withRecordZoneID: zoneID, completionHandler: $0) }
    }

    /// Delete one subscription object asynchronously from the current database.
    public func deleteSubscriptionWithID(_ subscriptionID: String) -> Promise<String> {
        return Promise.wrap { delete(withSubscriptionID: subscriptionID, completionHandler: $0) }
    }

    /// Searches the specified zone asynchronously for records that match the query parameters.
    public func performQuery(_ query: CKQuery, inZoneWithID zoneID: CKRecordZoneID? = nil) -> Promise<[CKRecord]> {
        return Promise.wrap { perform(query, inZoneWith: zoneID, completionHandler: $0) }
    }

    /// Searches the specified zone asynchronously for records that match the query parameters.
    public func performQuery(_ query: CKQuery, inZoneWithID zoneID: CKRecordZoneID? = nil) -> Promise<CKRecord?> {
        return Promise.wrap { resolve in
            perform(query, inZoneWith: zoneID) { records, error in
                resolve(records?.first, error)
            }
        }
    }

    /// Fetches the record for the current user.
    public func fetchUserRecord(_ container: CKContainer = CKContainer.default()) -> Promise<CKRecord> {
        return container.fetchUserRecordID().then(on: zalgo) { uid -> Promise<CKRecord> in
            return self.fetchRecordWithID(uid)
        }
    }
}
