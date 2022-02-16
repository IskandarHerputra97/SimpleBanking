//
//  PayeesResponse.swift
//  SimpleBanking
//
//  Created by Iskandar Herputra Wahidiyat on 11/02/22.
//

import Foundation

struct PayeesResponse: Codable {
    let data: [PayeesResponseDetail]?
    let error: Error?
}
