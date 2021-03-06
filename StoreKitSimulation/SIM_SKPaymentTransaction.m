//
//  SIM_SKPaymentTransaction.m
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

#import "SIM_SKPaymentTransaction.h"

@implementation SIM_SKPaymentTransaction

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_transactionIdentifier forKey:@"transactionIdentifier"];
    [aCoder encodeObject:_transactionReceipt forKey:@"transactionReceipt"];
    [aCoder encodeObject:[NSNumber numberWithInt:_transactionState] forKey:@"transactionState"];
}
- (id)initWithCoder:(NSCoder *)aDecoder {
    self.transactionIdentifier = [aDecoder decodeObjectForKey:@"transactionIdentifier"];
    self.transactionReceipt = [aDecoder decodeObjectForKey:@"transactionReceipt"];
    self.transactionState = [[aDecoder decodeObjectForKey:@"transactionState"] intValue];
    return self;
}

@end
