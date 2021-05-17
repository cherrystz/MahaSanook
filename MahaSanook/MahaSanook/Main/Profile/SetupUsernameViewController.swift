//
//  SetupUsernameViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 5/12/2563 BE.
//

import UIKit
import Firebase

class SetupUsernameViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var setup: UIButton!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup.isDefaultButton()
        self.hideKeyboardWhenTappedAround() 
        
        errorLabel.text = ""
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func setupUsername() {
        
        self.activityIndicator.startAnimating()
        self.activityIndicator.isHidden = false
        errorLabel.text = ""
        
        if username.text!.isValidUsername() {
            
            let re = Database.database().reference()
            re.child("user").observeSingleEvent(of: .value, with: { (snapshot) in

                if snapshot.hasChild(self.username.text!.lowercased()){

                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.errorLabel.text = "Username does exists!"

                }
                else {
                    let user = Auth.auth().currentUser
                    let ref = createUser.refs.databaseUser.child(self.username.text!.lowercased())

                    let userCreate = [
                        "uid": user!.uid,
                        "profile_url": user?.photoURL?.relativeString ?? "",
                        "display_name": user!.displayName
                    ]

                    ref.setValue(userCreate)
                    
                    let ref2 = UsernameCreate.refs.databaseUsername.child(user!.uid)

                    let create = [
                        "username": self.username.text!.lowercased(),
                        "display_name": user!.displayName
                    ]

                    ref2.setValue(create)
                    
                    let ref3 = Friends.refs.databaseFriends.child(self.username.text!.lowercased())
                    
                    let friends = [
                        "request": [
                            "0" : ""
                        ],
                        "friends": [
                            "0" : ""
                        ]
                    ]
                    
                    ref3.setValue(friends)
                    
                    let alert = UIAlertController(title: "Success", message: "Your username has been set!", preferredStyle: .alert)
                    
                    alert.addAction(.init(title: "Done", style: .cancel, handler: { _ in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }
        else {
            self.activityIndicator.stopAnimating()
            self.activityIndicator.isHidden = true
            
            errorLabel.text = "Username must be 5-12 characters and no symbol"
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
