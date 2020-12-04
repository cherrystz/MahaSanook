//
//  SignInViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 3/12/2563 BE.
//

import Firebase
import GoogleSignIn
import FBSDKLoginKit
import UIKit

class SignInViewController: UIViewController, LoginButtonDelegate {

    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var googleSignInButton: UIButton!
    @IBOutlet weak var facebookSignInButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    
    let defaults = UserDefaults.standard
    let loginButton = FBLoginButton()
    var emailText = String()
    var passwordText = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.text = emailText
        passwordField.text = passwordText
        
        loginButton.delegate = self
        
        if Auth.auth().currentUser != nil {
            // User is signed in.
            let nvc = storyboard?.instantiateViewController(identifier: "loginSuccess") as! MainTabBarViewController
            UIApplication.shared.windows.first?.rootViewController = nvc
        }
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))

            //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
            //tap.cancelsTouchesInView = false

        view.addGestureRecognizer(tap)
        
        GIDSignIn.sharedInstance()?.presentingViewController = self
        
        emailField.isDefaultTextField()
        passwordField.isDefaultTextField()
        signInButton.isDefaultButton()
        googleSignInButton.isDefaultButton()
        facebookSignInButton.isDefaultButton()
        
        activityIndicatorRunning(false)
        errorLabel.text = ""
        // Do any additional setup after loading the view.
    }
    
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    @IBAction func didTapSignInButton(_ sender: Any) {
        if let email = self.emailField.text , let password = self.passwordField.text{
            
            errorLabel.text = ""
            activityIndicatorRunning(true)
            
            Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
              guard let strongSelf = self else { return }
                let errorLocal = error?.localizedDescription ?? ""
                if errorLocal.isEmpty {
                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.activityIndicator.isHidden = true
                    strongSelf.activityIndicatorRunning(false)
                    self?.loginSuccess()
                }
                else {
                    strongSelf.activityIndicator.stopAnimating()
                    strongSelf.activityIndicator.isHidden = true
                    strongSelf.errorLabel.text = "Error: \(errorLocal)"
                    strongSelf.activityIndicatorRunning(false)
                }
            }
        }
    }
    
    @IBAction func didTapGoogleButton(_ sender: Any) {
        GIDSignIn.sharedInstance().signIn()
    }
    
    @IBAction func didTapFacebookButton(_ sender: Any) {
        loginButton.sendActions(for: .touchUpInside)
    }
    
    // MARK: - Facebook Function
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if AccessToken.current?.tokenString != nil {
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
                    
            Auth.auth().signIn(with: credential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                else {
                    self.loginSuccess()
                }
            }
        }
    }
        
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func activityIndicatorRunning(_ run: Bool) {
        activityIndicator.isHidden = !run
        if run {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
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

