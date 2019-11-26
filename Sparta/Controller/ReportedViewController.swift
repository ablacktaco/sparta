//
//  ReportedViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/26.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class ReportedViewController: UIViewController {

    var response : String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBOutlet var completeImage: UIButton!
    @IBOutlet var completeDescription: UITextView!
    @IBOutlet var reportedButton: UIButton!
    
    @IBAction func tapToPickPhoto(_ sender: UIButton) {
        pickPhoto()
    }
    @IBAction func tapToReport(_ sender: UIButton) {
        let basePostURL = ""
        let postFormData = ["descript" : completeDescription.text!]
        let image = completeImage.image(for: .normal)
        let uploadData = image!.jpegData(compressionQuality: 0.1)
        let dataPath = ["file" : uploadData!]
        requestWithFormData(urlString: basePostURL, parameters: postFormData, dataPath: dataPath, completion: { (data) in
            DispatchQueue.main.async {
                self.processData(data: data)
            }
        })
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
    
    func requestWithFormData(urlString: String, parameters: [String: Any], dataPath: [String: Data], completion: @escaping (Data) -> Void){
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        var body = Data()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        for (key, value) in parameters {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString(string: "\(value)\r\n")
        }
        
        for (key, value) in dataPath {
            body.appendString(string: "--\(boundary)\r\n")
            body.appendString(string: "Content-Disposition: form-data; name=\"\(key)\"; filename=\"\(arc4random())\"\r\n") //此處放入file name，以隨機數代替，可自行放入
            body.appendString(string: "Content-Type: image/png\r\n\r\n") //image/png 可改為其他檔案類型 ex:jpeg
            body.append(value)
            body.appendString(string: "\r\n")
        }
        
        body.appendString(string: "--\(boundary)--\r\n")
        request.httpBody = body
        
        fetchedDataByDataTask(from: request, completion: completion)
        
    }
    
    private func fetchedDataByDataTask(from request: URLRequest, completion: @escaping (Data) -> Void){
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            if error != nil{
                print(error as Any)
            }else{
                guard let data = data else{return}
                completion(data)
            }
        }
        task.resume()
    }
    
    func processData(data: Data){
        let fetchedDictionary = data.parseData()
        self.response = fetchedDictionary.description
        self.performSegue(withIdentifier: "showData", sender: self)
    }
}

extension ReportedViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            completeImage.setImage(selectedImage, for: .normal)
            completeImage.setTitle("", for: .normal)
            completeImage.contentMode = .scaleAspectFill
            completeImage.clipsToBounds = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}

extension Data {
    
    func parseData() -> NSDictionary{
        
        let dataDict = try? (JSONSerialization.jsonObject(with: self, options: .mutableContainers) as! NSDictionary)
        
        return dataDict!
    }
    
    mutating func appendString(string: String) {
        let data = string.data(using: String.Encoding.utf8, allowLossyConversion: true)
        append(data!)
    }
    
}
