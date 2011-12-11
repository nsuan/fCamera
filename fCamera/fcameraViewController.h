//
//  fcameraViewController.h
//  fCamera
//
//  Created by Nicholas Suan on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <MobileCoreServices/UTCoreTypes.h>

@interface fcameraViewController : UIViewController
<UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    IBOutlet UIWebView *imageView;
    BOOL newMedia;
}
@property (nonatomic, retain) UIWebView *imageView;
//@property (nonatomic, retain) IBOutlet UIWebView *imageView;

- (IBAction)useCamera;
- (IBAction)useCameraRoll;
@end




    