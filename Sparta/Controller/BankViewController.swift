//
//  BankViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/12/3.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class BankViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        name.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        email.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        password.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        
        password.isSecureTextEntry = true
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        navigationItem.title = "Create Bank Acc."
        let backButton = UIBarButtonItem(title: "Back", style: .plain, target: self, action: nil)
        navigationItem.backBarButtonItem = backButton
    }

    @IBOutlet var name: UITextField!
    @IBOutlet var email: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var confirmButton: UIButton! {
        didSet { setViewBorder(view: confirmButton, configSetting: .mainButton) }
    }

    @IBAction func tapToResignBank(_ sender: UIButton) {
        postBankData()
    }
    
}

extension BankViewController {
    
    @objc func checkContent() {
        if getEffectiveText(name) == "" || getEffectiveText(email) == "" || getEffectiveText(password).count < 6 {
            confirmButton.alpha = 0.2
            confirmButton.isEnabled = false
        } else {
            confirmButton.alpha = 1
            confirmButton.isEnabled = true
        }
    }
    
    func postBankData() {
        let registerData = Bank(name: getEffectiveText(name), account: getEffectiveText(email), password: getEffectiveText(password))
        guard let uploadData = try? JSONEncoder().encode(registerData) else { return }

        let url = URL(string: "https://19a201ce.ngrok.io/api/user/register")!
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
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print("got data: \(dataString)")
                    let key = self.decodeBankData(data)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: "Success", message: "Your bank's key is \(key)", preferredStyle: .alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (_) in
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alertController, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }
    
    func decodeBankData(_ data: Data) -> String {
        if let decodedData = try? JSONDecoder().decode(DecodeBank.self, from: data) {
            return decodedData.key
        }
        return ""
    }
    
    func getEffectiveText(_ textField: UITextField) -> String {
        return textField.text!.trimmingCharacters(in: .whitespaces)
    }
    
    @objc func keyboardShow(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let intersection = keyboardSize.intersection(self.view.frame)
        self.view.frame.origin.y -= intersection.height - 110
    }
    
    @objc func keyboardHide(_ notification: Notification) {
        self.view.frame.origin.y = 0
    }
    
}

extension BankViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
