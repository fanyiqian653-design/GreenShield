import Foundation

class GreenShieldManager {
    
    // 目标文件路径
    private static let targetPath = "/var/containers/Shared/SystemGroup/systemgroup.com.apple.mobilegestaltcache/Library/Caches/com.apple.MobileGestalt.plist"
    
    // 目标键名
    private static let targetKey = "qNNddlUK+B/looNoymwgA"
    
    // 备份文件路径
    private static let backupPath = "/var/mobile/Library/Preferences/com.greenshield.backup.plist"
    
    // 加密方法
    private static func encrypt(_ string: String) -> String {
        let key = "GD2026"
        var result = ""
        for i in 0..<string.count {
            let sIndex = string.index(string.startIndex, offsetBy: i)
            let kIndex = key.index(key.startIndex, offsetBy: i % key.count)
            let sChar = string[sIndex]
            let kChar = key[kIndex]
            let sValue = UnicodeScalar(String(sChar))!.value
            let kValue = UnicodeScalar(String(kChar))!.value
            let encryptedValue = (sValue ^ kValue) & 0xFF
            result.append(String(UnicodeScalar(encryptedValue)!))
        }
        return result
    }
    
    // 防调试检测
    private static func antiDebug() -> Bool {
        var info = kinfo_proc()
        var size = MemoryLayout<kinfo_proc>.stride
        var mib: [Int32] = [CTL_KERN, KERN_PROC, KERN_PROC_PID, getpid()]
        sysctl(&mib, UInt32(mib.count), &info, &size, nil, 0)
        return (info.kp_proc.p_flag & P_TRACED) != 0
    }
    
    // 获取主要系统版本
    private static func getMajorVersion() -> String {
        let systemVersion = UIDevice.current.systemVersion
        return systemVersion.components(separatedBy: ".").first ?? "0"
    }
    
    // 修改系统版本
    public static func modifySystemVersion() -> Bool {
        // 检测调试器
        if antiDebug() {
            return false
        }
        
        do {
            // 读取原始文件
            let data = try Data(contentsOf: URL(fileURLWithPath: targetPath))
            
            // 解析plist
            var propertyList: [String: Any]
            if let plist = try PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] {
                propertyList = plist
            } else {
                return false
            }
            
            // 备份原始文件
            try data.write(to: URL(fileURLWithPath: backupPath), options: .atomic)
            
            // 获取主要版本
            let majorVersion = getMajorVersion()
            
            // 修改目标键值
            propertyList[targetKey] = majorVersion
            
            // 写回文件
            let modifiedData = try PropertyListSerialization.data(fromPropertyList: propertyList, format: .xml, options: 0)
            try modifiedData.write(to: URL(fileURLWithPath: targetPath), options: .atomic)
            
            return true
        } catch {
            return false
        }
    }
    
    // 恢复原始版本
    public static func restoreOriginalVersion() -> Bool {
        // 检测调试器
        if antiDebug() {
            return false
        }
        
        do {
            // 检查备份文件是否存在
            if !FileManager.default.fileExists(atPath: backupPath) {
                return false
            }
            
            // 读取备份文件
            let backupData = try Data(contentsOf: URL(fileURLWithPath: backupPath))
            
            // 写回目标文件
            try backupData.write(to: URL(fileURLWithPath: targetPath), options: .atomic)
            
            return true
        } catch {
            return false
        }
    }
}

// 导入必要的头文件
#if os(iOS)
import Darwin
import UIKit

// 定义必要的常量和结构体
let CTL_KERN = 1
let KERN_PROC = 14
let KERN_PROC_PID = 1
let P_TRACED = 0x00000080

struct kinfo_proc {
    var kp_proc: proc
    var kp_eproc: eproc
}

struct proc {
    var p_flag: UInt32
    var p_stat: Int32
    var p_pid: Int32
    var p_oppid: Int32
    var p_ppid: Int32
    var p_ruid: uid_t
    var p_svuid: uid_t
    var p_rgid: gid_t
    var p_svgid: gid_t
    var p_jobc: UInt16
    var p_spare: UInt16
    var p_comm: (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)
    var p_priority: Int32
    var p_usrpri: Int32
    var p_nice: Int32
    var p_addr: UnsafeMutableRawPointer?
    var p_size: Int
    var p_rssize: Int
    var p_vm_rss: Int
    var p_vm_tsize: Int
    var p_vm_dsize: Int
    var p_vm_ssize: Int
    var p_wchan: UnsafeMutableRawPointer?
    var p_wmesg: (Int8, Int8, Int8, Int8)
    var p_swtime: Int
    var p_slptime: Int
    var p_cpu: Int
    var p_oldcpu: Int
    var p_ctime: timeval
    var p_utime: timeval
    var p_stime: timeval
    var p_cutime: timeval
    var p_cstime: timeval
    var p_start: timeval
    var p_realstart: timeval
    var p_childtime: Int
    var p_traceflag: Int32
    var p_tracep: Int32
    var p_siglist: UInt32
    var p_sigmask: UInt32
    var p_sigignore: UInt32
    var p_sigcatch: UInt32
    var p_sigthread: Int32
    var p_flag2: UInt32
    var p_xstat: Int32
    var p_acflag: Int32
    var p_ru: rusage
    var p_startzero: Int
    var p_emul: Int32
    var p_debugger: Int32
    var p_estcpu: Int
    var p_cpticks: Int
    var p_maxslp: Int
    var p_spare1: Int
    var p_spare2: Int
    var p_spare3: Int
    var p_spare4: Int
    var p_spare5: Int
    var p_spare6: Int
    var p_spare7: Int
    var p_spare8: Int
}

struct eproc {
    var e_paddr: UnsafeMutableRawPointer?
    var e_sess: UnsafeMutableRawPointer?
    var e_tsess: UnsafeMutableRawPointer?
    var e_proc: UnsafeMutableRawPointer?
    var e_pid: Int32
    var e_ppid: Int32
    var e_pgid: Int32
    var e_tpgid: Int32
    var e_sid: Int32
    var e_jobid: Int32
    var e_uid: uid_t
    var e_gid: gid_t
    var e_ruid: uid_t
    var e_rgid: gid_t
    var e_svuid: uid_t
    var e_svgid: gid_t
    var e_comm: (Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8, Int8)
    var e_flag: UInt32
    var e_status: Int32
    var e_realuid: uid_t
    var e_realvgid: gid_t
    var e_cred: UnsafeMutableRawPointer?
    var e_xcred: UnsafeMutableRawPointer?
    var e_audit: UnsafeMutableRawPointer?
    var e_ucred: UnsafeMutableRawPointer?
    var e_ru: rusage
    var e_start: timeval
    var e_childtime: Int
    var e_kstack: Int
    var e_kstack_size: Int
    var e_vm: UnsafeMutableRawPointer?
    var e_vmmap: UnsafeMutableRawPointer?
    var e_vmspace: UnsafeMutableRawPointer?
    var e_uthread: UnsafeMutableRawPointer?
    var e_pthread: UnsafeMutableRawPointer?
    var e_td: UnsafeMutableRawPointer?
    var e_sigqueue: UnsafeMutableRawPointer?
    var e_siglist: UInt32
    var e_sigmask: UInt32
    var e_sigignore: UInt32
    var e_sigcatch: UInt32
    var e_sigthread: Int32
    var e_flag2: UInt32
    var e_xstat: Int32
    var e_acflag: Int32
    var e_estcpu: Int
    var e_cpticks: Int
    var e_maxslp: Int
    var e_spare1: Int
    var e_spare2: Int
    var e_spare3: Int
    var e_spare4: Int
    var e_spare5: Int
    var e_spare6: Int
    var e_spare7: Int
    var e_spare8: Int
}

struct timeval {
    var tv_sec: time_t
    var tv_usec: suseconds_t
}

struct rusage {
    var ru_utime: timeval
    var ru_stime: timeval
    var ru_maxrss: Int
    var ru_ixrss: Int
    var ru_idrss: Int
    var ru_isrss: Int
    var ru_minflt: Int
    var ru_majflt: Int
    var ru_nswap: Int
    var ru_inblock: Int
    var ru_oublock: Int
    var ru_msgsnd: Int
    var ru_msgrcv: Int
    var ru_nsignals: Int
    var ru_nvcsw: Int
    var ru_nivcsw: Int
}
#endif
