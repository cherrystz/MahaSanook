//
//  HomeViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 4/12/2563 BE.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return game.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "data")! as! GameHistoryTableViewCell
        cell.date.text = date[indexPath.row]
        cell.game.text = result[indexPath.row]
        
        if result[indexPath.row].contains("Versus AI") {
            cell.img.image = UIImage(systemName: "desktopcomputer")
        }
        else {
            cell.img.image = UIImage(systemName: "person.fill")
        }
        return cell
    }
    
    
    @IBOutlet weak var singleButton: UIButton!
    @IBOutlet weak var multiButton: UIButton!
    @IBOutlet weak var chessBackgroundImage: UIImageView!
    @IBOutlet weak var viewBackground: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var mode = true
    var game: [String] = []
    var date: [String] = []
    var result: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 65
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.isHidden = true
        playButton.isHidden = true
        playButton.isUserInteractionEnabled = false
        activityRunning(false)
        
        singleButton.isDefaultButton()
        multiButton.isDefaultButton()
        chessBackgroundImage.layer.cornerRadius = 20
        viewBackground.layer.cornerRadius = 20
        chessBackgroundImage.layer.borderColor = .init(red: 0, green: 0, blue: 0, alpha: 0.3)
        chessBackgroundImage.layer.borderWidth = 0.5

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        tableView.isHidden = true
        loadTable()
    }
    
    
    @IBAction func segment(_ sender: Any) {
        let an = sender as! UISegmentedControl
        if an.selectedSegmentIndex == 0 {
            mode = true
            loadTable()
        }
        else {
            mode = false
            showTableView(false)
            
        }
    }
    @IBAction func didTapPlay() {
        if mode {
            let game = storyboard?.instantiateViewController(identifier: "Chess") as! ChessViewController
            self.navigationController?.pushViewController(game, animated: true)
        }
        else {
            didTapMultiplayer()
        }
    }
    
    @IBAction func didTapMultiplayer() {
        let alert = UIAlertController(title: "Closed", message: "Multiplayer Coming Soon!", preferredStyle: .alert)
        alert.addAction(.init(title: "Done", style: .cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func showTableView(_ flag: Bool) {
        tableView.isHidden = !flag
        playButton.isHidden = flag
        playButton.isUserInteractionEnabled = !flag
    }
    
    func loadTable() {
        activityRunning(true)
        playButton.isHidden = true
        if mode { // for single
            GameHistory.refs.Game.child(Auth.auth().currentUser!.uid).child("single").observeSingleEvent(of: .value, with: {(snapshot) in
                
                guard let snap = snapshot.value as? [String:String] else {
                    // run with error or dont have object
                    
                    self.activityRunning(false)
                    self.showTableView(false)
                    return
                }
                self.game = []
                
                for (date,result) in snap {
                    self.game.append(date+"z"+result)
                }
                
                self.reloadTableView()
                
                
            }) { (error) in
                print(error.localizedDescription)
            }
        }
    }
    
    func reloadTableView() {
        date = []
        result = []
        game = game.sorted(by: { $0 > $1 })
        for i in game {
            let full = i.components(separatedBy: "z")
            
            let dt = full[0].components(separatedBy: "x")
            
            let y = Int(dt[0])!
            let m = Int(dt[1])!
            let d = Int(dt[2])!
            
            let x1 = String(format: "%02d/%02d/%d", d, m, y)
            
            let h = Int(dt[3])!
            let mn = Int(dt[4])!
            let x2 = String(format: "%02d:%02d", h, mn)
            date.append(x1+" "+x2)
            result.append(full[1])
        }
        activityRunning(false)
        showTableView(true)
        tableView.reloadData()
    }
    
    func activityRunning(_ flag: Bool) {
        activityIndicator.isHidden = !flag
        if flag {
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
