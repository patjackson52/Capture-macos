import Foundation
import ServiceManagement

final class LaunchAtLoginManager {
    func toggle() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            NSLog("Launch-at-login toggle failed: %@", error.localizedDescription)
        }
    }
}
