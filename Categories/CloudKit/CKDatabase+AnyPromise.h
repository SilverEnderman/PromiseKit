#import <CloudKit/CKDatabase.h>
#import <PromiseKit/AnyPromise.h>

/**
 To import the `CKDatabase` category:

    use_frameworks!
    pod "PromiseKit/CloudKit"
 
 And then in your sources:

    @import PromiseKit;
*/
@interface CKDatabase (PromiseKit)

- (AnyPromise *)fetchRecordWithID:(CKRecordID *)recordID NS_REFINED_FOR_SWIFT;
- (AnyPromise *)saveRecord:(CKRecord *)record NS_REFINED_FOR_SWIFT;
- (AnyPromise *)deleteRecordWithID:(CKRecordID *)recordID NS_REFINED_FOR_SWIFT;

- (AnyPromise *)performQuery:(CKQuery *)query inZoneWithID:(CKRecordZoneID *)zoneID NS_REFINED_FOR_SWIFT;

- (AnyPromise *)fetchAllRecordZones NS_REFINED_FOR_SWIFT;
- (AnyPromise *)fetchRecordZoneWithID:(CKRecordZoneID *)zoneID NS_REFINED_FOR_SWIFT;
- (AnyPromise *)saveRecordZone:(CKRecordZone *)zone NS_REFINED_FOR_SWIFT;
- (AnyPromise *)deleteRecordZoneWithID:(CKRecordZoneID *)zoneID NS_REFINED_FOR_SWIFT;

- (AnyPromise *)fetchSubscriptionWithID:(NSString *)subscriptionID NS_REFINED_FOR_SWIFT;
- (AnyPromise *)fetchAllSubscriptions NS_REFINED_FOR_SWIFT;
- (AnyPromise *)saveSubscription:(CKSubscription *)subscription NS_REFINED_FOR_SWIFT;
- (AnyPromise *)deleteSubscriptionWithID:(NSString *)subscriptionID NS_REFINED_FOR_SWIFT;

@end
