import Flutter
import UIKit
import workmanager

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // In AppDelegate.application method
    WorkmanagerPlugin.registerBGProcessingTask(withIdentifier: "task-identifier")

    // Register a periodic task in iOS 13+
    WorkmanagerPlugin.registerPeriodicTask(withIdentifier: "be.tramckrijte.attendance.iOSBackgroundAppRefresh", frequency: NSNumber(value: 60 * 60))
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
