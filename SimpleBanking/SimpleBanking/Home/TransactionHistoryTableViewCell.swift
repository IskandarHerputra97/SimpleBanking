//
//  TransactionHistoryTableViewCell.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 30/01/22.
//

import UIKit

class TransactionHistoryTableViewCell: UITableViewCell {
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var userTransactionDataTableView: UITableView!
    
    private var transactions: [TransactionHistoryResponseDetail] = []
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 20
        
        userTransactionDataTableView.delegate = self
        userTransactionDataTableView.dataSource = self
        
        userTransactionDataTableView.register(UINib(nibName: "UserTransactionDataTableViewCell", bundle: nil), forCellReuseIdentifier: "UserTransactionDataTableViewCell")
    }
    
    func setupContent(content: DatesAndTransaction) {
        transactions = content.transactions
        dateLabel.text = content.date
        userTransactionDataTableView.reloadData()
    }
}

extension TransactionHistoryTableViewCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return transactions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.row < transactions.count, let cell: UserTransactionDataTableViewCell = tableView.dequeueReusableCell(withIdentifier: "UserTransactionDataTableViewCell") as? UserTransactionDataTableViewCell else {
            return UITableViewCell()
        }
        cell.selectionStyle = .none
        let transaction = transactions[indexPath.row]
        cell.setupContent(content: transaction)
        return cell
    }
}
