//
//  RootViewController.h
//  TopSongs
//
//  Created by Hidayahulla on 9/25/13.
//  Copyright (c) 2013 Individual. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RootViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> 
    // The main data model for our UITableView
    @property (nonatomic, strong) NSArray *entries;
    @property (nonatomic, strong) UITableView *customTableView;

@end
