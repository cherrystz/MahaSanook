//
//  SignUpViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 3/12/2563 BE.
//

import UIKit
import Firebase

class SignUpViewController: UIViewController {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        emailField.becomeFirstResponder()
        emailField.isDefaultTextField()
        passwordField.isDefaultTextField()
        displayNameField.isDefaultTextField()
        errorLabel.text = ""
        activityIndicator.isHidden = true
        signUpButton.layer.cornerRadius = 15
        // Do any additional setup after loading the view.
    }
    
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func didEndEditingEmail(_ sender: Any) {
        self.emailValidCheck()
    }
    @IBAction func didTapDismiss(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapSignUp(_ sender: Any) {
        let error = self.emailValidCheck()
        if error {
            if let password = passwordField.text {
                let passRegex = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$")
                if passRegex.evaluate(with: password) {
                    
                    let email = emailField.text!
                    activityIndicator.isHidden = false
                    activityIndicator.startAnimating()
                    errorLabel.text = ""
                    
                    if displayNameField.text!.count > 4 {
                        Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                            
                            if error != nil {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                self.errorLabel.text = "Error: \((error?.localizedDescription)!)"
                            }
                            else {
                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                
                                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                                changeRequest?.displayName = self.displayNameField.text
                                changeRequest?.commitChanges { (error) in
                                    if error != nil {
                                        self.activityIndicator.stopAnimating()
                                        self.activityIndicator.isHidden = true
                                        self.errorLabel.text = "Error: \((error?.localizedDescription)!)"
                                    }
                                    else {
                                        let alert = UIAlertController(title: "Complete", message: "Your email has been sign up!", preferredStyle: .alert)
                                        let action = UIAlertAction(title: "Done", style: .cancel, handler: { _ in
                                            self.loginSuccess()
                                        })
                                        alert.addAction(action)
                                        self.present(alert, animated: true, completion: nil)
                                    }
                                }
                            }
                        }
                    }
                    else {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.errorLabel.text = "Error: Display name must be more 4 characters"
                    }
                }
                else {
                    errorLabel.text = "Error: Password must be contains big letter and number! "
                }
            }
            else {
                errorLabel.text = "Error: \(error)"
            }
        }
    }
    
    func emailValidCheck() -> Bool{
        let email = self.emailField.text!
        if email.isEmpty {
            errorLabel.text = "Error: missing email!"
        }
        else if !email.isValidEmail() {
            errorLabel.text = "Error: email are not like the pattern, Try again!"
        }
        else {
            errorLabel.text = ""
            return true
        }
        return false
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
