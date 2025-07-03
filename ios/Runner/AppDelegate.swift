import UIKit
import Flutter
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    // Đăng ký plugin Flutter
    GeneratedPluginRegistrant.register(with: self)

    // Gán controller
    if let controller = window?.rootViewController as? FlutterViewController {
      let channel = FlutterMethodChannel(name: "com.example.local_notifications",
                                         binaryMessenger: controller.binaryMessenger)
      
      channel.setMethodCallHandler { (call, result) in
        if call.method == "scheduleDailyNotification" {
          if let args = call.arguments as? [String: Any],
             let hour = args["hour"] as? Int,
             let minute = args["minute"] as? Int {
            self.scheduleDailyNotification(atHour: hour, minute: minute)
            result("✅ Daily notification scheduled at \(hour):\(minute)")
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing hour or minute", details: nil))
          }
        } else if call.method == "scheduleWeeklyNotification" {
          if let args = call.arguments as? [String: Any],
             let weekday = args["weekday"] as? Int,
             let hour = args["hour"] as? Int,
             let minute = args["minute"] as? Int {
            self.scheduleWeeklyNotification(onWeekday: weekday, hour: hour, minute: minute)
            result("✅ Weekly notification scheduled for weekday \(weekday) at \(hour):\(minute)")
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing weekday, hour, or minute", details: nil))
          }
        } else {
          result(FlutterMethodNotImplemented)
        }
      }
    }

    // Yêu cầu quyền gửi thông báo
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
      print(granted ? "✅ Notification permission granted" : "❌ Permission denied")
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Thông báo hàng ngày
  func scheduleDailyNotification(atHour hour: Int, minute: Int) {
    let content = UNMutableNotificationContent()
    content.title = "Thông báo định kỳ"
    content.body = "Thông báo mỗi ngày lúc \(hour):\(String(format: "%02d", minute))"
    content.sound = .default

    var dateComponents = DateComponents()
    dateComponents.hour = hour
    dateComponents.minute = minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(
      identifier: "daily_notification_\(hour)_\(minute)",
      content: content,
      trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("❌ Notification error: \(error)")
      } else {
        print("✅ Daily notification scheduled")
      }
    }
  }

  // Thông báo hàng tuần
  func scheduleWeeklyNotification(onWeekday weekday: Int, hour: Int, minute: Int) {
    let content = UNMutableNotificationContent()
    content.title = "Thông báo hàng tuần"
    content.body = "Thông báo lúc \(hour):\(String(format: "%02d", minute)) vào thứ \(weekday)"
    content.sound = .default

    var dateComponents = DateComponents()
    dateComponents.weekday = weekday
    dateComponents.hour = hour
    dateComponents.minute = minute

    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

    let request = UNNotificationRequest(
      identifier: "weekly_notification_\(weekday)_\(hour)_\(minute)",
      content: content,
      trigger: trigger
    )

    UNUserNotificationCenter.current().add(request) { error in
      if let error = error {
        print("❌ Notification error: \(error)")
      } else {
        print("✅ Weekly notification scheduled")
      }
    }
  }
}
