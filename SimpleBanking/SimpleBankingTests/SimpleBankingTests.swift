//
//  SimpleBankingTests.swift
//  SimpleBankingTests
//
//  Created by Iskandar Herputra Wahidiyat on 16/02/22.
//

import XCTest
@testable import SimpleBanking

class SimpleBankingTests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testRegisterPerformance() throws {
        let registerVC = RegisterViewController()
        measure {
            registerVC.register()
        }
    }
    
    func testLoginPerformance() throws {
        let loginVC = LoginViewController()
        measure {
            loginVC.login()
        }
    }
    
    func testHomeFetchAccountDataPerformance() throws {
        let homeVC = HomeViewController()
        measure {
            homeVC.fetchAccountData()
        }
    }
    
    func testHomeFetchTransactionHistoryPerformance() throws {
        let homeVC = HomeViewController()
        measure {
            homeVC.fetchAccountData()
        }
    }
    
    func testTransferFetchPayeesPerformance() throws {
        let transferVC = TransferViewController(currentAccountBalance: 100000)
        measure {
            transferVC.fetchPayees()
        }
    }
    
    func testTransferPerformance() throws {
        let transferVC = TransferViewController(currentAccountBalance: 100000)
        measure {
            transferVC.transfer(receipientAccountNo: "2970-111-3648", amount: 1000, description: "Testing")
        }
    }
}
