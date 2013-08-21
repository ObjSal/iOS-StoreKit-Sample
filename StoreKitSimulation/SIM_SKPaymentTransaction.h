//
//  SIM_SKPaymentTransaction.h
//
//  iOS StoreKit Sample, Huge list of in-app consumable products? No problem, here is a solution.
//  Copyright (C) 2013  Salvador Guerrero
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// NU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SIM_SKPaymentTransaction : NSObject <NSCoding>

// Only set if state is SKPaymentTransactionFailed
@property(nonatomic, strong) NSError *error;

// Only valid if state is SKPaymentTransactionStateRestored.
@property(nonatomic, strong) SKPaymentTransaction *originalTransaction;

@property(nonatomic, strong) SKPayment *payment;

// Available downloads (SKDownload) for this transaction
@property(nonatomic, strong) NSArray *downloads;

// The date when the transaction was added to the server queue.  Only valid if state is SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored.
@property(nonatomic, strong) NSDate *transactionDate;

// The unique server-provided identifier.  Only valid if state is SKPaymentTransactionStatePurchased or SKPaymentTransactionStateRestored.
@property(nonatomic, strong) NSString *transactionIdentifier;

// Only valid if state is SKPaymentTransactionStatePurchased.
@property(nonatomic, strong) NSData *transactionReceipt;

@property(nonatomic, assign) SKPaymentTransactionState transactionState;

@end
