import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var cardView: UIView!
    
    private var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    private var majorVersion: String {
        return systemVersion.components(separatedBy: ".").first ?? "0"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateVersionInfo()
    }
    
    private func setupUI() {
        // 设置背景
        backgroundImageView.image = UIImage(named: "background")
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.7
        
        // 设置卡片视图
        cardView.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        cardView.layer.cornerRadius = 20
        cardView.layer.shadowColor = UIColor.black.cgColor
        cardView.layer.shadowOpacity = 0.1
        cardView.layer.shadowOffset = CGSize(width: 0, height: 2)
        cardView.layer.shadowRadius = 10
        
        // 设置标题
        titleLabel.text = "绿盾版本修改器"
        titleLabel.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        titleLabel.textColor = UIColor(red: 0.2, green: 0.5, blue: 0.3, alpha: 1.0)
        
        // 设置状态标签
        statusLabel.text = "请点击下方按钮执行操作"
        statusLabel.font = UIFont.systemFont(ofSize: 16)
        statusLabel.textColor = UIColor.gray
        statusLabel.textAlignment = .center
        
        // 设置修改按钮
        modifyButton.setTitle("修改绿盾", for: .normal)
        modifyButton.backgroundColor = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
        modifyButton.setTitleColor(.white, for: .normal)
        modifyButton.layer.cornerRadius = 12
        modifyButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        modifyButton.layer.shadowColor = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 0.3).cgColor
        modifyButton.layer.shadowOpacity = 0.5
        modifyButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        modifyButton.layer.shadowRadius = 8
        
        // 设置恢复按钮
        restoreButton.setTitle("恢复", for: .normal)
        restoreButton.backgroundColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        restoreButton.setTitleColor(.white, for: .normal)
        restoreButton.layer.cornerRadius = 12
        restoreButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        restoreButton.layer.shadowColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 0.3).cgColor
        restoreButton.layer.shadowOpacity = 0.5
        restoreButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        restoreButton.layer.shadowRadius = 8
    }
    
    private func updateVersionInfo() {
        versionLabel.text = "当前系统版本: \(systemVersion)"
        versionLabel.font = UIFont.systemFont(ofSize: 18)
        versionLabel.textColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0)
    }
    
    @IBAction func modifyButtonTapped(_ sender: UIButton) {
        statusLabel.text = "正在执行修改操作..."
        statusLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // 执行修改操作
        let success = GreenShieldManager.modifySystemVersion()
        
        if success {
            statusLabel.text = "修改成功！"
            statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
            
            // 添加成功动画
            animateSuccess()
        } else {
            statusLabel.text = "修改失败，请检查系统权限"
            statusLabel.textColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        }
    }
    
    @IBAction func restoreButtonTapped(_ sender: UIButton) {
        statusLabel.text = "正在执行恢复操作..."
        statusLabel.textColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0)
        
        // 执行恢复操作
        let success = GreenShieldManager.restoreOriginalVersion()
        
        if success {
            statusLabel.text = "恢复成功！"
            statusLabel.textColor = UIColor(red: 0.2, green: 0.6, blue: 0.3, alpha: 1.0)
            
            // 添加成功动画
            animateSuccess()
        } else {
            statusLabel.text = "恢复失败，可能没有备份文件"
            statusLabel.textColor = UIColor(red: 0.8, green: 0.3, blue: 0.3, alpha: 1.0)
        }
    }
    
    private func animateSuccess() {
        // 添加按钮动画
        UIView.animate(withDuration: 0.3, animations: {
            self.modifyButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
            self.restoreButton.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.modifyButton.transform = .identity
                self.restoreButton.transform = .identity
            }
        }
        
        // 添加卡片视图动画
        UIView.animate(withDuration: 0.5, animations: {
            self.cardView.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
        }) { _ in
            UIView.animate(withDuration: 0.5) {
                self.cardView.transform = .identity
            }
        }
    }
}
