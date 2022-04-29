//
//  SubscriptionController.swift
//  iCepa
//
//  Created by Arjun Singh on 29/4/2022.
//  Copyright © 2022 Guardian Project. All rights reserved.
//

import Foundation
import StoreKit

/// Singleton class for purchase logic
@available(iOS 15.0, *)
final class SubscriptionController {
    
    static let shared = SubscriptionController()
    
    var updates: Task<Void, Never>? = nil
    
    let IndividualSubscription: Product.ID = "com.tulabyte.tulabyte.individualSubscription"
    let FamilySubscription: Product.ID = "com.tulabyte.tulabyte.familySubscription"
    
    var availableSubscriptions: [Product.ID: Product] = [:]
    var purchasedSubscriptions: [Product.ID: Bool] = [:]
    
    private init() {
        monitorUpdates()
    }
    
    deinit {
        stopMonitoringUpdates()
    }
    
    /// Start receiving App Store Updates
    public func monitorUpdates(){
        updates = Task {
            await listenForTransactions()
        }
    }
    
    /// Stop receiving App Store Updates
    public func stopMonitoringUpdates(){
        updates?.cancel()
    }
    
    /// Get  transaction updates from the App Store to see if a user has purchased elsewhere
    private func listenForTransactions() async {
        for await result in Transaction.updates {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.revocationDate != nil {
                self.purchasedSubscriptions[transaction.productID] = false
                NSLog("TBT StoreKit: Subscription to \(transaction.productID) revoked due to reason - \(String(describing: transaction.revocationReason))")
            } else if let expirationDate = transaction.expirationDate, expirationDate < Date() {
                self.purchasedSubscriptions[transaction.productID] = false
                NSLog("TBT StoreKit: Subscription to \(transaction.productID) expired on \(String(describing: transaction.expirationDate))")
            } else if transaction.isUpgraded {
                self.purchasedSubscriptions[transaction.productID] = false
                NSLog("TBT StoreKit: Subscription upgraded to \(transaction.productID)")
            } else {
                await transaction.finish()
                await self.updatePurchasedSubscriptions()
                NSLog("TBT StoreKit: Transaction for \(transaction.productID) finished.")
            }
        }
    }
    
    /// Update metadata on available subscriptions
    public func updateAvailableSubscriptions() async {
        do {
            let products = try await Product.products(for: Set([self.IndividualSubscription, self.FamilySubscription]))
            for product in products {
                self.availableSubscriptions[product.id] = product
            }
        } catch {
            NSLog("TBT StoreKit: Could not retrieve available products")
        }
    }
    
    /// Check the current entitlements to see whether a subscription has been purchased
    private func updatePurchasedSubscriptions() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {continue}
            
            if transaction.revocationDate == nil {
                self.purchasedSubscriptions[transaction.productID] = true
            } else {
                self.purchasedSubscriptions[transaction.productID] = false
            }
        }
    }
    
    /// Purchase a subscription given a Product.ID
    public func purchaseSubcription(subscription: Product.ID) async throws {
        let result = try await self.availableSubscriptions[subscription]!.purchase()
        
        switch result {
            
        case .success(let verification):
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                await self.updateAvailableSubscriptions()
                
            case .unverified:
                throw SubscriptionPurchaseError.unverified
            }
        case .userCancelled:
            throw SubscriptionPurchaseError.userCancelled
        case .pending:
            throw SubscriptionPurchaseError.pending
        @unknown default:
            throw SubscriptionPurchaseError.unknown
        }
    }
    
    /// Check whether the user has a valid subscription
    public func hasValidSubcription() async -> Bool {
        var hasSub: Bool = false
        await self.updatePurchasedSubscriptions()
        
        if let _ = self.purchasedSubscriptions.first(where: {$0.value == true}) {
            hasSub = true
        }
        
        return hasSub
    }
}

/// All possible purchase errors when buying with StoreKit2
enum SubscriptionPurchaseError: Error {
    case unverified
    case userCancelled
    case pending
    case unknown
}

