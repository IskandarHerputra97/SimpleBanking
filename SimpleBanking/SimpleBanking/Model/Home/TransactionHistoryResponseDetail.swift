//
//  TransactionHistoryResponseDetail.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 11/02/22.
//

import Foundation

struct TransactionHistoryResponseDetail: Codable {
    let transactionId: String
    let amount: Double
    let transactionDate: String
    let description: String?
    let transactionType: String
    let receipient: Receipient?
    let sender: Sender?
}
