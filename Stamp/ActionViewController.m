//
//  ActionViewController.m
//  Stamp
//
//  Created by Nanba Takeo on 2014/08/15.
//  Copyright (c) 2014年 GrooveLab. All rights reserved.
//

#import "ActionViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
@import AVFoundation;

@interface ActionViewController ()

@property(strong,nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *stamp;

@end

@implementation ActionViewController

@synthesize imageView;
@synthesize stamp;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Get the item[s] we're handling from the extension context.
    
    // For example, look for an image and place it into an image view.
    // Replace this with something appropriate for the type[s] your extension supports.
    BOOL imageFound = NO;
    for (NSExtensionItem *item in self.extensionContext.inputItems) {
        for (NSItemProvider *itemProvider in item.attachments) {
            if ([itemProvider hasItemConformingToTypeIdentifier:(NSString *)kUTTypeImage]) {
                // This is an image. We'll load it, then place it in our image view.
                __weak ActionViewController *instance = self;
                [itemProvider loadItemForTypeIdentifier:(NSString *)kUTTypeImage options:nil completionHandler:^(UIImage *image, NSError *error) {
                    if(image) {
                        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                            [instance.imageView setImage:image];
                            instance.imageView.userInteractionEnabled = YES;
                            [instance.imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                                             action:@selector(touchAction:)]];
                            instance.stamp = [UIImage imageNamed:@"stamp.gif"];
                        }];
                    }
                }];
                
                imageFound = YES;
                break;
            }
        }
        
        if (imageFound) {
            // We only handle one image, so stop looking for more.
            break;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)done {
    // Return any edited content to the host app.
    // This template doesn't do anything, so we just echo the passed in items.
    NSExtensionItem* extensionItem = [[NSExtensionItem alloc] init];
    [extensionItem setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Image with stamp"]];
    [extensionItem setAttachments:@[[[NSItemProvider alloc] initWithItem:[self.imageView image] typeIdentifier:(NSString*)kUTTypeImage]]];
    [self.extensionContext completeRequestReturningItems:@[extensionItem] completionHandler:nil];
}

#pragma mark Action Methods
- (void)touchAction:(UITapGestureRecognizer*)sender {
    
    CGRect imageFrame = [self imageFrame];
    CGPoint touchedPoint = [sender locationInView:self.imageView];
    if ( !CGRectContainsPoint(imageFrame, touchedPoint) ) {
        return;
    }
    
    touchedPoint = CGPointMake(touchedPoint.x - imageFrame.origin.x,
                               touchedPoint.y - imageFrame.origin.y );
    NSLog(@"touched %f %f", touchedPoint.x, touchedPoint.y);
    
    CGFloat scale = self.imageView.image.size.height / imageFrame.size.height;
    CGPoint position = [self scalePosition:touchedPoint scale:scale];
    UIImage *image = [self compositeImages:self.imageView.image
                                  addImage:self.stamp
                               addPosition:position];
    self.imageView.image = image;
}

#pragma mark Private Methods

- (CGRect)imageFrame {
    static CGRect imageFrame;
    if ( imageFrame.size.height > 0 ) {
        return imageFrame;
    }

    CGRect frame = AVMakeRectWithAspectRatioInsideRect(self.imageView.image.size, self.imageView.bounds);
    CGRect imageViewFrame = self.imageView.frame;
    imageFrame = CGRectMake((imageViewFrame.size.width - frame.size.width) / 2.0,
                                   (imageViewFrame.size.height - frame.size.height) / 2.0,
                                   frame.size.width,
                                   frame.size.height );
    NSLog( @"imageFrame %f %f", imageFrame.origin.x, imageFrame.origin.y );
    return imageFrame;
}

- (CGPoint)scalePosition:(CGPoint)originalPosition scale:(CGFloat)scale {
    return CGPointMake( originalPosition.x * scale, originalPosition.y * scale );
}

- (UIImage *)compositeImages:(UIImage*)baseImage addImage:(UIImage*)addImage addPosition:(CGPoint)point {
    UIImage *image = nil;
    
    UIGraphicsBeginImageContext(CGSizeMake(baseImage.size.width, baseImage.size.height));
    [baseImage drawAtPoint:CGPointMake(0, 0)];
    
    point = CGPointMake( point.x - (addImage.size.width)/2 , point.y - (addImage.size.height)/2);
    [addImage drawAtPoint:point];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
