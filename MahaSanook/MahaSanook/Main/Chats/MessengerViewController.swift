//
//  MessengerViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 5/12/2563 BE.
//

import UIKit
import JSQMessagesViewController
import Firebase

class MessengerViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var requestButton: UIButton!
    
    var friend: [String] = []
    var request: [String] = []
    var nameFriend = [String]()
    var imgFriend = [String]()
    var uidFriend = [String]()
    var usernameSelf = String()
    let ref = Database.database().reference()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.rowHeight = 70
        
        // Do any additional setup after loading the view.
        
        
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        indicatorRunning(true)
        
        //load usernameself
        ref.child("username").observeSingleEvent(of: .value, with: { (snapshot) in

            if snapshot.hasChild(Auth.auth().currentUser!.uid){
                let f = snapshot.childSnapshot(forPath: Auth.auth().currentUser!.uid).value as! [String:String]
                self.usernameSelf = f["username"]!
                self.loadList()
            }
        })
    }
    
    // MARK:- Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friend.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "data") as! FriendTableViewCell
        
        //image
        if imgFriend[indexPath.row] == "" {
            cell.photo.image = UIImage(systemName: "person.circle")
        }
        else {
            do {
                let url = URL(string: imgFriend[indexPath.row])
                let data = try Data(contentsOf: url!) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                cell.photo.image = UIImage(data: data)
            }
            catch {
                print(error.localizedDescription)
            }
        }
        
        //name
        cell.name.text = nameFriend[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chat = ChatViewController()
        chat.hidesBottomBarWhenPushed = true
        chat.receiver_id = uidFriend[indexPath.row]
        chat.name = nameFriend[indexPath.row]
        
        chat.navigationController?.navigationBar.tintColor = UIColor(named: "Text App Color")
        chat.navigationController?.navigationBar.backItem?.titleView?.tintColor = UIColor(named: "Text App Color")
        self.navigationController?.pushViewController(chat, animated: true)
    }
    
    // MARK:- Actions
    
    @IBAction func didTapRequest() {
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
                let page = self.storyboard?.instantiateViewController(identifier: "request") as! RequestViewController
                self.navigationController?.pushViewController(page, animated: true)
            }
        })
    }
    
    @IBAction func didTapAddFriend() {
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
                let page = self.storyboard?.instantiateViewController(identifier: "add") as! AddFriendViewController
                self.navigationController?.pushViewController(page, animated: true)
            }
        })
        
    }
    
    // MARK:- Functions
    
    func loadList() {
        // load friends
        ref.child("friends/\(usernameSelf)/friends").observeSingleEvent(of: .value, with: { (snapshot) in
            self.friend = Array((snapshot.value as! [String])[1...])
            self.loadFriend()
        })
        
        ref.child("friends/\(usernameSelf)/request").observeSingleEvent(of: .value, with: { (snapshot) in
            let snap = snapshot.value as! [String]
            if snap.count > 1 {
                self.request = Array((snapshot.value as! [String])[1...])
            }
            else {
                self.request = []
            }
            self.loadFriend()
        })
    }
    
    func loadFriend() {
        nameFriend = []
        imgFriend = []
        uidFriend = []
        
        ref.child("user").observeSingleEvent(of: .value, with: { (snapshot) in
            let snap = snapshot.value as! [String:[String:String]]
            
            for (k,v) in snap {
                if self.friend.contains(k) {
                    for (a,b) in v {
                        if a == "display_name" {
                            self.nameFriend.append(b)
                        }
                        if a == "profile_url" {
                            self.imgFriend.append(b)
                        }
                        if a == "uid" {
                            self.uidFriend.append(b)
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
            self.indicatorRunning(false)
        })
        
        if !request.isEmpty {
            self.requestButton.setTitle("Request (\(request.count))", for: .normal)
        }
        else {
            self.requestButton.setTitle("Request", for: .normal)
        }
        
    }
    
    func indicatorRunning(_ flag: Bool) {
        activityIndicator.isHidden = !flag
        if flag {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        self.tableView.isUserInteractionEnabled = !flag
        self.requestButton.isUserInteractionEnabled = !flag
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
