//
//  fcameraViewController.m
//  fCamera
//
//  Created by Nicholas Suan on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "fcameraViewController.h"
#import "Base64.m"

void useCamera();
void useCameraRoll();

NSTimer *initTimer;
UIImage *image;
BOOL hasImage = FALSE;
//@synthesize webView;

@implementation fcameraViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.imageView = nil;

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissModalViewControllerAnimated:YES];
}

    
-(IBAction)showActionSheet:(id)sender {
	UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:@"" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Take Photo Or Video...", @"Choose From Library", nil];
	popupQuery.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[popupQuery showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex == 0) {
		[self useCamera];
	} else if (buttonIndex == 1) {
		[self useCameraRoll];
	}
}

- (void) useCamera
{
    //Handler for camera.

    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = 
        UIImagePickerControllerSourceTypeCamera;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
//        [imagePicker release];
        newMedia = YES;
    }
}

- (void) useCameraRoll
{
    
    //Handler for stored image picker.
    
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeSavedPhotosAlbum])
    {
        UIImagePickerController *imagePicker =
        [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = 
        UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.mediaTypes = [NSArray arrayWithObjects:
                                  (NSString *) kUTTypeImage,
                                  nil];
        imagePicker.allowsEditing = NO;
        [self presentModalViewController:imagePicker animated:YES];
//       [imagePicker release];
        newMedia = NO;
    }
}


- (NSString *) htmlForJPEGImage:(UIImage *) imageObj {
    
    //Generate data object for web view from UIImage object.
    
    imageData = UIImageJPEGRepresentation(imageObj, 1.0);
    NSString *imageSource = [NSString stringWithFormat:@"data:image/jpeg;base64,%@",[imageData base64Encoding]];
    return [NSString stringWithFormat:@"Test: <img src='%@' />", imageSource];
}


-(void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    [self dismissModalViewControllerAnimated:YES];
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        image = [info 
                          objectForKey:UIImagePickerControllerOriginalImage];
        
        //Display image in webview using data: URI
        NSString *html =  [self htmlForJPEGImage :image];
        [imageView loadHTMLString:html baseURL:nil];
        
        if (newMedia)
            UIImageWriteToSavedPhotosAlbum(image, 
                                           self,
                                           @selector(image:finishedSavingWithError:contextInfo:),
                                           nil);
       // if(!hasImage) 
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
		// Code here to support video if enabled
	}
}


- (IBAction)uploadImage {
	NSString *urlString = @"https://1e400.net/upload-iphone";
    
	// setting up the request object now
	NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
	[request setURL:[NSURL URLWithString:urlString]];
	[request setHTTPMethod:@"POST"];
    

    
    CFUUIDRef	uuidObj = CFUUIDCreate(nil);
    NSString	*uuidString = (NSString*)CFUUIDCreateString(nil, uuidObj);
    CFRelease(uuidObj);
    
    //Create Boundry
	NSString *boundary = [NSString stringWithFormat:@"---------------------------%@", uuidString];
	NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
	[request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
	/*
     Post body
    */
	NSMutableData *body = [NSMutableData data];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Disposition: form-data; name=\"media\"; filename=\"photo.jpg\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[[NSString stringWithString:@"Content-Type: application/octet-stream\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
	[body appendData:[NSData dataWithData:imageData]];
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    
	// Set the body of reqeust
	[request setHTTPBody:body];
    
	// Upload time
	NSData *returnData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
	NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
    
    //Open safari to the image location
    NSURL *imageURI = [NSURL URLWithString:returnString];
    if(![[UIApplication sharedApplication] openURL:imageURI]){
        NSLog(@"Failed to open URL");
    }
	NSLog(@"%@", returnString);
}


-(void)image:(UIImage *)image
finishedSavingWithError:(NSError *)error 
 contextInfo:(void *)contextInfo
{
    if (error) {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle: @"Save failed"
                              message: @"Failed to save image"
                              delegate: nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil];
        [alert show];
//        [alert release];
    }
}
@end
