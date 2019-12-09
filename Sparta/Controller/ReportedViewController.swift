//
//  ReportedViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/26.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ReportedViewController: UIViewController {

    var id: Int?
    var response: String?
    var missionVC: MissionViewController?
    var missionTitle: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        keyboardHide()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.title = "Report mission"
    }
    
    @IBOutlet var titleLabel: UILabel! {
        didSet { titleLabel.text = missionTitle }
    }
    @IBOutlet var pickPhotoButton: UIButton!
    @IBOutlet var completeImage: UIImageView!
    @IBOutlet var completeDescription: UITextView!
    @IBOutlet var reportedButton: UIButton! {
        didSet {
            setViewBorder(view: reportedButton, configSetting: .mainButton)
        }
    }
    
    @IBAction func tapToPickPhoto(_ sender: UIButton) {
        pickPhoto()
    }
    @IBAction func tapToReport(_ sender: UIButton) {
        let basePostURL = "http://34.80.65.255/api/reward/\(id!)/report"
        let postFormData = ["reported_descript" : completeDescription.text!]
        let image = completeImage.image
        let uploadData = image!.jpegData(compressionQuality: 0.1)
        let dataPath = ["img" : uploadData!]
        requestWithFormData(urlString: basePostURL, parameters: postFormData, dataPath: dataPath)
    }
    
}

extension ReportedViewController {
    
    func pickPhoto() {
        let photoSourceRequestController = UIAlertController(title: "", message: "Choose your photo source", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .camera
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo library", style: .default) { (action) in
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.allowsEditing = false
                imagePicker.sourceType = .photoLibrary
                imagePicker.delegate = self
                
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        photoSourceRequestController.addAction(cancelAction)
        
        present(photoSourceRequestController, animated: true, completion: nil)
        
    }
    
    func requestWithFormData(urlString: String, parameters: [String: Any], dataPath: [String: Data]) {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        var body = Data()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")
        
        for (key, value) in parameters {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        for (key, value) in dataPath {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(arc4random())\"\r\n")
            body.appendString(string: "Content-Type: image/jpeg\r\n\r\n")
            body.append(value)
            body.appendString(string: "\r\n")
        }
        
        body.appendString(string: "--\(boundary)--\r\n")
        
        request.httpBody = body
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("status code: \(response.statusCode)")
                if response.statusCode == 416 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "You must need to add a photo.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                } else if response.statusCode == 200 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Success", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.missionVC?.getMissionHistory(closure: { (missionHistory) in
                                self.missionVC?.missionList = missionHistory.history!
                                self.missionVC?.filterList = (self.missionVC?.missionList.filter { ($0.done == 1) })!
                                DispatchQueue.main.async {
                                    self.missionVC?.missionTable.reloadData()
                                }
                            })
                            self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
                if let mimeType = response.mimeType,
                    mimeType == "multipart/form-data",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                }
            }
        }
        task.resume()
        
    }
    
    func keyboardHide() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardDismiss))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func keyboardDismiss() {
        self.view.endEditing(true)
    }
    
    @objc func keyboardShow(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let intersection = keyboardSize.intersection(self.view.frame)
        self.view.frame.origin.y -= intersection.height - 100
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
}

extension ReportedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            completeImage.image = selectedImage
            pickPhotoButton.setTitle("", for: .normal)
            completeImage.contentMode = .scaleAspectFit
            reportedButton.isEnabled = true
            reportedButton.alpha = 1
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension Data {
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
    
}

