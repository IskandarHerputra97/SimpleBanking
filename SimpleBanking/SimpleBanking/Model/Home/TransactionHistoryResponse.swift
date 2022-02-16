//
//  TransactionHistoryResponse.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 11/02/22.
//

import Foundation

struct TransactionHistoryResponse: Codable {
    let data: [TransactionHistoryResponseDetail]
}
