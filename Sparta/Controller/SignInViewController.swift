//
//  SignInViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        account.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        password.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        
        password.isSecureTextEntry = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        account.text = ""
        password.text = ""
    }
    
    @IBOutlet var account: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var signInButton: UIButton! {
        didSet { setViewBorder(view: signInButton, configSetting: .mainButton) }
    }
    
    @IBAction func tapToSignIn(_ sender: UIButton) {
        postSignInData()
    }
    @IBAction func cancelSignIn(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension SignInViewController {
    
    @objc func checkContent() {
        if getEffectiveText(account) == "" || getEffectiveText(password) == "" {
            signInButton.alpha = 0.2
            signInButton.isEnabled = false
        } else {
            signInButton.alpha = 1
            signInButton.isEnabled = true
        }
    }
    
    func postSignInData() {
        let signInData = SignIn(account: getEffectiveText(account), password: getEffectiveText(password))
        guard let uploadData = try? JSONEncoder().encode(signInData) else { return }

        let url = URL(string: "http://35.221.252.120/api/login")!
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
                if response.statusCode == 401 {
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Error", message: "The account or password is unavailable.", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alertController, animated: true, completion: nil)
                    }
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print ("got data: \(dataString)")
                    self.decodeResignData(data)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Welcome Back, \(UserData.shared.name!).", message: nil, preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            if let userNavi = self.storyboard?.instantiateViewController(withIdentifier: "userNavi") as? UINavigationController{
                                self.present(userNavi, animated: true, completion: nil)
                            }
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func decodeResignData(_ data: Data) {
        if let decodedData = try? JSONDecoder().decode(DecodeSignIn.self, from: data) {
            UserData.shared.name = decodedData.user.name
            UserData.shared.role = decodedData.user.role
            UserData.shared.token = decodedData.user.remember_token
        }
    }
    
    func getEffectiveText(_ textField: UITextField) -> String {
        return textField.text!.trimmingCharacters(in: .whitespaces)
    }
}

extension SignInViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
