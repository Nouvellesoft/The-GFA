import UIKit
import Flutter
import Firebase
import OneSignalFramework
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
    
    lazy var flutterEngine = FlutterEngine(name: "MyApp")
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UIApplication.shared.isStatusBarHidden = false
        
        // OneSignal setup
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize("6b1cda87-62bf-44d0-9243-9088805b7909", withLaunchOptions: launchOptions)

        // Configure Firebase
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        flutterEngine.run()
        GeneratedPluginRegistrant.register(with: self.flutterEngine)

        // Set notification center delegate
        UNUserNotificationCenter.current().delegate = self
        application.registerForRemoteNotifications()
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    // MARK: - Firebase MessagingDelegate
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("Firebase registration token: \(String(describing: fcmToken))")
        // If necessary, send the token to your app server or OneSignal
    }

    override func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if Auth.auth().canHandleNotification(userInfo) {
            completionHandler(.noData)
            return
        }
        Messaging.messaging().appDidReceiveMessage(userInfo)
        completionHandler(.newData)
    }
    
    // MARK: - OneSignal Notification Handling
    
    func serviceExtensionTimeWillExpire() {
        // Handle time expiring
        if let contentHandler = self.contentHandler, let bestAttemptContent = self.bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // MARK: - UNUserNotificationCenterDelegate Methods
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      willPresent notification: UNNotification,
                                      withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    override func userNotificationCenter(_ center: UNUserNotificationCenter,
                                      didReceive response: UNNotificationResponse,
                                      withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    // Properties for notification service extension
    private var contentHandler: ((UNNotificationContent) -> Void)?
    private var bestAttemptContent: UNMutableNotificationContent?
    
    func didReceiveNotificationExtensionRequest(_ request: UNNotificationRequest,
                                              with content: UNMutableNotificationContent,
                                              withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        self.bestAttemptContent = content
        
        OneSignal.didReceiveNotificationExtensionRequest(request, with: content) { newContent in
            contentHandler(newContent)
        }
    }
}
