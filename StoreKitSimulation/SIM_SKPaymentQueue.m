//
//  SIM_SKPaymentQueue.m
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

#import "SIM_SKPaymentQueue.h"
#import "SIM_SKPaymentTransaction.h"
#import "SIM_SKPayment.h"

#define PendingTransactionsKey  @"pendingTransactionsKey"

@implementation SIM_SKPaymentQueue {
    id<SKPaymentTransactionObserver> _observer;
    SKPayment* _payment;
}

+ (id)defaultQueue {
    static SIM_SKPaymentQueue *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

+(BOOL)canMakePayments {
    return YES;
}

-(void)addTransactionObserver:(id<SKPaymentTransactionObserver>)observer {
    _observer = observer;
    //trigger restore pending transactions
    NSArray *pendingTransactions = [NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PendingTransactionsKey]];
    if([pendingTransactions count]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [_observer paymentQueue:(SKPaymentQueue*)self updatedTransactions:pendingTransactions];
        });
    }
}

-(void)addPayment:(SKPayment*)payment {
    _payment = payment;
    SKProduct *product = [(SIM_SKPayment *)_payment product];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Confirm Your In-App Purchase" message:[NSString stringWithFormat:@"Do you want to buy one %@ for $%.2f?",product.localizedTitle, product.price.floatValue] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Buy", nil];
    
    [alert show];
}

-(void)finishTransaction:(SKPaymentTransaction*)transaction {
    //remove persisted transaction
    NSMutableArray *pendingTransactions = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PendingTransactionsKey]]];
    //get transaction With the same transaction receipt and remove it the pending transactions.
    //need to check for transactionReceipt because I use NSKeyedArchiver
    for(SIM_SKPaymentTransaction *trans in pendingTransactions){
        if([trans.transactionReceipt isEqualToData:transaction.transactionReceipt]) {
            [pendingTransactions removeObject:trans];
            break;
        }
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:pendingTransactions] forKey:PendingTransactionsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - UIAlertViewDelegate Methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Buy"]) {
        SIM_SKPaymentTransaction *transaction = [[SIM_SKPaymentTransaction alloc] init];
        transaction.transactionReceipt = [[[NSUUID UUID] UUIDString] dataUsingEncoding:NSUTF8StringEncoding];
        transaction.payment = _payment;
        transaction.transactionState = SKPaymentTransactionStatePurchased;
        
        //persist transaction
        //Asuming they are all consumables.
        NSMutableArray *pendingTransactions = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults] objectForKey:PendingTransactionsKey]]];
        [pendingTransactions addObject:transaction];
        [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:pendingTransactions] forKey:PendingTransactionsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [_observer paymentQueue:(SKPaymentQueue*)self updatedTransactions:[NSArray arrayWithObject:transaction]];
    }
}

@end
