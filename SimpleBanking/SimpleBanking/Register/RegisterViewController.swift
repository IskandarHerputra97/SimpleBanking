//
//  RegisterViewController.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 29/01/22.
//

import UIKit

class RegisterViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var confirmPasswordErrorLabel: UILabel!
    @IBOutlet weak var registerButton: UIButton!
    
    private var username = ""
    private var password = ""
    
    private lazy var activityView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }

    //MARK: - Setup
    private func setupView() {
        title = "Simple Banking"
        registerButton.layer.cornerRadius = 20
        confirmPasswordErrorLabel.isHidden = true
        setupToolbar()
    }
    
    //MARK: - Private
    private func setupToolbar() {
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonDidTapped))
        bar.items = [done]
        bar.sizeToFit()
        usernameTextField.inputAccessoryView = bar
        passwordTextField.inputAccessoryView = bar
        confirmPasswordTextField.inputAccessoryView = bar
    }
    
    private func showActivityIndicator() {
        self.view.isUserInteractionEnabled = false
        activityView.center = self.view.center
        self.view.addSubview(activityView)
        activityView.startAnimating()
   }
    
    private func hideActivityIndicator() {
        self.view.isUserInteractionEnabled = true
        activityView.stopAnimating()
    }
    
    private func validate() -> Bool {
        if usernameTextField.text == "" {
            confirmPasswordErrorLabel.text = "Please input username!"
            confirmPasswordErrorLabel.isHidden = false
            return false
        }
        else if passwordTextField.text == "" {
            confirmPasswordErrorLabel.text = "Please input password!"
            confirmPasswordErrorLabel.isHidden = false
            return false
        }
        else if confirmPasswordTextField.text == "" {
            confirmPasswordErrorLabel.text = "Please input confirmed password!"
            confirmPasswordErrorLabel.isHidden = false
            return false
        }
        else if confirmPasswordTextField.text != passwordTextField.text {
            confirmPasswordErrorLabel.text = "Confirmed password and password does not match"
            confirmPasswordErrorLabel.isHidden = false
            return false
        }
        return true
    }
    
    func register() {
        showActivityIndicator()
        username = usernameTextField.text!
        password = passwordTextField.text!
        
        guard let url = URL(string: "https://green-thumb-64168.uc.r.appspot.com/register") else {
            print("Error: cannot create URL")
            return
        }
        
        //Add data to the model
        let registerRequest = RegisterRequest(username: username, password: password)
        
        //Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(registerRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        //Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type") // the request is JSON
        request.setValue("application/json", forHTTPHeaderField: "Accept") // the response expected to be in JSON format
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("Error: error calling POST")
                print(error!)
                return
            }
            guard let data = data else {
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.confirmPasswordErrorLabel.text = "username already exists"
                    self.confirmPasswordErrorLabel.isHidden = false
                }
                return
            }
            
            print("response: \(response)")
            
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJSON = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Couldn't print JSON in String")
                    return
                }
                print("prettyPrintedJSON: \(prettyPrintedJSON)")
              
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            } catch {
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
    
    //MARK: - Button Action
    @IBAction func registerButtonDidTapped(_ sender: UIButton) {
        if validate() {
            register()
        }
    }
    
    @objc private func doneButtonDidTapped() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        confirmPasswordTextField.resignFirstResponder()
    }
}
