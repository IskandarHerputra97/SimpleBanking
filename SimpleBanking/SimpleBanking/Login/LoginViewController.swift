//
//  LoginViewController.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 29/01/22.
//

import UIKit

class LoginViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var usernameErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
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
        loginButton.layer.cornerRadius = 20
        registerButton.layer.cornerRadius = 20
        registerButton.layer.borderWidth = 1
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
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
            usernameErrorLabel.text = "Please input username!"
            usernameErrorLabel.isHidden = false
            return false
        }
        else if passwordTextField.text == "" {
            usernameErrorLabel.isHidden = true
            passwordErrorLabel.text = "Please input password!"
            passwordErrorLabel.isHidden = false
            return false
        }
        usernameErrorLabel.isHidden = true
        passwordErrorLabel.isHidden = true
        return true
    }
    
    func login() {
        showActivityIndicator()
        username = usernameTextField.text!
        password = passwordTextField.text!
        
        guard let url = URL(string: "https://green-thumb-64168.uc.r.appspot.com/login") else {
            print("Error: cannot create URL")
            return
        }
        
        // Add data to the model
        let loginRequest = LoginRequest(username: username, password: password)
        
        // Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(loginRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        // Create the url request
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
                    self.passwordErrorLabel.text = "invalid login credential"
                    self.passwordErrorLabel.isHidden = false
                }
                return
            }
            
            do {
                guard let jsonObject = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    print("Error: Cannot convert data to JSON object")
                    return
                }
                guard let prettyJsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted) else {
                    print("Error: Cannot convert JSON object to Pretty JSON data")
                    return
                }
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Couldn't print JSON in String")
                    return
                }
                print("prettyPrintedJson: \(prettyPrintedJson)")
                
                guard let userLoginToken: String = jsonObject["token"] as? String else {
                    return
                }
                guard let userName: String = jsonObject["username"] as? String else {
                    return
                }
                guard let accountNo: String = jsonObject["accountNo"] as? String else {
                    return
                }
                UserHelper.saveLoginState(tokenData: userLoginToken, userNameData: userName, userAccountNoData: accountNo)
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                    NotificationCenter.default.post(name: .loginStateChange, object: nil)
                }
            } catch {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                print("Error: Trying to convert JSON data to string")
                return
            }
        }.resume()
    }
    
    //MARK: - Button Action
    @IBAction func loginButtonDidTapped(_ sender: UIButton) {
        if validate() {
            login()
        }
    }
    
    @IBAction func registerButtonDidTapped(_ sender: UIButton) {
        let registerVC = RegisterViewController()
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
    @objc private func doneButtonDidTapped() {
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
    }
}
