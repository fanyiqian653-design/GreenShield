import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var modifyButton: UIButton!
    @IBOutlet weak var restoreButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        title = "绿盾版本修改器"
        resultLabel.text = "请点击下方按钮执行操作"
        resultLabel.textColor = .black
        
        modifyButton.setTitle("修改绿盾", for: .normal)
        modifyButton.backgroundColor = UIColor.systemGreen
        modifyButton.setTitleColor(.white, for: .normal)
        modifyButton.layer.cornerRadius = 8
        
        restoreButton.setTitle("恢复", for: .normal)
        restoreButton.backgroundColor = UIColor.systemRed
        restoreButton.setTitleColor(.white, for: .normal)
        restoreButton.layer.cornerRadius = 8
    }
    
    @IBAction func modifyButtonTapped(_ sender: UIButton) {
        resultLabel.text = "正在执行修改操作..."
        resultLabel.textColor = .black
        
        // 执行修改操作
        let success = SystemVersionModifier.autoExecute()
        
        if success {
            resultLabel.text = "修改成功！"
            resultLabel.textColor = .green
        } else {
            resultLabel.text = "修改失败，请检查系统权限"
            resultLabel.textColor = .red
        }
    }
    
    @IBAction func restoreButtonTapped(_ sender: UIButton) {
        resultLabel.text = "正在执行恢复操作..."
        resultLabel.textColor = .black
        
        // 执行恢复操作
        let success = SystemVersionModifier.restore()
        if success {
            resultLabel.text = "恢复成功！已恢复到原始状态"
            resultLabel.textColor = .green
        } else {
            resultLabel.text = "恢复失败，可能没有备份文件"
            resultLabel.textColor = .red
        }
    }
}
