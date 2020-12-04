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
        profileNameLabel.text = "Hi, \((user?.displayName)?.description)!"
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 60.9
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func didLogout(_ sender: Any) {
        
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure?", preferredStyle: .alert)
        alert.addAction(.init(title: "Logout", style: .destructive, handler: { _ in
            let firebaseAuth = Auth.auth()
            do {
              try firebaseAuth.signOut()
                UIApplication.shared.windows.first?.rootViewController = self.storyboard?.instantiateViewController(withIdentifier: "signIn") as! SignInViewController
                
                let loginManager = LoginManager()
                loginManager.logOut()
                
            } catch let signOutError as NSError {
              print ("Error signing out: %@", signOutError)
            }
        }))
        alert.addAction(.init(title: "Cancel", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
