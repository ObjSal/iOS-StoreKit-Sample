//
//  SIM_SKProductsRequest.h
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
#import <StoreKit/StoreKit.h>//Added

@interface SIM_SKProductsRequest : NSObject
//properties
@property(nonatomic, strong)id<SKProductsRequestDelegate>   delegate;

//methods
-(SIM_SKProductsRequest*)initWithProductIdentifiers:(NSSet*)identifiers;
-(void)start;
@end
