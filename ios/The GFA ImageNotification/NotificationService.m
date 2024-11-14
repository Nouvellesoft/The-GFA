#import "NotificationService.h"
#import <Firebase.h>
#import <FirebaseMessaging/FirebaseMessaging.h>
#import <OneSignalFramework/OneSignalFramework.h>

@interface NotificationService ()
@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNNotificationRequest *receivedRequest;
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;
@end

@implementation NotificationService

// Remove Firebase Auth methods if they're not needed for authentication in this service extension.
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request
                  withContentHandler:(void (^)(UNNotificationContent *))contentHandler {
    self.receivedRequest = request;
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];

    // Handle OneSignal notification request
    [OneSignal didReceiveNotificationExtensionRequest:self.receivedRequest
                          withMutableNotificationContent:self.bestAttemptContent
                                      withContentHandler:self.contentHandler];

    // Handle Firebase Messaging notification request
    [[FIRMessaging extensionHelper] populateNotificationContent:self.bestAttemptContent
                                            withContentHandler:contentHandler];
}

- (void)serviceExtensionTimeWillExpire {
    // Provide the best attempt content when time is about to expire
    [OneSignal serviceExtensionTimeWillExpireRequest:self.receivedRequest
                          withMutableNotificationContent:self.bestAttemptContent];
    self.contentHandler(self.bestAttemptContent);
}

@end
