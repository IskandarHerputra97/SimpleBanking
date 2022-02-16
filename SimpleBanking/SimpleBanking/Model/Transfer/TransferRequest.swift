//
//  TransferRequest.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 11/02/22.
//

import Foundation

struct TransferRequest: Codable {
    let receipientAccountNo: String
    let amount: Double
    let description: String
}
