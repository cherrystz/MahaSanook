//
//  UpdateProfileViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 4/12/2563 BE.
//

import UIKit
import Firebase
import FBSDKLoginKit

class UpdateProfileViewController: UIViewController {
    
    @IBOutlet weak var imageProfileView: UIButton!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var updateButton: UIButton!
    
    
    let user = Auth.auth().currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let url = user?.photoURL
        if url != nil {
            do {
                let imageData = try Data(contentsOf: url!)
                imageProfileView.setBackgroundImage(UIImage.init(data: imageData)?.withRoundedCorners(), for: .normal)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        if user?.displayName != nil {
            displayName.text = (user?.displayName)!
        }
        
        errorLabel.text = ""
        imageProfileView.layer.cornerRadius = imageProfileView.frame.height/2
        displayName.isDefaultTextField()
        updateButton.isDefaultButton()
        activityIndicatorRunning(false)
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func didTapUpdate() {
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        activityIndicatorRunning(true)
        if displayName.text != user?.displayName {
            changeRequest?.displayName = displayName.text
            changeRequest?.commitChanges { (error) in
                if error != nil {
                    self.errorLabel.text = "Error: \((error?.localizedDescription)!)"
                    self.activityIndicatorRunning(false)
                }
                else {
                    do {
                        try Auth.auth().signOut()
                        let loginManager = LoginManager()
                        loginManager.logOut()
                        
                    let alert = UIAlertController(title: "Success", message: "Update profile complete!\nPlease Sign in again.", preferredStyle: .alert)
                    alert.addAction(.init(title: "Done", style: .cancel, handler: { _ in
                        self.logOut()
                    }))
                    self.present(alert, animated: true, completion: nil)
                    self.activityIndicatorRunning(false)
                    }
                    catch let signOutError as NSError {
                      print ("Error signing out: %@", signOutError)
                    }
                }
            }
        }
        else {
            activityIndicatorRunning(false)
            errorLabel.text = "This name has not change! Please try again."
        }
        
    }
    
    @IBAction func didTapChangeProfilePicture() {
        
    }
    
    @IBAction func didTapBack() {
        self.navigationController?.popViewController(animated: true)
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
