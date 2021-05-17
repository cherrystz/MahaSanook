//
//  RequestViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 5/12/2563 BE.
//

import UIKit
import Firebase

class RequestViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var request = [String]()
    let ref = Database.database().reference()
    var nameFriend = [String]()
    var imgFriend = [String]()
    var usernameSelf = String()
    
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
    
    // MARK: - Table View
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return request.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "data") as! RequestTableViewCell
        
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
        
        cell.addRequest.tag = indexPath.row
        cell.addRequest.addTarget(self, action: #selector(addReq(sender:)), for: .touchUpInside)
        
        cell.removeRequest.tag = indexPath.row
        cell.removeRequest.addTarget(self, action: #selector(removeReq(sender:)), for: .touchUpInside)

        
        //name
        cell.name.text = nameFriend[indexPath.row]
        
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
    
    // MARK:- Actions
    
    
    
    // MARK:- OBJ-C FUNCTION
    @objc func addReq(sender: UIButton){
        let index = sender.tag
        self.indicatorRunning(true)
        
        ref.child("/friends/\(self.usernameSelf)/request").observeSingleEvent(of: .value, with: { (snapshot) in
          
            var snap = snapshot.value as! [String]
            snap.remove(at: snap.firstIndex(of: self.request[index])!)
            let childUpdates = ["/friends/\(self.usernameSelf)/request" : snap]
            self.ref.updateChildValues(childUpdates)
            
            
            self.indicatorRunning(true)
          }) { (error) in
            print(error.localizedDescription)
        }
        
        ref.child("/friends/\(self.usernameSelf)/friends").observeSingleEvent(of: .value, with: { (snapshot) in
          
            var snap = snapshot.value as! [String]
            snap.append(self.request[index])
            let childUpdates = ["/friends/\(self.usernameSelf)/friends" : snap]
            self.ref.updateChildValues(childUpdates)
            self.loadList()
            
          }) { (error) in
            print(error.localizedDescription)
            
        }
        
        
        
    }
    @objc func removeReq(sender: UIButton){
        let index = sender.tag
        indicatorRunning(true)
        
        ref.child("/friends/\(self.usernameSelf)/request").observeSingleEvent(of: .value, with: { (snapshot) in
          
            var snap = snapshot.value as! [String]
            snap.remove(at: snap.firstIndex(of: self.request[index])!)
            let childUpdates = ["/friends/\(self.usernameSelf)/request" : snap]
            self.ref.updateChildValues(childUpdates)
            self.loadList()

          }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    // MARK:- Functions
    
    func indicatorRunning(_ flag: Bool) {
        activityIndicator.isHidden = !flag
        if flag {
            activityIndicator.startAnimating()
        }
        else {
            activityIndicator.stopAnimating()
        }
        self.tableView.isUserInteractionEnabled = !flag
    }
    
    func loadList() {
        
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
        
        ref.child("user").observeSingleEvent(of: .value, with: { (snapshot) in
            let snap = snapshot.value as! [String:[String:String]]
            
            for (k,v) in snap {
                if self.request.contains(k) {
                    for (a,b) in v {
                        if a == "display_name" {
                            self.nameFriend.append(b)
                        }
                        if a == "profile_url" {
                            self.imgFriend.append(b)
                        }
                    }
                }
            }
            
            self.tableView.reloadData()
            self.indicatorRunning(false)
        })
        
    }

}
