//
//  ProductsManager.swift
//  WorkAndRest
//
//  Created by YangCun on 3/6/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

protocol ProductsManagerDelegate {
    func productsManager(productsManager: ProductsManager, paymentTransactionState state: SKPaymentTransactionState)
}

private let _singletonInstance = ProductsManager()
class ProductsManager: NSObject, SKProductsRequestDelegate, SKPaymentTransactionObserver {
    let kProProductIdentifier = "com.yangcun.WorkAndRest.pro"
    var delegate: ProductsManagerDelegate?
    
    class var sharedInstance: ProductsManager {
        return _singletonInstance
    }
    // button
    func purchasePro() {
        println("User requests to purchase Pro.")
        
        if SKPaymentQueue.canMakePayments() {
            println("User can make payments.")
            
            let productsRequest = SKProductsRequest(productIdentifiers: NSSet(object: kProProductIdentifier))
            productsRequest.delegate = self
            productsRequest.start()
        } else {
            println("User cannot make payments due to  parental controls.")
        }
    }
    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    // button
    func restore() {
        println("TransactionState -> restore()")
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
//        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(request: SKProductsRequest!, didReceiveResponse response: SKProductsResponse!) {
        
        for invalidProductId in response.invalidProductIdentifiers {
            println("invalidProductId: \(invalidProductId)")
        }
        
        var validProduct: SKProduct?
        let count = response.products.count
        println("count:\(count)")
        if count > 0 {
            println("Products availabel!")
            validProduct = response.products[0] as? SKProduct
        } else if validProduct == nil {
            println("No products available.")
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(queue: SKPaymentQueue!, updatedTransactions transactions: [AnyObject]!) {
        for transaction in transactions {
            switch transaction.transactionState! {
            case SKPaymentTransactionState.Purchasing:
                println("TransactionState -> Purchasing")
                // called when the user is in the process of purchasing, do not add any of your own code here.
                break
                
            case SKPaymentTransactionState.Purchased:
                println("TransactionState -> Purchased")
                
                // this is called when the user has successfully purchased the package (Cha-Ching!)
                self.doRemoveAds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
                
            case SKPaymentTransactionState.Restored:
                println("TransactionState -> Restored")
                
                self.doRemoveAds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
                
            case SKPaymentTransactionState.Failed:
                println("TransactionState -> Failed")
                
                if transaction.errorStatusCode == SKErrorPaymentCancelled {
                    // The user cancelled the payment
                    println("TransactionState -> Cancelled")
                    
                }
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
                
            default:
                break
            }
            //self.delegate?.productsManager(self, paymentTransactionState: transaction.transactionState)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue!) {
        println("Received restored transactions: \(queue.transactions.count)")
        for transaction in queue.transactions {
            if transaction.transactionState == SKPaymentTransactionState.Restored {
                println("TransactionState -> Restored")
                self.doRemoveAds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction as SKPaymentTransaction)
                break
            }
        }
    }
    
    func doRemoveAds() {
        println("doRemoveAds")
        ApplicationStateManager.sharedInstance.purchasedSuccess()
    }
}















