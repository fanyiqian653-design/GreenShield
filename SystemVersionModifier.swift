import UIKit
import Darwin

class SystemVersionModifier {
    
    // 字符串加密/解密辅助方法
    private static func _aes(_ s: String) -> String {
        let k = "GD2026"
        var r = ""
        for i in 0..<s.count {
            let sc = s[s.index(s.startIndex, offsetBy: i)]
            let kc = k[k.index(k.startIndex, offsetBy: i % k.count)]
            let scv = UnicodeScalar(String(sc))!.value
            let kcv = UnicodeScalar(String(kc))!.value
            let cv = (scv ^ kcv) & 0xFF
            r.append(String(UnicodeScalar(cv)!))
        }
        return r
    }
    
    // 反调试检测
    private static func _antiDebug() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    // 备份文件路径（加密）
    private static var _backupPath: String {
        return _aes("/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist.backup")
    }
    
    // 目标文件路径（加密）
    private static var _targetPath: String {
        return _aes("/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches")
    }
    
    // 目标键名（加密）
    private static var _targetKey: String {
        return _aes("qNNddlUK+B/looNoymwgA")
    }
    
    // 获取系统版本
    private static func _getSysVer() -> String {
        return UIDevice.current.systemVersion
    }
    
    // 解析系统版本为主要版本号
    private static func _getMajorVer() -> String {
        let v = _getSysVer()
        let c = v.components(separatedBy: ".")
        if let m = c.first {
            return m
        }
        return ""
    }
    
    // 备份原始plist文件
    private static func _backupPlist(_ p: String) -> Bool {
        let pp = p.appending("/").appending(_aes("com.apple.MobileGestalt.plist"))
        
        guard FileManager.default.fileExists(atPath: pp) else {
            return false
        }
        
        do {
            try FileManager.default.copyItem(atPath: pp, toPath: _backupPath)
            return true
        } catch {
            return false
        }
    }
    
    // 修改MobileGestalt.plist文件
    private static func _modifyPlist(_ p: String) -> Bool {
        // 检测调试器
        if _antiDebug() {
            return false
        }
        
        let pp = p.appending("/").appending(_aes("com.apple.MobileGestalt.plist"))
        
        guard FileManager.default.fileExists(atPath: pp) else {
            return false
        }
        
        // 先备份原始文件
        _ = _backupPlist(p)
        
        do {
            guard let d = FileManager.default.contents(atPath: pp) else {
                return false
            }
            
            var pd: [String: Any]?
            if #available(iOS 11.0, *) {
                pd = try PropertyListSerialization.propertyList(from: d, options: [], format: nil) as? [String: Any]
            } else {
                pd = try PropertyListSerialization.propertyList(from: d, options: [], format: nil) as? [String: Any]
            }
            
            guard var dict = pd else {
                return false
            }
            
            let mv = _getMajorVer()
            dict[_targetKey] = mv
            
            let md = try PropertyListSerialization.data(fromPropertyList: dict, format: .xml, options: 0)
            if FileManager.default.createFile(atPath: pp, contents: md, attributes: nil) {
                return true
            } else {
                return false
            }
        } catch {
            return false
        }
    }
    
    // 恢复原始plist文件
    private static func _restorePlist() -> Bool {
        let pp = _targetPath.appending("/").appending(_aes("com.apple.MobileGestalt.plist"))
        
        guard FileManager.default.fileExists(atPath: _backupPath) else {
            return false
        }
        
        do {
            try FileManager.default.copyItem(atPath: _backupPath, toPath: pp)
            return true
        } catch {
            return false
        }
    }
    
    // 主方法：自动执行修改操作
    public static func autoExecute() -> Bool {
        // 检测调试器
        if _antiDebug() {
            return false
        }
        
        let p = _targetPath
        return _modifyPlist(p)
    }
    
    // 主方法：恢复原始状态
    public static func restore() -> Bool {
        // 检测调试器
        if _antiDebug() {
            return false
        }
        
        return _restorePlist()
    }
    
    // 获取主要系统版本（public）
    public static func getMajorVersion() -> String {
        return _getMajorVer()
    }
}

// 示例用法
// let filePath = "/path/to/file.txt"
// SystemVersionModifier.run(path: filePath)