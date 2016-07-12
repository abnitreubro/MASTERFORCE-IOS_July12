//
//  CameraListingViewController.h
//  VideoScope
//
//  Created by JS Products on 04/03/16.
//  Copyright © 2016  JS Products. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "PlayViewController.h"
#import "ListTableViewCell.h"


@interface CameraListingViewController : UITableViewController<NSFetchedResultsControllerDelegate>
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property(nonatomic,strong)NSFetchedResultsController*fetchedResultsController;

@end
