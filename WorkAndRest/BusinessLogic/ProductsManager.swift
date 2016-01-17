//
//  ProductsManager.swift
//  WorkAndRest
//
//  Created by YangCun on 3/6/15.
//  Copyright (c) 2015 YangCun. All rights reserved.
//

import UIKit

@objc protocol ProductsManagerDelegate {
    func productsManager(productsManager: ProductsManager, paymentTransactionState state: SKPaymentTransactionState)
    
    optional
    func productsManagerRestoreFailed(productsManager: ProductsManager)
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
//        return
        print("User requests to purchase Pro.")
        
        if SKPaymentQueue.canMakePayments() {
            print("User can make payments.")
            
            let productsRequest = SKProductsRequest(productIdentifiers: NSSet(object: kProProductIdentifier) as! Set<String>)
            productsRequest.delegate = self
            productsRequest.start()
        } else {
            print("User cannot make payments due to  parental controls.")
        }
    }
    
    func purchase(product: SKProduct) {
        let payment = SKPayment(product: product)
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
        SKPaymentQueue.defaultQueue().addPayment(payment)
    }
    
    // button
    func restore() {
//        return
        print("TransactionState -> restore()")
        SKPaymentQueue.defaultQueue().restoreCompletedTransactions()
        SKPaymentQueue.defaultQueue().addTransactionObserver(self)
    }
    
    // MARK: - SKProductsRequestDelegate
    
    func productsRequest(request: SKProductsRequest, didReceiveResponse response: SKProductsResponse) {
        
        for invalidProductId in response.invalidProductIdentifiers {
            print("invalidProductId: \(invalidProductId)")
        }
        
        var validProduct: SKProduct?
        let count = response.products.count
        print("count:\(count)")
        if count > 0 {
            print("Products availabel!")
            validProduct = response.products[0]
            print("price: \(validProduct!.price)")
            print("description: \(validProduct!.localizedDescription)")
            print("localizedTitle: \(validProduct!.localizedTitle)")
            self.purchase(validProduct!)
        } else if validProduct == nil {
            print("No products available.")
        }
    }
    
    // MARK: - SKPaymentTransactionObserver
    
    func paymentQueue(queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case SKPaymentTransactionState.Purchasing:
                print("TransactionState -> Purchasing")
                // called when the user is in the process of purchasing, do not add any of your own code here.
                break
                
            case SKPaymentTransactionState.Purchased:
                print("TransactionState -> Purchased")
                
                // this is called when the user has successfully purchased the package (Cha-Ching!)
                self.doRemoveAds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction )
                break
                
            case SKPaymentTransactionState.Restored:
                print("TransactionState -> Restored")
                
                self.doRemoveAds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction )
                break
                
            case SKPaymentTransactionState.Failed:
                print("TransactionState -> Failed")
                
                /*
                if transaction.error!.code == SKErrorPaymentCancelled {
                    // The user cancelled the payment
                    print("TransactionState -> Cancelled")
                    
                }
                */
                SKPaymentQueue.defaultQueue().finishTransaction(transaction )
                break
                
            default:
                break
            }
            self.delegate?.productsManager(self, paymentTransactionState: transaction.transactionState)
        }
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(queue: SKPaymentQueue) {
        print("Received restored transactions: \(queue.transactions.count)")
        if queue.transactions.count == 0 {
            self.delegate?.productsManagerRestoreFailed!(self)
            return
        }
        for transaction in queue.transactions {
            if transaction.transactionState == SKPaymentTransactionState.Restored {
                print("paymentQueueRestoreCompletedTransactionsFinished - TransactionState -> Restored")
                self.doRemoveAds()
                SKPaymentQueue.defaultQueue().finishTransaction(transaction )
                break
            }
        }
    }
    
    func doRemoveAds() {
        print("doRemoveAds")
        ApplicationStateManager.sharedInstance.purchasedSuccess()
    }
}















