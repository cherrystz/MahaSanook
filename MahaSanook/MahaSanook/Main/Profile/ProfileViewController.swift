//
//  ProfileViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 4/12/2563 BE.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var profileNameLabel: UILabel!
    @IBOutlet weak var username: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    let arrayCell: [String] = ["Profile","History","Settings","FAQ","Contact Us"]
    let user = Auth.auth().currentUser

    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let url = user?.photoURL
        if url != nil {
            do {
                let imageData = try Data(contentsOf: url!)
                profileImageView.image = UIImage.init(data: imageData)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        profileImageView.cornerRadius()
        
        if user?.displayName != nil {
            profileNameLabel.text = "Hi, \((user?.displayName)!)!"
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60.9
        
        // Do any additional setup after loading the view.
        
        
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        Auth.auth().currentUser?.reload(completion: nil)
        
        let re = Database.database().reference()
        re.child("username").observeSingleEvent(of: .value, with: { (snapshot) in

            if snapshot.hasChild(self.user!.uid){
                let f = snapshot.childSnapshot(forPath: self.user!.uid).value as! [String:String]
                self.username.setTitle("Username : " + ((f["username"])!), for: .normal)
            }
            else {
                self.username.isUserInteractionEnabled = true
            }
        })
    }
    
    @IBAction func didLogout(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(.init(title: "Logout", style: .destructive, handler: { _ in
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
                self.logOut()
                let loginManager = LoginManager()
                loginManager.logOut()
                
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func didTapUsername() {
        let page = self.storyboard?.instantiateViewController(identifier: "Setup") as! SetupUsernameViewController
        self.present(page, animated: true, completion: nil)
    }

    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayCell.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profile")!
        
        cell.textLabel?.text = "  " + arrayCell[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            
            let user = Auth.auth().currentUser?.uid
            let ref = Database.database().reference()
            
            ref.child("username").observeSingleEvent(of: .value, with: { (snapshot) in
                if !snapshot.hasChild(user!) {
                    let alert = UIAlertController(title: "Warning", message: "Your username doesn't set.\nDo you want to set username?", preferredStyle: .alert)
                    
                    alert.addAction(.init(title: "Setup", style: .default, handler: { _ in
                        let page = self.storyboard?.instantiateViewController(identifier: "Setup") as! SetupUsernameViewController
                        self.present(page, animated: true, completion: nil)
                    }))
                    alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    let update = self.storyboard?.instantiateViewController(identifier: "updateProfile") as! UpdateProfileViewController
                    self.navigationController?.pushViewController(update, animated: true)
                }
            })
            
        default:
            break
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
