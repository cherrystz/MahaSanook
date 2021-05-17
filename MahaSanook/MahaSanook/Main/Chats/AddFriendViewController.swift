//
//  AddFriendViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 5/12/2563 BE.
//

import UIKit
import Firebase

class AddFriendViewController: UIViewController {
    
    @IBOutlet weak var username: UITextField!
    @IBOutlet weak var addFriend: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var errorDescription: UILabel!
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var nameProfile: UILabel!
    @IBOutlet weak var asFriendOrYour: UILabel!
    @IBOutlet weak var submit: UIButton!
    
    var usernameSelf: String = ""
    
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        addFriend.isDefaultButton()
        username.isDefaultTextField()
        submit.isDefaultButton()
        imageProfile.cornerRadius()
        
        
        addFriend.isUserInteractionEnabled = false
        errorDescription.text = ""
        asFriendOrYour.text = ""
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        showProfile(false)
        
        ref.child("username").observeSingleEvent(of: .value, with: { (snapshot) in

            if snapshot.hasChild(Auth.auth().currentUser!.uid){
                let f = snapshot.childSnapshot(forPath: Auth.auth().currentUser!.uid).value as! [String:String]
                self.usernameSelf = f["username"]!
                
                self.activityIndicator.stopAnimating()
                self.activityIndicator.isHidden = true
                self.addFriend.isUserInteractionEnabled = true
            }
        })
        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func didAddFriend() {
        
        showProfile(false)
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        addFriend.isUserInteractionEnabled = false
        errorDescription.text = ""
        
        
        if username.text!.isValidUsername() {
            let re = Database.database().reference()
            re.child("user").observeSingleEvent(of: .value, with: { (snapshot) in

                if snapshot.hasChild(self.username.text!.lowercased()){
                    let x = snapshot.childSnapshot(forPath: self.username.text!).value as! [String:String]
                    
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    
                    self.showProfile(true)
                    self.submitShow(false)
                    self.errorDescription.text = ""
                    //image
                    if x["profile_url"]! == "" {
                        self.imageProfile.image = UIImage(systemName: "person.circle")
                    }
                    else {
                        do {
                            let url = URL(string: x["profile_url"]!)
                            let data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                            self.imageProfile.image = UIImage(data: data)
                        }
                        catch {
                            print(error.localizedDescription)
                        }
                    }
                    
                    //name
                    self.nameProfile.text = x["display_name"]!
                    
                    var flag = true
                    
                    self.ref.child("/friends/\(self.usernameSelf)/friends").observeSingleEvent(of: .value, with: {(snapshot) in
                        let snap = snapshot.value as! [String]
                        
                        for i in snap {
                            if i == self.username.text!{
                                self.asFriendOrYour.text = "Have been added friend!"
                                self.submit.isHidden = true
                                self.submit.isUserInteractionEnabled = false
                                flag = false
                                break
                            }
                        }
                        
                        if x["uid"]! == Auth.auth().currentUser!.uid {
                            self.asFriendOrYour.text = "Cannot add your self!"
                            self.submit.isHidden = true
                            self.submit.isUserInteractionEnabled = false
                            flag = false
                        }
                    })
                    
                    self.ref.child("/friends/\(self.usernameSelf)/request").observeSingleEvent(of: .value, with: {(snapshot) in
                        let snap = snapshot.value as! [String]
                        
                        for i in snap {
                            if i == self.username.text!{
                                self.asFriendOrYour.text = "Have been added friend! Check your request!"
                                self.submit.isHidden = true
                                self.submit.isUserInteractionEnabled = false
                                flag = false
                                break
                            }
                        }
                        
                        if flag {
                            self.submitShow(true)
                        }
                    })
                    
                    
                    
                }
                else {
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.showProfile(false)
                    self.errorDescription.text = "User not found!"
                }
            })
        }
        else {
            errorDescription.text = "Username must be 5-12 characters and no symbol"
            activityIndicator.isHidden = true
            activityIndicator.stopAnimating()
            addFriend.isUserInteractionEnabled = false
        }
        
        addFriend.isUserInteractionEnabled = true
    }
    
    @IBAction func didSubmit() {
        let ref = Database.database().reference()
        
        ref.child("friends").child(username.text!).child("request").observeSingleEvent(of: .value, with: {(snapshot) in
            var snap = snapshot.value as! [String]
            snap.append(self.usernameSelf)
            let childUpdates = ["/friends/\(self.username.text!)/request" : snap]
            ref.updateChildValues(childUpdates)
        })
        
        ref.child("friends").child(usernameSelf).child("friends").observeSingleEvent(of: .value, with: {(snapshot) in
            var snap = snapshot.value as! [String]
            snap.append(self.username.text!)
            let childUpdates = ["/friends/\(self.usernameSelf)/friends" : snap]
            ref.updateChildValues(childUpdates)
        })
        
        let alert = UIAlertController(title: "Success", message: "Add \(self.nameProfile.text!) Success!", preferredStyle: .alert)
        alert.addAction(.init(title: "Done", style: .cancel, handler: { _ in
            self.showProfile(false)
        }))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func showProfile(_ flag: Bool) {
        
        asFriendOrYour.text = ""
        imageProfile.isHidden = !flag
        nameProfile.isHidden = !flag
        submit.isHidden = !flag
        submit.isUserInteractionEnabled = flag
    }
    
    func submitShow(_ flag: Bool) {
        submit.isHidden = !flag
        submit.isUserInteractionEnabled = flag
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
