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
    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var displayNameField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signUpButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false

        
        emailField.becomeFirstResponder()
        emailField.isDefaultTextField()
        passwordField.isDefaultTextField()
        usernameField.isDefaultTextField()
        displayNameField.isDefaultTextField()
        errorLabel.text = ""
        activityIndicator.isHidden = true
        signUpButton.layer.cornerRadius = 15
        // Do any additional setup after loading the view.
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
                    
                    let username = usernameField.text!
                    if username.isValidUsername() {
                        
                        let re = Database.database().reference()
                        re.child("user").observeSingleEvent(of: .value, with: { (snapshot) in

                            if snapshot.hasChild(self.usernameField.text!.lowercased()){

                                self.activityIndicator.stopAnimating()
                                self.activityIndicator.isHidden = true
                                self.errorLabel.text = "Error: Username does exists!"

                            }
                            else {
                                if self.displayNameField.text!.count >= 4 {
                                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                                
                                if error != nil {
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true
                                    self.errorLabel.text = "Error: \((error?.localizedDescription)!)"
                                }
                                else {
                                    let user = Auth.auth().currentUser
                                    self.activityIndicator.stopAnimating()
                                    self.activityIndicator.isHidden = true
                                    
                                    let changeRequest = user?.createProfileChangeRequest()
                                    changeRequest?.displayName = self.displayNameField.text
                                    changeRequest?.commitChanges { (error) in
                                        if error != nil {
                                            self.activityIndicator.stopAnimating()
                                            self.activityIndicator.isHidden = true
                                            self.errorLabel.text = "Error: \((error?.localizedDescription)!)"
                                        }
                                        else {
                                            
                                            let ref = createUser.refs.databaseUser.child(self.usernameField.text!.lowercased())

                                            let userCreate = [
                                                "uid": user!.uid,
                                                "profile_url": user?.photoURL?.relativeString ?? "",
                                                "display_name": user!.displayName
                                            ]

                                            ref.setValue(userCreate)
                                            
                                            let ref2 = UsernameCreate.refs.databaseUsername.child(user!.uid)

                                            let create = [
                                                "username": self.usernameField.text!.lowercased(),
                                                "display_name": user!.displayName
                                            ]

                                            ref2.setValue(create)
                                            
                                            let ref3 = Friends.refs.databaseFriends.child(self.usernameField.text!.lowercased())
                                            
                                            let friends = [
                                                "request": [
                                                    "0" : ""
                                                ],
                                                "friends": [
                                                    "0" : ""
                                                ]
                                            ]
                                            
                                            ref3.setValue(friends)
                                            
                                            
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
                })
                        
                    }
                    else {
                        self.activityIndicator.stopAnimating()
                        self.activityIndicator.isHidden = true
                        self.errorLabel.text = "Error: Display name must be more 5-12 characters and no symbol"
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
