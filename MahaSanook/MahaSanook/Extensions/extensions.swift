//
//  extensions.swift
//  MahaSanook
//
//  Created by Napassorn V. on 3/12/2563 BE.
//

import Foundation
import UIKit
import Firebase

extension String {
    
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }
    
    func isValidUsername() -> Bool {
        
        return self.count >= 5 && self.count <= 12 && range(of: "[^a-zA-Z0-9]", options: .regularExpression) == nil
    }
    
}

extension UIViewController {
    func loginSuccess() {
        let nvc = storyboard?.instantiateViewController(identifier: "loginSuccess") as! MainTabBarViewController
        UIApplication.shared.windows.first?.switchRootViewController(nvc, animated: true, duration: 0.3, options: .transitionCrossDissolve, completion: nil)
    }
    func logOut() {
        let signOut = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as! SignInViewController
        UIApplication.shared.windows.first?.switchRootViewController(signOut, animated: true, duration: 0.3, options: .transitionCrossDissolve, completion: nil)
    }
    func hideKeyboardWhenTappedAround() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
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

extension UIWindow {
    
    func switchRootViewController(_ viewController: UIViewController,  animated: Bool = true, duration: TimeInterval = 0.5, options: UIView.AnimationOptions = .transitionFlipFromRight, completion: (() -> Void)? = nil) {
        guard animated else {
            rootViewController = viewController
            return
        }
        
        UIView.transition(with: self, duration: duration, options: options, animations: {
            let oldState = UIView.areAnimationsEnabled
            UIView.setAnimationsEnabled(false)
            self.rootViewController = viewController
            UIView.setAnimationsEnabled(oldState)
        }) { _ in
            completion?()
        }
    }
}

extension UIImage {
       // image with rounded corners
       public func withRoundedCorners(radius: CGFloat? = nil) -> UIImage? {
           let maxRadius = min(size.width, size.height) / 2
           let cornerRadius: CGFloat
           if let radius = radius, radius > 0 && radius <= maxRadius {
               cornerRadius = radius
           } else {
               cornerRadius = maxRadius
           }
           UIGraphicsBeginImageContextWithOptions(size, false, scale)
           let rect = CGRect(origin: .zero, size: size)
           UIBezierPath(roundedRect: rect, cornerRadius: cornerRadius).addClip()
           draw(in: rect)
           let image = UIGraphicsGetImageFromCurrentImageContext()
           UIGraphicsEndImageContext()
           return image
       }
    
    func resizeImage(_ targetSize: CGSize) -> UIImage {
        let size = self.size

        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        self.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
}