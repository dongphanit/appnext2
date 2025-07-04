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
        // Xử lý các phương thức gọi từ Flutter
        
        if call.method == "scheduleDailyNotification" {
          if let args = call.arguments as? [String: Any],
          let content = args["content"] as? String,
             let hour = args["hour"] as? Int,
             let minute = args["minute"] as? Int {
            self.scheduleDailyNotification(bodyText: content, atHour: hour, minute: minute)
            result("✅ Daily notification scheduled at \(hour):\(minute)")
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing hour or minute", details: nil))
          }
        }
        //cancelDailyNotification
        else if call.method == "cancelDailyNotification" {
          if let args = call.arguments as? [String: Any],
             let hour = args["hour"] as? Int,
             let minute = args["minute"] as? Int {
            self.cancelDailyNotification(atHour: hour, minute: minute)
            result("✅ Daily notification cancelled at \(hour):\(minute)")
          } else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing hour or minute", details: nil))
          }
        }
        // Thông báo hàng tuần
         else if call.method == "scheduleWeeklyNotification" {
          if let args = call.arguments as? [String: Any],
          let content = args["content"] as? String,
             let weekday = args["weekday"] as? Int,
             let hour = args["hour"] as? Int,
             let minute = args["minute"] as? Int {
            self.scheduleWeeklyNotification(onWeekday: weekday, bodyText: content, hour: hour, minute: minute)
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
  func scheduleDailyNotification( bodyText: String, atHour hour: Int, minute: Int) {
    let content = UNMutableNotificationContent()
    content.title = "Nhắc nhở"
    content.body = bodyText
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
   // Huỷ thông báo hằng ngày theo giờ và phút
    func cancelDailyNotification(atHour hour: Int, minute: Int) {
        let identifier = "daily_notification_\(hour)_\(minute)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        print("🛑 Cancelled daily notification at \(hour):\(String(format: "%02d", minute))")
    }

  // Thông báo hàng tuần
  func scheduleWeeklyNotification(onWeekday weekday: Int, bodyText: String, hour: Int, minute: Int) {
    let content = UNMutableNotificationContent()
    content.title = "Nhắc nhở"
    content.body = bodyText
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
