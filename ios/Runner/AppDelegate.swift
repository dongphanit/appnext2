import UIKit
import Flutter
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        // ✅ Gọi super trước để window, controller được tạo
        let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // ✅ Lúc này window đã tồn tại
        if let controller = window?.rootViewController as? FlutterViewController {
            let channel = FlutterMethodChannel(name: "com.example.local_notifications",
                                               binaryMessenger: controller.binaryMessenger)
            
            channel.setMethodCallHandler { [weak self] (call, result) in
                guard let self = self else { return }
                
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
        } else {
            print("❌ Không tìm thấy FlutterViewController")
        }

        // ✅ Xin quyền notification
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print(granted ? "✅ Notification permission granted" : "❌ Permission denied")
        }

        return result
    }
    
    // 🔔 Notification hàng tuần
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
        let request = UNNotificationRequest(identifier: "weekly_\(weekday)_\(hour)_\(minute)",
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification scheduling error: \(error)")
            } else {
                print("✅ Weekly notification set")
            }
        }
    }

    // 🔔 Notification hàng ngày
    func scheduleDailyNotification(atHour hour: Int, minute: Int) {
        let content = UNMutableNotificationContent()
        content.title = "Thông báo mỗi ngày"
        content.body = "Vào lúc \(hour):\(String(format: "%02d", minute))"
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_\(hour)_\(minute)",
                                            content: content,
                                            trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("❌ Notification scheduling error: \(error)")
            } else {
                print("✅ Daily notification set")
            }
        }
    }
}
