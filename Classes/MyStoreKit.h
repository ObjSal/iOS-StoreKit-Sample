//
//  StoreKit.h
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
#import "SIM_SKProductsRequest.h"
#import "SIM_SKPaymentQueue.h"
#import "SIM_SKPayment.h"
#import "SIM_SKProduct.h"

#pragma mark - Contants

#define SECTIONS_COUNT      2
#define PurchaseCompleteNotificationKey @"purchaseCompleteNotificationKey"

#pragma mark - structs

struct productInfo {
    __unsafe_unretained NSString *name;
    __unsafe_unretained NSString *description;
    __unsafe_unretained NSString *identifier;
    __unsafe_unretained NSString *imageName;
//    __unsafe_unretained SIM_SKProduct *iTunesProduct;//Using ARC :'(
    float price;
};

//some useful C functions
int sectionItemCount(int section);
struct productInfo getProductInfo(int section, int row);

//Notifications
#define PricesLoadedNotification    @"pricesLoadedNotificarion"

@interface MyStoreKit : NSObject <SKProductsRequestDelegate, SKPaymentTransactionObserver>
+ (id)sharedManager;
-(void)fetchAllProducts;
-(void)purchaseProduct:(struct productInfo)product;
@end
