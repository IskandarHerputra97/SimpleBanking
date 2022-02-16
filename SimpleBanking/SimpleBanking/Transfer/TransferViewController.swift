//
//  TransferViewController.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 29/01/22.
//

import UIKit

class TransferViewController: UIViewController {
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var payeeTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var systemErrorMessageLabel: UILabel!
    @IBOutlet weak var transferNowButton: UIButton!
    @IBOutlet var payeePickerView: UIPickerView!
    
    private var payeesData: [PayeesResponseDetail] = []
    private var currentAccountBalance = 0.0
    private var transferAmount = 0.0
    private var receipientAccountNo = ""
    
    private lazy var activityView = UIActivityIndicatorView(style: .large)
    
    //MARK: - Lifecycle
    required init(currentAccountBalance: Double) {
        self.currentAccountBalance = currentAccountBalance
        super.init(nibName: "TransferViewController", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        fetchPayees()
    }
    
    //MARK: - Setup
    private func setupView() {
        setupToolbar()
        title = "Simple Banking"
        
        payeeTextField.rightViewMode = UITextField.ViewMode.always
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        let image = UIImage(named: "ic-arrow-down")
        imageView.image = image
        payeeTextField.rightView = imageView
        descriptionTextView.layer.borderWidth = 1
        descriptionTextView.text = "Description"
        descriptionTextView.textColor = .lightGray
        descriptionTextView.selectedTextRange = descriptionTextView.textRange(from: descriptionTextView.beginningOfDocument, to: descriptionTextView.beginningOfDocument)
        transferNowButton.layer.cornerRadius = 20
        payeeTextField.inputView = payeePickerView
        payeePickerView.delegate = self
        payeePickerView.dataSource = self
        descriptionTextView.delegate = self
        systemErrorMessageLabel.isHidden = true
        systemErrorMessageLabel.layer.borderColor = UIColor.red.cgColor
        systemErrorMessageLabel.layer.cornerRadius = 10.0
        systemErrorMessageLabel.layer.borderWidth = 1.0
    }
    
    private func setupToolbar() {
        let bar = UIToolbar()
        let done = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneButtonDidTapped))
        bar.items = [done]
        bar.sizeToFit()
        payeeTextField.inputAccessoryView = bar
        amountTextField.inputAccessoryView = bar
        descriptionTextView.inputAccessoryView = bar
    }
    
    //MARK: - Private
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
    
    func fetchPayees() {
        showActivityIndicator()
        guard let url = URL(string: "https://green-thumb-64168.uc.r.appspot.com/payees") else {
            self.hideActivityIndicator()
            print("Error: cannot create URL")
            return
        }
        
        //Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(UserHelper.userLoginTokenData, forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                do {
                    let response = try JSONDecoder().decode(PayeesResponse.self, from: data)
                    if let responseError = response.error {
                        if responseError.name == "TokenExpiredError" {
                            UserHelper.removeLoginState()
                            DispatchQueue.main.async {
                                self.hideActivityIndicator()
                                NotificationCenter.default.post(name: .loginStateChange, object: nil)
                            }
                        }
                    }
                    guard let responseData = response.data else {
                        return
                    }
                    self.payeesData.append(PayeesResponseDetail(id: "", name: "Choose Payee:", accountNo: ""))
                    self.payeesData.append(contentsOf: responseData)
                    
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                    }
                } catch let error {
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                    }
                    print("error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    private func validate() -> Bool {
        if payeeTextField.text?.isEmpty ?? true || payeeTextField.text?.count == 0 || payeeTextField.text == "" {
            systemErrorMessageLabel.text = "Please choose a payee!"
            systemErrorMessageLabel.isHidden = false
            return false
        }
        else if amountTextField.text?.isEmpty ?? true || amountTextField.text?.count == 0 || amountTextField.text == "" {
            systemErrorMessageLabel.text = "Please input transfer amount!"
            systemErrorMessageLabel.isHidden = false
            return false
        }
        else if amountTextField.text == "0" {
            systemErrorMessageLabel.text = "Transfer amount must be more than 0!"
            systemErrorMessageLabel.isHidden = false
            return false
        }
        else if let transferAmount = Double(amountTextField.text!) {
            if transferAmount > currentAccountBalance {
                systemErrorMessageLabel.text = "Not enough account balance!"
                systemErrorMessageLabel.isHidden = false
                return false
            }
            else if descriptionTextView.text?.isEmpty ?? true || descriptionTextView.text?.count == 0 || descriptionTextView.text == "" || descriptionTextView.text == "Description" {
                systemErrorMessageLabel.text = "Please input transfer description!"
                systemErrorMessageLabel.isHidden = false
                return false
            }
            self.transferAmount = transferAmount
            systemErrorMessageLabel.text = ""
            systemErrorMessageLabel.isHidden = true
            return true
        }
        return false
    }
    
    func transfer(receipientAccountNo: String, amount: Double, description: String) {
        showActivityIndicator()
        guard let url = URL(string: "https://green-thumb-64168.uc.r.appspot.com/transfer") else {
            print("Error: cannot create URL")
            return
        }
        
        //Add data to the model
        let transferRequest = TransferRequest(receipientAccountNo: receipientAccountNo, amount: amount, description: description)
        
        //Convert model to JSON data
        guard let jsonData = try? JSONEncoder().encode(transferRequest) else {
            print("Error: Trying to convert model to JSON data")
            return
        }
        //Create the url request
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(UserHelper.userLoginTokenData, forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                print("Error: error calling POST")
                print(error!)
                return
            }
            guard let data = data else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                print("Error: Did not receive data")
                return
            }
            guard let response = response as? HTTPURLResponse, (200 ..< 299) ~= response.statusCode else {
                DispatchQueue.main.async {
                    self.hideActivityIndicator()
                }
                print("Error: HTTP request failed")
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
                guard let prettyPrintedJson = String(data: prettyJsonData, encoding: .utf8) else {
                    print("Error: Couldn't print JSON in String")
                    return
                }
                print("prettyPrintedJson: \(prettyPrintedJson)")
                
                guard let success: String = jsonObject["status"] as? String else {
                    return
                }
                if success == "success" {
                    print("Transfer success")
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                        self.navigationController?.popViewController(animated: true)
                    }
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
    @IBAction func transferNowButtonDidTapped(_ sender: UIButton) {
        if validate() {
            transfer(receipientAccountNo: receipientAccountNo, amount: transferAmount, description: descriptionTextView.text!)
        }
    }
    
    @objc private func doneButtonDidTapped() {
        payeeTextField.resignFirstResponder()
        amountTextField.resignFirstResponder()
        descriptionTextView.resignFirstResponder()
    }
}

extension TransferViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        payeesData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return payeesData[row].name
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        var selectedRow = row
        if selectedRow == 0 {
            selectedRow = 1
            pickerView.selectRow(selectedRow, inComponent: component, animated: false)
            payeeTextField.text = payeesData[selectedRow].name
            receipientAccountNo = payeesData[selectedRow].accountNo
        }
        else {
            payeeTextField.text = payeesData[row].name
            receipientAccountNo = payeesData[row].accountNo
        }
    }
}

extension TransferViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)
        if updatedText.isEmpty {
            
            textView.text = "Description"
            textView.textColor = UIColor.lightGray
            
            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }
        else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }
        else {
            return true
        }
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
}
