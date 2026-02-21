import AppKit
import Carbon.HIToolbox

final class GlobalShortcutService {
    private var hotKeyRef: EventHotKeyRef?
    private var handlerRef: EventHandlerRef?
    var onTrigger: (() -> Void)?

    func registerDefaultShortcut() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, event, userData in
            guard let userData else { return noErr }
            let service = Unmanaged<GlobalShortcutService>.fromOpaque(userData).takeUnretainedValue()
            var hotKeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID), nil, MemoryLayout<EventHotKeyID>.size, nil, &hotKeyID)
            if hotKeyID.id == 1 { service.onTrigger?() }
            return noErr
        }, 1, &eventType, UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque()), &handlerRef)

        let id = EventHotKeyID(signature: OSType(0x43505452), id: 1) // CPTR
        RegisterEventHotKey(UInt32(kVK_ANSI_C), UInt32(cmdKey | optionKey), id, GetApplicationEventTarget(), 0, &hotKeyRef)
    }
}
