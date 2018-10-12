//
//  MyBalanceViewController.swift
//  Balance
//
//  Created by Michael on 4/9/18.
//  Copyright © 2018 poshbaboon. All rights reserved.
//

import UIKit

class CustomRect : UIView {
    
    init(frame: CGRect, level: CGFloat, color: UIColor) {
        super.init(frame: frame)
        let levelLayer = CAShapeLayer()
        levelLayer.path = UIBezierPath(roundedRect: CGRect(x: frame.origin.x,
                                                           y: frame.origin.y,
                                                           width: frame.width * level,
                                                           height: frame.height),
                                       cornerRadius: 10).cgPath
        levelLayer.fillColor = color.cgColor
        self.layer.addSublayer(levelLayer)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("Required, but Will not be called in a Playground")
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}

class MyBalanceViewController: UIViewController {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var topBlur: UIView!
    @IBOutlet weak var bottomBlur: UIView!
    
    @IBOutlet weak var leisureBar: UIView!
    @IBOutlet weak var workBar: UIView!
    @IBOutlet weak var sleepBar: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let blurEffect1 = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect1)
        blurEffectView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView1.frame = topBlur.bounds
        blurEffectView1.alpha = 0.66
        topBlur.addSubview(blurEffectView1)
        
        let blurEffect2 = UIBlurEffect(style: UIBlurEffectStyle.regular)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect2)
        blurEffectView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurEffectView2.frame = topBlur.bounds
        blurEffectView2.alpha = 0.66
        bottomBlur.addSubview(blurEffectView2)
        
        let height = mainView.bounds.height
        
        let leisureHeight = height * 0.75
        let leisurePos = (height/2) - (leisureHeight/2)
        print(leisurePos)
        
        let workHeight = (height * 0.31)
        let workPos = (height/2) - (workHeight/2)
        print(workPos)
        
        let sleepHeight = (height * 0.52)
        let sleepPos = (height/2) - (sleepHeight/2)
        print(sleepPos)
        
        let leisureView = CustomRect(frame: CGRect(x: 0, y: leisurePos, width: leisureBar.frame.width, height: leisureHeight + 10), level: 1, color: UIColor(hexString: "#F0584F"))
        let workView = CustomRect(frame: CGRect(x: 0, y: workPos, width: workBar.frame.width, height: workHeight + 10), level: 1, color: UIColor(hexString: "#FC9C20"))
        let sleepView = CustomRect(frame: CGRect(x: 0, y: sleepPos, width: sleepBar.frame.width, height: sleepHeight + 10), level: 1, color: UIColor(hexString: "#FAD93B"))
        
        leisureBar.addSubview(leisureView)
        workBar.addSubview(workView)
        sleepBar.addSubview(sleepView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
    }

}
