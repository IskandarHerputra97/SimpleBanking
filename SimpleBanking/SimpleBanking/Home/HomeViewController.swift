//
//  HomeViewController.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 29/01/22.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var headerContainerView: UIView!
    @IBOutlet weak var totalBalanceTitleLabel: UILabel!
    @IBOutlet weak var totalBalanceLabel: UILabel!
    @IBOutlet weak var accountNumberTitleLabel: UILabel!
    @IBOutlet weak var accountNumberLabel: UILabel!
    @IBOutlet weak var accountHolderTitleLabel: UILabel!
    @IBOutlet weak var accountHolderLabel: UILabel!
    @IBOutlet weak var transactionHistoryLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var makeTransferButton: UIButton!
    
    private var currentAccountBalance = 0.0
    private var transactionHistoryResponseDetail: [TransactionHistoryResponseDetail] = []
    private var transactionDates = Set<String>()
    private var datesAndTransactions: [DatesAndTransaction] = []
    
    private lazy var activityView = UIActivityIndicatorView(style: .large)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchAccountData()
    }
    
    //MARK: - Setup
    private func setupView() {
        title = "Simple Banking"
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black, NSAttributedString.Key.font:UIFont.boldSystemFont(ofSize: 16)]
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(logoutButtonDidTapped))
        navigationItem.rightBarButtonItem?.setTitleTextAttributes(textAttributes, for: .normal)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Refresh", style: .plain, target: self, action: #selector(refreshButtonDidTapped))
        navigationItem.leftBarButtonItem?.setTitleTextAttributes(textAttributes, for: .normal)
        headerContainerView.clipsToBounds = true
        headerContainerView.layer.cornerRadius = 20
        headerContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        makeTransferButton.layer.cornerRadius = 20
        tableView.register(UINib(nibName: "TransactionHistoryTableViewCell", bundle: nil), forCellReuseIdentifier: "TransactionHistoryTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
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
    
    func fetchAccountData() {
        showActivityIndicator()
        guard let url = URL(string: "https://green-thumb-64168.uc.r.appspot.com/balance") else {
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
                    let response = try JSONDecoder().decode(BalanceResponse.self, from: data)
                    if let responseError = response.error {
                        if responseError.name == "TokenExpiredError" {
                            UserHelper.removeLoginState()
                            DispatchQueue.main.async {
                                NotificationCenter.default.post(name: .loginStateChange, object: nil)
                            }
                        }
                    }
                    guard let balance = response.balance, let accountNo = response.accountNo else {
                        return
                    }
                    DispatchQueue.main.async {
                        let currencyFormatter = NumberFormatter()
                        currencyFormatter.usesGroupingSeparator = true
                        currencyFormatter.numberStyle = .decimal
                        let priceString = currencyFormatter.string(from: NSNumber(value: balance))!
                        self.totalBalanceLabel.text = "SGD \(priceString)"
                        self.currentAccountBalance = balance
                        self.accountNumberLabel.text = accountNo
                        self.accountHolderLabel.text = UserHelper.userNameData
                    }
                    self.fetchTransactionHistory()
                } catch let error {
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                    }
                    print("error.localizedDescription: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
    
    func fetchTransactionHistory() {
        self.transactionHistoryResponseDetail.removeAll()
        self.datesAndTransactions.removeAll()
        guard let url = URL(string: "https://green-thumb-64168.uc.r.appspot.com/transactions") else {
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
                    let response = try JSONDecoder().decode(TransactionHistoryResponse.self, from: data)
                    DispatchQueue.main.async {
                        self.transactionHistoryLabel.text = "Your transaction history"
                    }
                    
                    for item in response.data {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
                        let convertedString = dateFormatter.date(from: item.transactionDate)
                        dateFormatter.dateFormat = "d MMM yyyy"
                        let stringFromDate = dateFormatter.string(from: convertedString ?? Date())
                        
                        self.transactionHistoryResponseDetail.append(TransactionHistoryResponseDetail(transactionId: item.transactionId,
                                                                                                      amount: item.amount,
                                                                                                      transactionDate: stringFromDate,
                                                                                                      description: item.description,
                                                                                                      transactionType: item.transactionType,
                                                                                                      receipient: item.receipient,
                                                                                                      sender: item.sender))
                    }
                
                    for item in self.transactionHistoryResponseDetail {
                        self.transactionDates.insert(item.transactionDate)
                    }
                    
                    let uniqueDates = Array(self.transactionDates)
                    var convertedArray: [Date] = []
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "d MMM yyyy"
                    for dateData in uniqueDates {
                        let date = dateFormatter.date(from: dateData)
                        if let date = date {
                            convertedArray.append(date)
                        }
                    }
                    
                    let finalDates = convertedArray.sorted(by: {$0.compare($1) == .orderedDescending})
                    
                    var newDatesString: [String] = []
                    
                    for convertedDateData in finalDates {
                        let date = dateFormatter.string(from: convertedDateData)
                        newDatesString.append(date)
                    }
                    
                    for item in newDatesString {
                        var tempTransactionData: [TransactionHistoryResponseDetail] = []
                        for viewModel in self.transactionHistoryResponseDetail {
                            if viewModel.transactionDate == item {
                                tempTransactionData.append(viewModel)
                            }
                        }
                        let dateAndTransaction = DatesAndTransaction(date: item, transactions: tempTransactionData)
                        self.datesAndTransactions.append(dateAndTransaction)
                    }
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.hideActivityIndicator()
                    }
                } catch let error {
                    print("error: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        self.hideActivityIndicator()
                        self.tableView.isHidden = true
                        self.transactionHistoryLabel.text = "Your transaction history is empty"
                    }
                }
            }
        }.resume()
    }
    
    //MARK: - Button Action
    @objc private func logoutButtonDidTapped() {
        UserHelper.removeLoginState()
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .loginStateChange, object: nil)
        }
    }
    
    @IBAction func makeTransferButtonDidTapped(_ sender: UIButton) {
        let transferVC = TransferViewController(currentAccountBalance: currentAccountBalance)
        navigationController?.pushViewController(transferVC, animated: true)
    }
    
    @objc private func refreshButtonDidTapped() {
        fetchAccountData()
    }
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datesAndTransactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < datesAndTransactions.count, let cell: TransactionHistoryTableViewCell = tableView.dequeueReusableCell(withIdentifier: "TransactionHistoryTableViewCell") as? TransactionHistoryTableViewCell else {
            return UITableViewCell()
        }
        let viewModel = datesAndTransactions[indexPath.row]
        cell.setupContent(content: viewModel)
        return cell
    }
}
