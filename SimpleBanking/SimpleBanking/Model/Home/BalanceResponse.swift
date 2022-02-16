//
//  BalanceResponse.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 11/02/22.
//

import Foundation

struct BalanceResponse: Codable {
    let status: String
    let accountNo: String?
    let balance: Double?
    let error: Error?
}
