//
//  FullScreenCaptureVC.m
//  Place
//
//  Created by Iurii Oliiar on 4/25/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "FullScreenCaptureVC.h"

#import <AVFoundation/AVFoundation.h>
#import <ImageIO/CGImageProperties.h>

@interface FullScreenCaptureVC ()

@property(nonatomic, retain) AVCaptureStillImageOutput *stillImageOutput;
@property (strong, nonatomic) IBOutlet UIView *videoPreview;

@end

@implementation FullScreenCaptureVC

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    return ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPad || orientation == UIDeviceOrientationPortrait);
}

- (BOOL)shouldAutorotate {
    return NO;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    AVCaptureSession *session = [[[AVCaptureSession alloc] init] autorelease];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    AVCaptureVideoPreviewLayer *captureVideoPreviewLayer = [[[AVCaptureVideoPreviewLayer alloc] initWithSession:session] autorelease];
    captureVideoPreviewLayer.frame = self.videoPreview.bounds;
    captureVideoPreviewLayer.orientation = [UIApplication sharedApplication].statusBarOrientation;
    [self.videoPreview.layer addSublayer:captureVideoPreviewLayer];
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    if (!input) {
        NSLog(@"ERROR: trying to open camera: %@", error);
    }
    [session addInput:input];
    self.stillImageOutput = [[[AVCaptureStillImageOutput alloc] init] autorelease];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    AVVideoCodecJPEG, AVVideoCodecKey, nil];
    [self.stillImageOutput setOutputSettings:outputSettings];
    [outputSettings release];
    [session addOutput:self.stillImageOutput];
    [session startRunning];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    self.toolbar = nil;
}

#pragma mark Actions implemenation

- (IBAction)cancel:(UIBarButtonItem *)sender {
    [self.delegate fullScreenVCCancelledPicking];
    [self dismissViewControllerAnimated:YES
                             completion:nil];
}

- (IBAction)capture:(UIBarButtonItem *)sender {
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.stillImageOutput.connections) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] ) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) {
            break;
        }
    }
   
    [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
        
         NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
         UIImage *image = [[[UIImage alloc] initWithData:imageData] autorelease];
        UIImage *im;
        switch ([UIApplication sharedApplication].statusBarOrientation) {
            case UIInterfaceOrientationLandscapeLeft: {
               im = [UIImage imageWithCGImage:image.CGImage
                                      scale:[UIScreen mainScreen].scale
                                orientation:UIImageOrientationDown];

            }
                break;
            case UIInterfaceOrientationLandscapeRight: {
                im = [UIImage imageWithCGImage:image.CGImage
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationUp];

            }
                break;
            case UIInterfaceOrientationPortrait: {
                im = [UIImage imageWithCGImage:image.CGImage
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationRight];

            }
                break;
            case UIInterfaceOrientationPortraitUpsideDown: {
                im = [UIImage imageWithCGImage:image.CGImage
                                         scale:[UIScreen mainScreen].scale
                                   orientation:UIImageOrientationLeft];

            }
                break;
            default:
                NSLog(@"Unknown orienation");
                break;
        }

        [self.delegate fullScreenVCFinishedPickingImage:im];
        [self dismissViewControllerAnimated:YES
                                 completion:nil];
     }];
}



- (void)dealloc {
    [_toolbar release];
    [super dealloc];
}
- (void)viewDidUnload {
    self.toolbar = nil;
    [super viewDidUnload];
}
    @end
