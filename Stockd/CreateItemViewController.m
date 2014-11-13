//
//  CreateListViewController.m
//  Stockd
//
//  Created by Adam Duflo on 11/5/14.
//  Copyright (c) 2014 Amaeya Kalke. All rights reserved.
//

#import "CreateItemViewController.h"
#import "Photo.h"

@interface CreateItemViewController ()
@property (weak, nonatomic) IBOutlet UITextField *itemDescriptionTextField;
@property (weak, nonatomic) IBOutlet UILabel *quickListLabel;
@property (weak, nonatomic) IBOutlet UISwitch *quickListSwitch;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CreateItemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.fromListDetails == YES) {
        [self hideQuickListObjects];
    } else if (self.fromInventory == YES) {
        [self.quickListSwitch setOn:NO];
        [self showQuickListObjects];
    } else if (self.editingFromInventory == YES) {
        if (self.item.isInQuickList == YES) {
            [self.quickListSwitch setOn:YES];
        } else {
            [self.quickListSwitch setOn:NO];
        }
        [self showQuickListObjects];
        self.quickListLabel.text = @"In Quick List";
        self.itemDescriptionTextField.text = self.item.type;
    } else if (self.editingFromListDetails == YES) {
        [self hideQuickListObjects];
        self.itemDescriptionTextField.text = self.item.type;
    }
}

#pragma mark - Helper Methods

- (void)resetBOOLs {
    self.fromInventory = NO;
    self.fromListDetails = NO;
    self.editingFromInventory = NO;
    self.editingFromListDetails = NO;
}

- (void)hideQuickListObjects {
    self.quickListLabel.hidden = YES;
    self.quickListSwitch.hidden = YES;
    self.quickListSwitch.userInteractionEnabled = NO;
}

- (void)showQuickListObjects {
    self.quickListLabel.hidden = NO;
    self.quickListSwitch.hidden = NO;
    self.quickListSwitch.userInteractionEnabled = YES;
}

- (void)noDescriptionAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Missing Information" message:@"Please fill item description" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okay = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:okay];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - IBActions

- (IBAction)addItemOnButtonPress:(id)sender {
    PFUser *user = [PFUser currentUser];
    if (self.fromInventory || self.fromListDetails) {
        Item *item = [[Item alloc] init];
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            if (self.fromInventory == YES) {
                [item createNewItemWithType:self.itemDescriptionTextField.text forUser:user inList:nil inInventory:YES isInQuickList:self.quickListSwitch.isOn];
            } else if (self.fromListDetails == YES) {
                [item createNewItemWithType:self.itemDescriptionTextField.text forUser:user inList:self.listID inInventory:NO isInQuickList:NO];
            }
            [self dismissViewControllerAnimated:YES completion:^{
                [self resetBOOLs];
            }];
        }
    } else if (self.editingFromInventory || self.editingFromListDetails) {
        if ([self.itemDescriptionTextField.text isEqualToString:@""]) {
            [self noDescriptionAlert];
        } else {
            if (self.editingFromInventory) {
                [self.item setObject:[NSNumber numberWithBool:self.quickListSwitch.isOn] forKey:@"isInQuickList"];
            }
            self.item.type = self.itemDescriptionTextField.text;
            [self.item setObject:self.itemDescriptionTextField.text forKey:@"type"];
            
            [self.item saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (error) {
                    NSLog(@"%@", error);
                } else if (succeeded) {
                    [self dismissViewControllerAnimated:YES completion:^{
                        [self resetBOOLs];
                    }];
                }
            }];
        }
    }
}

- (IBAction)cancelItemCreationOnButtonPress:(id)sender {
    self.quickListLabel.text = @"Add to Quick List?";
    [self dismissViewControllerAnimated:YES completion:^{
        [self resetBOOLs];
    }];
}

- (IBAction)uploadPhotoOnButtonPress:(id)sender {
    //    NSData *data = UIImagePNGRepresentation(self.imageView.image);
    //    PFFile *imageFile = [PFFile fileWithData:data];
    //    PFUser *currentUser = [PFUser currentUser];
    //
    //    [imageFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //        if(!error){
    //            Photo *newPhotoObject = [Photo objectWithClassName: @"Photo"];
    //            [newPhotoObject setObject:imageFile forKey:@"image"];
    //
    //            [newPhotoObject createPhotoObject: nil :currentUser];
    //
    //            [newPhotoObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
    //                if(error){
    //                    NSLog(@"%@", error);
    //                }
    //                else{
    //                    NSLog(@"Image Saved");
    //                }
    //            }];
    //        }
    //        else{
    //            NSLog(@"%@", error);
    //        }
    //    }];
}

- (IBAction)setQuickListOnSwitch:(id)sender {
    
    if ([self.quickListSwitch isOn]) {
        [self.quickListSwitch setOn:YES animated:YES];
    } else {
        [self.quickListSwitch setOn:NO animated:YES];
    }
}

@end
