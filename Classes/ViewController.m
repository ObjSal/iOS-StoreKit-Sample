//
//  ViewController.m
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

#import "ViewController.h"
#import "MyStoreKit.h"

//Contants
#define CELL_ID             @"Cell"

@implementation ViewController {
    UITableView *_tableView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //set listeners
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pricesLoadedNotification:) name:PricesLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pricesLoadedNotification:) name:PurchaseCompleteNotificationKey object:nil];
    
    //initialize views
    self.title = @"Store";
    
    //initizalize the products table
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    [self.view addSubview:_tableView];
    [_tableView reloadData];
    
    
    //initialize background tasks
    
    double delayInSeconds = 2.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        [MyStoreKit.sharedManager fetchAllProducts];
    });
}

-(void)viewWillUnload {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PricesLoadedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:PurchaseCompleteNotificationKey object:nil];
}

#pragma mark - Notification methods

-(void)pricesLoadedNotification:(NSNotification*)notification {
    if([NSThread mainThread] != [NSThread currentThread]) {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self pricesLoadedNotification:notification];
        });
        return;
    }
    
    [_tableView reloadData];
}

#pragma mark - TableViewDataSource Methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return sectionItemCount(section);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_ID];
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CELL_ID];
    }
    
    struct productInfo product = getProductInfo(indexPath.section, indexPath.row);
    cell.textLabel.text = product.name;
    
    NSNumber *purchaseCount = [[NSUserDefaults standardUserDefaults] objectForKey:product.identifier];
    if(purchaseCount) {
        cell.textLabel.text = [cell.textLabel.text stringByAppendingFormat:@" (%d)",purchaseCount.intValue];
    }
    
    if(product.price) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"$%.2f - %@", product.price, product.description];
    } else {
        cell.detailTextLabel.text = product.description;
    }
    cell.imageView.image = [UIImage imageNamed:product.imageName];
    
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return arrayCount(storeKitBundles);
}

#pragma mark - UITableViewDelegate Methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    struct productInfo product = getProductInfo(indexPath.section, indexPath.row);
    if(product.price) {
        [[MyStoreKit sharedManager] purchaseProduct:product];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
