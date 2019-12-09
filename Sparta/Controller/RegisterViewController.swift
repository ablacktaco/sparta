//
//  RegisterViewController.swift
//  Sparta
//
//  Created by 陳姿穎 on 2019/11/25.
//  Copyright © 2019 陳姿穎. All rights reserved.
//

import UIKit

class RegisterViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        name.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        account.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        password.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        bankAccount.addTarget(self, action: #selector(checkContent), for: .editingChanged)
        
        password.isSecureTextEntry = true
        bankAccount.keyboardType = .emailAddress
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @IBOutlet var name: UITextField!
    @IBOutlet var account: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var bankAccount: UITextField!
    @IBOutlet var registerBankButton: UIButton! {
        didSet {
            registerBankButton.contentHorizontalAlignment = .trailing
        }
    }
    @IBOutlet var role: UISegmentedControl!
    @IBOutlet var confirmButton: UIButton! {
        didSet { setViewBorder(view: confirmButton, configSetting: .mainButton) }
    }
    
    @IBAction func tapToResign(_ sender: UIButton) {
        if role.selectedSegmentIndex == 0 {
            postRegisterData()
        } else {
            if let ruleVC = storyboard?.instantiateViewController(withIdentifier: "mercenaryRuleVC") as? MercenaryRuleViewController {
                ruleVC.registerVC = self
                present(ruleVC, animated: true, completion: nil)
            }
        }
    }
    @IBAction func cancelRegister(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController {
    
    @objc func checkContent() {
        if getEffectiveText(name) == "" || getEffectiveText(account) == "" || getEffectiveText(password) == "" || getEffectiveText(bankAccount) == "" {
            confirmButton.alpha = 0.2
            confirmButton.isEnabled = false
        } else {
            confirmButton.alpha = 1
            confirmButton.isEnabled = true
        }
    }
    
    func postRegisterData() {
        let registerData = Register(name: getEffectiveText(name), account: getEffectiveText(account), password: getEffectiveText(password), role: role.selectedSegmentIndex, bank_account: getEffectiveText(bankAccount))
        guard let uploadData = try? JSONEncoder().encode(registerData) else { return }

        let url = URL(string: "http://34.80.65.255/api/register")!
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
                if response.statusCode == 416 {
                    let alertController = UIAlertController(title: "", message: "The name or account has already been taken.", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion: nil)
                    return
                }
                if let mimeType = response.mimeType,
                    mimeType == "application/json",
                    let data = data,
                    let dataString = String(data: data, encoding: .utf8) {
                    print("got data: \(dataString)")
                    let result = self.decodeResignData(data)
                    DispatchQueue.main.async {
                        let alertController = UIAlertController(title: result, message: nil, preferredStyle: .alert)
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
    
    func decodeResignData(_ data: Data) -> String {
        if let decodedData = try? JSONDecoder().decode(DecodeRegister.self, from: data) {
            return decodedData.result
        }
        return "Register Failed"
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

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
}
