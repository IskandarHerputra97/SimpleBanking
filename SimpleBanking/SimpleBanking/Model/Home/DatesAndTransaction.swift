//
//  DatesAndTransaction.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 15/02/22.
//

import Foundation

struct DatesAndTransaction: Codable {
    let date: String
    let transactions: [TransactionHistoryResponseDetail]
}
