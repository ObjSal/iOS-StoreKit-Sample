//
//  SIM_SKProductsRequest.m
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

#import "SIM_SKProductsRequest.h"
#import "SIM_SKProductsResponse.h"
#import "SIM_SKProduct.h"

@implementation SIM_SKProductsRequest {
    NSSet *identifiersRequested;
    NSDictionary *serverProducts;
}

-(SIM_SKProductsRequest*)initWithProductIdentifiers:(NSSet*)identifiers {
    self = [super init];
    if(self) {
        //save the requested identifiers
        identifiersRequested = [NSSet setWithSet:identifiers];
        
        //simulate server stored in-app products
        NSMutableDictionary *simServerProducts = [NSMutableDictionary dictionaryWithCapacity:identifiers.count];
        
        SIM_SKProduct *product = [[SIM_SKProduct alloc] init];
        product.productIdentifier = iTUNES_IDENTIFIER_PREFIX "1";
        product.price = [NSDecimalNumber decimalNumberWithDecimal:[NSNumber numberWithFloat:1.0f].decimalValue];
        product.localizedTitle = @"Group 1";
        [simServerProducts setObject:product forKey:product.productIdentifier];
        
        product = [[SIM_SKProduct alloc] init];
        product.productIdentifier = iTUNES_IDENTIFIER_PREFIX "2";
        product.price = [NSDecimalNumber decimalNumberWithDecimal:[NSNumber numberWithFloat:2.0f].decimalValue];
        product.localizedTitle = @"Group 2";
        [simServerProducts setObject:product forKey:product.productIdentifier];
        
        serverProducts = [NSDictionary dictionaryWithDictionary:simServerProducts];
    }
    return self;
}

-(void)start {
    SIM_SKProductsResponse *response = [[SIM_SKProductsResponse alloc] init];
    response.products = [serverProducts objectsForKeys:identifiersRequested.allObjects notFoundMarker:[NSNumber numberWithInt:NSNotFound]];
    
    //casting to use the original protocol method from SKProductsRequestDelegate
    [_delegate productsRequest:(SKProductsRequest*)self didReceiveResponse:(SKProductsResponse*)response];
    [_delegate requestDidFinish:(SKRequest *)self];
}

@end
