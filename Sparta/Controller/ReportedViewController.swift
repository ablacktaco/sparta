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
    var response : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        let basePostURL = "http://35.221.252.120/api/reward/\(id!)/report"
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
        
        photoSourceRequestController.addAction(cameraAction)
        photoSourceRequestController.addAction(photoLibraryAction)
        
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
    
}

extension ReportedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            completeImage.image = selectedImage
            pickPhotoButton.setTitle("", for: .normal)
            completeImage.contentMode = .scaleAspectFill
            completeImage.clipsToBounds = true
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

