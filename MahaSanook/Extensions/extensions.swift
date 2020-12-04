//
//  extensions.swift
//  MahaSanook
//
//  Created by Napassorn V. on 3/12/2563 BE.
//

import Foundation
import UIKit

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
}

extension UIViewController {
    func loginSuccess() {
        let nvc = storyboard?.instantiateViewController(identifier: "loginSuccess") as! MainTabBarViewController
        UIApplication.shared.windows.first?.rootViewController = nvc
    }
}

extension UITextField {
    
    func isDefaultTextField() {
        self.layer.cornerRadius = self.frame.height/3
        self.layer.borderWidth = 0.5
        self.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.textAlignment = .left
        self.textRect(forBounds: bounds.inset(by: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)))
        self.placeholderRect(forBounds: bounds.inset(by: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)))
        self.editingRect(forBounds: bounds.inset(by: UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)))
    }
    
}

extension UIButton {
    
    func isDefaultButton() {
        self.layer.cornerRadius = self.frame.height/2
        self.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.layer.borderWidth = 0.5
    }
    
}

extension UIImageView {
    
    func cornerRadius() {
        self.layer.cornerRadius = self.frame.height/2
    }
}
