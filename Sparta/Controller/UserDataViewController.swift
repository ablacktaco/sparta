//
//  UserDataViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/6.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class UserDataViewController: UIViewController {

    var belongings = [Belongings]()
    
    var image: String?
    var userName: String?
    var userMoney: String?
    var userRole: String?
    var allCase: Int?
    var acRate: Int?
    
    var keyAlert: UIAlertController?
    var downloadCompletionBlock: ((_ data: Data) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = userName
        
        downloadByDownloadTask(urlString: image, completion: { (data) in
            self.userImage.image = UIImage(data: data)
        })
        
        belongingsTable.tableFooterView = UIView()
        
        getBelongings { (belongings) in
            self.belongings = belongings
            DispatchQueue.main.async {
                self.belongingsTable.reloadData()
            }
        }
        
        if userRole == "Role: Mortal" {
            totalCase.isHidden = true
            rate.isHidden = true
        }
    }

    @IBOutlet var userImage: UIImageView! {
        didSet {
            userImage.layer.cornerRadius = userImage.frame.width / 2
            userImage.clipsToBounds = true
        }
    }
    @IBOutlet var forgetKeyButton: UIButton! {
        didSet { setViewBorder(view: forgetKeyButton, configSetting: .chooseButton) }
    }
    @IBOutlet var name: UILabel! {
        didSet { name.text = userName }
    }
    @IBOutlet var property: UILabel! {
        didSet { property.text = userMoney }
    }
    @IBOutlet var role: UILabel! {
        didSet { role.text = userRole }
    }
    @IBOutlet var totalCase: UILabel! {
        didSet { totalCase.text = "Finished case: \(allCase!)" }
    }
    @IBOutlet var rate: UILabel! {
        didSet {
            if acRate == 0 {
                rate.text = "Achieve rate: 0 %"
            } else {
                rate.text = "Achieve rate: \(acRate! / allCase! * 100) %"
            }
        }
    }
    @IBOutlet var belongingsTable: UITableView!
    
    @IBAction func tapToChangePhoto(_ sender: UIButton) {
        pickPhoto()
    }
    @IBAction func tapToGetKey(_ sender: UIButton) {
        keyAlert = UIAlertController(title: "Forget key", message: nil, preferredStyle: .alert)
        keyAlert!.addTextField { (textField) in
            textField.placeholder = "Enter your bank's account"
            textField.keyboardType = .emailAddress
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        keyAlert!.addTextField { (textField) in
            textField.placeholder = "Enter your bank's password"
            textField.isSecureTextEntry = true
            textField.addTarget(self, action: #selector(self.alertTextFieldDidChange(_:)), for: .editingChanged)
        }
        keyAlert!.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
            self.getBankKey(userID: self.getEffectiveText((self.keyAlert?.textFields![0])!), password: self.getEffectiveText((self.keyAlert?.textFields![1])!))
        }))
        keyAlert?.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        keyAlert?.actions[0].isEnabled = false
        self.present(keyAlert!, animated: true, completion: nil)
    }
    
}

extension UserDataViewController {
    
    func getBelongings(closure: @escaping ([Belongings]) -> Void) {
        
        let url = URL(string: "http://34.80.65.255/api/bought")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("keep-alive", forHTTPHeaderField: "connection")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")
                        
        let task = URLSession.shared.uploadTask(with: request, fromFile: url) { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("status code: \(response.statusCode)")
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    if let belongings = try? JSONDecoder().decode([Belongings].self, from: data) {
                        closure(belongings)
                    }
                }
            }
        }
        task.resume()
    }
    
    func getBankKey(userID: String, password: String) {
        let bankUserData = BankUserData(userID: userID, password: password)
        guard let uploadData = try? JSONEncoder().encode(bankUserData) else { return }

        let url = URL(string: "https://bboa14171205.nctu.me/api/user/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let task = URLSession.shared.uploadTask(with: request, from: uploadData) { (data, response, error) in
            if let error = error {
                print ("error: \(error)")
                return
            }
            if let response = response as? HTTPURLResponse {
                print("status code: \(response.statusCode)")
                if response.statusCode != 200 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "Wrong account or password", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print("got data: \(dataString)")
                    let key = self.decodeBankData(data)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Your bank's key is \(key)", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func decodeBankData(_ data: Data) -> Int {
        if let decodedData = try? JSONDecoder().decode(DecodeBank.self, from: data) {
            return decodedData.key
        }
        return 0
    }
    
    func getEffectiveText(_ textField: UITextField) -> String {
        return textField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    @objc func alertTextFieldDidChange(_ sender: UITextField) {
        keyAlert!.actions[0].isEnabled = getEffectiveText((keyAlert?.textFields![0])!).count > 0 && getEffectiveText((keyAlert?.textFields![1])!).count >= 6
    }
    
    func downloadByDownloadTask(urlString: String?, completion: @escaping (Data) -> Void){
        if let urlString = urlString {
            let url = URL(string: urlString)!
            let request = URLRequest(url: url)
            
            let configiguration = URLSessionConfiguration.default
            configiguration.timeoutIntervalForRequest = .infinity
            
            let urlSession = URLSession(configuration: configiguration, delegate: self, delegateQueue: OperationQueue.main)
            
            let task = urlSession.downloadTask(with: request)
            
            downloadCompletionBlock = completion
            
            task.resume()
        }
    }
    
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
    
    func uploadPhoto() {
        let basePostURL = "http://34.80.65.255/api/avatar/\(UserData.shared.id!)"
        let image = userImage.image
        let uploadData = image!.jpegData(compressionQuality: 0.1)
        let dataPath = ["avatar" : uploadData!]
        requestWithFormData(urlString: basePostURL, dataPath: dataPath)
    }
    
    func requestWithFormData(urlString: String, dataPath: [String: Data]) {
        let url = URL(string: urlString)!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        let boundary = "Boundary+\(arc4random())\(arc4random())"
        var body = Data()
        
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue(UserData.shared.token, forHTTPHeaderField: "remember_token")
        
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

extension UserDataViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return belongings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "belongingsCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! BelongingsTableViewCell
        
        cell.setbelongingsData(belongings, indexPath: indexPath)
        cell.selectionStyle = .none
        
        return cell
    }
    
}

extension UserDataViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let data = try! Data(contentsOf: location)
        if let block = downloadCompletionBlock {
            block(data)
        }
    }
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        print(progress)
    }
    
}

extension UserDataViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            userImage.image = selectedImage
            userImage.contentMode = .scaleAspectFill
            uploadPhoto()
        }
        
        dismiss(animated: true, completion: nil)
    }
    
}
