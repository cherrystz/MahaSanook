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
    
    @IBOutlet weak var imageProfile: UIImageView!
    @IBOutlet weak var imageProfileView: UIButton!
    @IBOutlet weak var displayName: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var updateButton: UIButton!
    
    var imagePicker = UIImagePickerController()
    let user = Auth.auth().currentUser
    var urlProfilePic: URL? = nil
    
    var userChild: String = ""
    
    let storage = Storage.storage()
    let storageRef = Storage.storage().reference()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let ref = Database.database().reference()
        
        //search username
        ref.child("username").observeSingleEvent(of: .value, with: { (snapshot) in
            let f = snapshot.childSnapshot(forPath: self.user!.uid).value as! [String:String]
            self.userChild = (f["username"])!
        })
        
        self.imagePicker.allowsEditing = true
        
        let url = user?.photoURL
        if url != nil {
            do {
                let imageData = try Data(contentsOf: url!)
                imageProfile.image = UIImage.init(data: imageData)?.withRoundedCorners()
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
    
    @IBAction func dismissTap() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func didTapUpdate() {
        
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        errorLabel.text = ""
        activityIndicatorRunning(true)
        if displayName.text != user?.displayName || urlProfilePic != nil {
            changeRequest?.displayName = displayName.text
            if urlProfilePic != nil {
                changeRequest?.photoURL = urlProfilePic
            }
            changeRequest?.commitChanges { (error) in
                if error != nil {
                    self.errorLabel.text = "Error: \((error?.localizedDescription)!)"
                    self.activityIndicatorRunning(false)
                }
                else {
                    do {
                        
                        let ref = Database.database().reference()
                        
                        
                        //Update username
                            ref.child("username").child(self.user!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                              
                                var snap = snapshot.value as! [String:String]
                                snap["display_name"] = self.displayName!.text
                                let childUpdates = ["/username/\(self.user!.uid)" : snap]
                                ref.updateChildValues(childUpdates)

                              }) { (error) in
                                print(error.localizedDescription)
                            }
                        // Update user
                        ref.child("user").child(self.userChild).observeSingleEvent(of: .value, with: { (snapshot) in

                            var snap = snapshot.value as! [String:String]
                            snap["display_name"] = self.displayName!.text
                            if self.urlProfilePic != nil {
                                let url = self.urlProfilePic != nil ? self.urlProfilePic?.relativeString : ""
                                snap["profile_url"] = url
                            }
                            let childUpdates = ["/user/\(self.userChild)" : snap]
                            ref.updateChildValues(childUpdates)

                          }) { (error) in
                            print(error.localizedDescription)
                        }
                        
                        
                        
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

        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            print("Button capture")

            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = true

            self.present(imagePicker, animated: true, completion: nil)
        }
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



extension UpdateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        guard let im: UIImage = info[.editedImage] as? UIImage else { return }
        guard let d: Data = im.jpegData(compressionQuality: 0.5) else { return }

        let md = StorageMetadata()
        md.contentType = "image/png"

        let ref = storageRef.child("profile_img/\(user!.uid).jpg")

        ref.putData(d, metadata: md) { (metadata, error) in
            if error == nil {
                ref.downloadURL(completion: { (url, error) in
                    let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                    changeRequest?.photoURL = url
                    changeRequest?.commitChanges { (error) in
                        if error != nil {
                            self.errorLabel.text = "Error: \((error?.localizedDescription)!)"
                        }
                        else {
                            self.urlProfilePic = url
                        }
                    }
                    
                })
            }
            else {
                print("error \(String(describing: error))")
            }
        }


        self.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            imageProfile.image = image.withRoundedCorners()
        }

    }
    

//    func imagePickerController(_ picker: UIImagePickerController,
//    didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//     guard let im: UIImage = info[.editedImage] as? UIImage else { return }
//     guard let d: Data = im.jpegData(compressionQuality: 0.5) else { return }
//
//     let md = StorageMetadata()
//     md.contentType = "image/png"
//
//        let ref = Storage.storage().reference().child("profile_img/\(user!.uid).jpg")
//
//     ref.putData(d, metadata: md) { (metadata, error) in
//         if error == nil {
//             ref.downloadURL(completion: { (url, error) in
//                 print("Done, url is \(String(describing: url))")
//             })
//         }else{
//             print("error \(String(describing: error))")
//         }
//     }
//
//        self.dismiss(animated: true)
//        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                    imageProfile.image = image.withRoundedCorners()
//                }
//    }
}

func setUsersPhotoURL(withImage: UIImage, andFileName: String) {
    guard let imageData = withImage.jpegData(compressionQuality: 0.5) else { return }
    let storageRef = Storage.storage().reference()
    let thisUserPhotoStorageRef = storageRef.child(Auth.auth().currentUser!.uid).child(andFileName)

    let uploadTask = thisUserPhotoStorageRef.putData(imageData, metadata: nil) { (metadata, error) in
        guard let metadata = metadata else {
            print("error while uploading")
            return
        }

        thisUserPhotoStorageRef.downloadURL { (url, error) in
            print(metadata.size) // Metadata contains file metadata such as size, content-type.
            thisUserPhotoStorageRef.downloadURL { (url, error) in
                guard let downloadURL = url else {
                    print("an error occured after uploading and then getting the URL")
                    return
                }

                let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
                changeRequest?.photoURL = downloadURL
                changeRequest?.commitChanges { (error) in
                    //handle error
                }
            }
        }
    }
}
