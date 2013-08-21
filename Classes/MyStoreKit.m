//
//  StoreKit.m
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

#import "MyStoreKit.h"

static struct productInfo storeProducts[] = {
    {
        @"5 XP",
        @"Increase your experience!",
        iTUNES_IDENTIFIER_PREFIX "1.5xp",
        @"28-star"
    },
    {
        @"20 Magic",
        @"Get more magic!",
        iTUNES_IDENTIFIER_PREFIX "1.20Magic",
        @"183-genie-lamp"
    },
    {
        @"1 heart",
        @"increase your lives",
        iTUNES_IDENTIFIER_PREFIX "1.1heart",
        @"29-heart"
    },
    {
        @"10 XP",
        @"Increase your experience!",
        iTUNES_IDENTIFIER_PREFIX "2.10xp",
        @"28-star"
    },
    {
        @"50 Magic",
        @"Get more magic!",
        iTUNES_IDENTIFIER_PREFIX "2.50Magic",
        @"183-genie-lamp"
    },
    {
        @"2 heart",
        @"increase your lives",
        iTUNES_IDENTIFIER_PREFIX "2.2Hearts",
        @"29-heart"
    }
};

static int savedItemCount[SECTIONS_COUNT];//lazy; saves the count of items in each section.
static int savedItemIndex[SECTIONS_COUNT];//lazy; saves the known start indexes of each section.

int sectionItemCount(int section) {
    if(!savedItemCount[section]) {
        int sectionCount = 0;
        
        for(int i=0; i<arrayCount(storeProducts); i++) {
            if([storeProducts[i].identifier hasPrefix:[iTUNES_IDENTIFIER_PREFIX stringByAppendingFormat:@"%d",section+1]]) {
                sectionCount++;
            }
        }
        savedItemCount[section] = sectionCount;
    }
    
    return savedItemCount[section];
}

struct productInfo getProductInfo(int section, int row) {
    int currentRow = 0;
    int i=savedItemIndex[section]?savedItemIndex[section]-1:0;
    for(; i<arrayCount(storeProducts); i++) {
        if([storeProducts[i].identifier hasPrefix:[iTUNES_IDENTIFIER_PREFIX stringByAppendingFormat:@"%d",section+1]]) {
            if(!savedItemIndex[section]) {
                savedItemIndex[section] = i+1;
            }
            if(currentRow==row) {
                break;
            }
            currentRow++;
        }
    }
    return storeProducts[i];
}

struct productInfo getProductByIdentifier(NSString *identifier) {
    struct productInfo result;
    for(int i=0; i<arrayCount(storeProducts); i++) {
        if([storeProducts[i].identifier isEqualToString:identifier]) {
            result = storeProducts[i];
            break;
        }
    }
    return result;
}

#pragma mark - MyStoreKit Implementation

@implementation MyStoreKit {
    BOOL successfulRequest;
    NSMutableDictionary *fetchedProducts;
    struct productInfo currentProduct;
}

+(void)initialize {
    //this method is called the first time this class is called.
    memset(savedItemCount, 0, SECTIONS_COUNT);
    memset(savedItemIndex, 0, SECTIONS_COUNT);
}

#pragma mark Singleton Methods

+ (id)sharedManager {
    static MyStoreKit *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
        if(sharedMyManager) {
            [[SIM_SKPaymentQueue defaultQueue] addTransactionObserver:sharedMyManager];
        }
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        //initialize stuff here.
        fetchedProducts = [NSMutableDictionary dictionary];
    }
    return self;
}

#pragma mark - helper methods

-(void)fetchAllProducts {
    if(!successfulRequest) {
        NSSet *identifiers = [NSSet setWithObjects:storeKitBundles count:arrayCount(storeKitBundles)];
        SIM_SKProductsRequest *request = [[SIM_SKProductsRequest alloc] initWithProductIdentifiers:identifiers];
        request.delegate = self;
        [request start];
    }
}

-(void)purchaseProduct:(struct productInfo)product {
    if ([SIM_SKPaymentQueue canMakePayments]) {
        currentProduct = product;
        NSString *iTunesBundleIdentifier = [product.identifier substringToIndex:[product.identifier rangeOfString:@"." options:NSBackwardsSearch].location];
        [[SIM_SKPaymentQueue defaultQueue] addPayment:[SIM_SKPayment paymentWithProduct:[fetchedProducts objectForKey:iTunesBundleIdentifier]]];
    } else {
        // Warn the user that purchases are disabled.
    }
}

#pragma mark - SKRequest Delegate Methods

//You must make a product request for a particular product identifier before allowing the user to purchase that product. Retrieving product information from the App Store ensures that you are using a valid product identifier for a product you have marked available for sale in iTunes Connect.
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    
    for (SKProduct* product in response.products) {
        //cache the product
        [fetchedProducts setObject:product forKey:product.productIdentifier];
        
        //populate the prices
        for(int i=0; i<arrayCount(storeProducts); i++) {
            struct productInfo *productInf = storeProducts+i;
            if([productInf->identifier hasPrefix:product.productIdentifier]) {
//                productInf->iTunesProduct = (SIM_SKProduct*)product; //Using ARC :'(
                productInf->price = product.price.floatValue;
            }
        }
    }
    
    //notify that the prices have been loaded
    [[NSNotificationCenter defaultCenter] postNotificationName:PricesLoadedNotification object:nil];
}

- (void)requestDidFinish:(SKRequest *)request {
    successfulRequest = YES;
}

#pragma mark - SKPaymentTransactionObserver Methods

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    for (SKPaymentTransaction *transaction in transactions)
    {
        switch (transaction.transactionState)
        {
            case SKPaymentTransactionStatePurchased:
                //The purchase has been completed.
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed:
                //Usually means hat the user cancelled the purchase
                //TODO
                break;
                
            case SKPaymentTransactionStateRestored:
                //I usually use the same method
                [self completeTransaction:transaction];
                break;
        }
    }
}

-(void)completeTransaction:(SKPaymentTransaction*)transaction
{
    @try
    {
        NSString *paymentReceipt = [[transaction transactionReceipt] base64EncodedString];
        
        //fetch the specific product identifier just in case this is a restore transaction automatically called by iOS
        NSString *specificProductIdentifier = [[NSUserDefaults standardUserDefaults] objectForKey:paymentReceipt];
        
        if(!specificProductIdentifier) {
            //Persist the specific product just in case something goes wrong.
            specificProductIdentifier = currentProduct.identifier;
            [[NSUserDefaults standardUserDefaults] setObject:currentProduct.identifier forKey:paymentReceipt];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        
        //Price might not be loaded if this is a restore transaction called by iOS; fetch the product if you would like more information.
        struct productInfo product = getProductByIdentifier(specificProductIdentifier);
        
        //TODO: Any server validation
        
        //enable feature in app/game
        NSNumber *itemCount = [[NSUserDefaults standardUserDefaults] objectForKey:product.identifier];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:itemCount.intValue+1] forKey:product.identifier];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //If something goes wrong in the above lines, finish transaction will not be called and next time the app starts
        //iOS is going to restore the purchase until finishTransaction is called.
        
        [[SIM_SKPaymentQueue defaultQueue] finishTransaction:transaction];
        
        //remove persisted pending transaction
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:paymentReceipt];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //notify the listeners
        [[NSNotificationCenter defaultCenter] postNotificationName:PurchaseCompleteNotificationKey object:nil];
        
        [[[UIAlertView alloc] initWithTitle:nil message:@"Purchase Complete!" delegate:self cancelButtonTitle:@"Okay!" otherButtonTitles:nil] show];
        
    }
    @catch (NSException *exception)
    {
        [[[UIAlertView alloc] initWithTitle:nil message:exception.description delegate:self cancelButtonTitle:@"Close :(" otherButtonTitles:nil] show];
    }
    @finally {
        
    }
}

@end
