//
//  UserTransactionDataTableViewCell.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 30/01/22.
//

import UIKit

class UserTransactionDataTableViewCell: UITableViewCell {
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var bankAccountNumberLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func setupContent(content: TransactionHistoryResponseDetail) {
        if let sender = content.sender {
            balanceLabel.textColor = UIColor.green
            usernameLabel.text = sender.accountHolder
            bankAccountNumberLabel.text = sender.accountNo
            balanceLabel.text = "\(content.amount)"
        }
        else if let recipient = content.receipient {
            balanceLabel.textColor = UIColor.gray
            usernameLabel.text = recipient.accountHolder
            bankAccountNumberLabel.text = recipient.accountNo
            balanceLabel.text = "-\(content.amount)"
        }
    }
}
