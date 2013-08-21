//
//  SIM_SKProduct.h
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

@interface SIM_SKProduct : NSObject

@property(nonatomic, strong) NSString *localizedDescription;

@property(nonatomic, strong) NSString *localizedTitle;

@property(nonatomic, strong) NSDecimalNumber *price;

@property(nonatomic, strong) NSLocale *priceLocale;

@property(nonatomic, strong) NSString *productIdentifier;

// YES if this product has content downloadable using SKDownload
@property(nonatomic, assign, getter=isDownloadable) BOOL downloadable;

// Sizes in bytes (NSNumber [long long]) of the downloads available for this product
@property(nonatomic, strong) NSArray *downloadContentLengths;

// Version of the downloadable content
@property(nonatomic, strong) NSString *downloadContentVersion;

@end
