//
//  ActionViewController.m
//  KeychainPassword
//
//  Created by Nanba Takeo on 2014/08/15.
//  Copyright (c) 2014年 GrooveLab. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ActionViewController ()
@end

@implementation ActionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //  if you want to delete password, uncomment the below line
//    [self deleteItemAsync];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    NSDictionary *query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: @"SampleService",
                            (__bridge id)kSecReturnData: @YES,
                            (__bridge id)kSecUseOperationPrompt: @"authorize"
                            };
    
    __block ActionViewController* instance = self;
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){

        CFTypeRef dataTypeRef = NULL;
        OSStatus status = SecItemCopyMatching((__bridge CFDictionaryRef)(query), &dataTypeRef);
        NSData *resultData = (__bridge NSData *)dataTypeRef;
        NSString *stringForCopy = [[NSString alloc] initWithData:resultData encoding:NSUTF8StringEncoding];
        if ( status != errSecSuccess ) {
            //  show error alert
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"error" message:@"not saved passwrord" preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"launch containing app" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //  open containing app
                NSString *urlStr = @"asia.groovelab.ActionExtensionContaining://";
                //                [[self extensionContext] openURL:[NSURL URLWithString:urlStr] completionHandler:nil];
                
                UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0,1,1)];
                [instance.view addSubview:webView];
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]];
                [webView loadRequest:request];
            }]];
            [instance presentViewController:alert animated:YES completion:nil];
            return;
        }
        
        UIPasteboard *pasteBoard = [UIPasteboard generalPasteboard];
        [pasteBoard setValue:stringForCopy forPasteboardType:@"public.utf8-plain-text"];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    [self.extensionContext completeRequestReturningItems:self.extensionContext.inputItems completionHandler:nil];
}

- (void)deleteItemAsync
{
    NSDictionary *query = @{
                            (__bridge id)kSecClass: (__bridge id)kSecClassGenericPassword,
                            (__bridge id)kSecAttrService: @"SampleService"
                            };
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)(query));
        NSLog( @"%d", status );
    });
}

@end
