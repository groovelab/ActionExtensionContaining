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

@property (weak, nonatomic) IBOutlet UITextField *passwordLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

@synthesize passwordLabel;
@synthesize imageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)savePasswordAction:(id)sender {

    NSString *passwordString = self.passwordLabel.text;
    NSDictionary *query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: @"SampleService",
                            (__bridge id)kSecUseOperationPrompt: @"認証"
                            };
    
    NSDictionary *changes = @{
                              (__bridge id)kSecValueData: [passwordString dataUsingEncoding:NSUTF8StringEncoding]
                              };
    
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        OSStatus status = SecItemUpdate((__bridge CFDictionaryRef)query, (__bridge CFDictionaryRef)changes);
        NSLog( @"status : %d", status );
        
        if ( status == -25300 ) {
            //  未登録
            CFErrorRef error = NULL;
            SecAccessControlRef sacObject;
            sacObject = SecAccessControlCreateWithFlags(kCFAllocatorDefault,
                                                        kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly,
                                                        kSecAccessControlUserPresence, &error);
            if(sacObject == NULL || error != NULL) {
                NSLog(@"can't create sacObject: %@", error);
                return;
            }
            
            NSDictionary *attributes = @{
                                         (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                                         (__bridge id)kSecAttrService: @"SampleService",
                                         (__bridge id)kSecValueData: [passwordString dataUsingEncoding:NSUTF8StringEncoding],
                                         (__bridge id)kSecAttrAccessControl: (__bridge id)sacObject
                                         };
            
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
                OSStatus status =  SecItemAdd((__bridge CFDictionaryRef)attributes, nil);
                NSLog( @"2status : %d", status );
                if ( status != errSecSuccess ) {
                    NSLog( @"2errror" );
                }
            });
        } else if ( status != errSecSuccess ) {
            NSLog( @"errror" );
        }
        
        
    });
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
