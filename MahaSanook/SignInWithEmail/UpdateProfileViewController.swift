//
//  UpdateProfileViewController.swift
//  MahaSanook
//
//  Created by Napassorn V. on 4/12/2563 BE.
//

import UIKit
import Firebase

class UpdateProfileViewController: UIViewController {
    
    @IBOutlet weak var imageProfileView: UIButton!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var updateButton: UIButton!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageProfileView.layer.cornerRadius = imageProfileView.frame.height/2   
        displayName.isDefaultTextField()
        updateButton.isDefaultButton()
        // Do any additional setup after loading the view.
        
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
