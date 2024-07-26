import UIKit
import Flutter
import Firebase

@main
@objc class AppDelegate: FlutterAppDelegate {
  var flutterViewController: FlutterViewController!
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    
    self.flutterViewController = FlutterViewController(project: nil, nibName: nil, bundle: nil)
    let navigationController = UINavigationController(rootViewController: self.flutterViewController)
    navigationController.setNavigationBarHidden(true, animated: false)
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.rootViewController = navigationController
    self.window?.makeKeyAndVisible()
    
    GeneratedPluginRegistrant.register(with: self.flutterViewController)
    
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  override func registrar(forPlugin pluginKey: String) -> FlutterPluginRegistrar? {
    return flutterViewController.registrar(forPlugin: pluginKey)
  }
  
  override func hasPlugin(_ pluginKey: String) -> Bool {
    return flutterViewController.hasPlugin(pluginKey)
  }
  
  override func valuePublished(byPlugin pluginKey: String) -> NSObject? {
    return flutterViewController.valuePublished(byPlugin: pluginKey)
  }
}
