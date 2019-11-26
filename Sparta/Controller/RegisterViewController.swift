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
    }
    
    @IBOutlet var name: UITextField!
    @IBOutlet var account: UITextField!
    @IBOutlet var password: UITextField!
    @IBOutlet var role: UISegmentedControl!
    @IBOutlet var confirmButton: UIButton! {
        didSet { setViewBorder(view: confirmButton, configSetting: .mainButton) }
    }
    
    @IBAction func tapToResign(_ sender: UIButton) {
        if role.selectedSegmentIndex == 0 {
            postRegisterData()
        } else {
            if let qualVC = self.storyboard?.instantiateViewController(withIdentifier: "qualVC") as? QualificationViewController {
                qualVC.regiVC = self
                self.present(qualVC, animated: true, completion: nil)
            }
        }
    }
    @IBAction func cancelRegister(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
}

extension RegisterViewController {
    
    @objc func checkContent() {
        if getEffectiveText(name) == "" || getEffectiveText(account) == "" || getEffectiveText(password) == "" {
            confirmButton.alpha = 0.2
            confirmButton.isEnabled = false
        } else {
            confirmButton.alpha = 1
            confirmButton.isEnabled = true
        }
    }
    
    func postRegisterData() {
        let registerData = Register(name: getEffectiveText(name), account: getEffectiveText(account), password: getEffectiveText(password), role: role.selectedSegmentIndex)
        guard let uploadData = try? JSONEncoder().encode(registerData) else { return }

        let url = URL(string: "http://35.221.252.120/api/register")!
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
    
}

extension RegisterViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
