//
//  ViewController.m
//  ActionExtensionContaining
//
//  Created by Nanba Takeo on 2014/08/15.
//  Copyright (c) 2014年 GrooveLab. All rights reserved.
//

#import "ViewController.h"
@import MobileCoreServices;

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

@synthesize imageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)actionToImage:(id)sender {
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[[self.imageView image]] applicationActivities:nil];
    
    [activityViewController setCompletionWithItemsHandler:^(NSString *activityType, BOOL completed, NSArray *returnedItems, NSError * error){
        
        if([returnedItems count] > 0){
            NSExtensionItem* extensionItem = [returnedItems firstObject];
            NSItemProvider* imageItemProvider = [[extensionItem attachments] firstObject];
            
            if([imageItemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]){
                [imageItemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *item, NSError *error) {
                    if(item && !error){
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.imageView setImage:item];
                        });
                        
                    }
                }];
            }
        }
    }];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
