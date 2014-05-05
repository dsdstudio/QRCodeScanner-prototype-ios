//
//  ViewController.m
//  CameraTest
//
//  Created by bohyung kim on 2014. 5. 3..
//  Copyright (c) 2014년 bohyung kim. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
- (IBAction)click:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UILabel *capturedLabel;
@property (strong, nonatomic) UIView *cameraView;

@property (nonatomic) dispatch_queue_t sessionQueue;
@property (strong, nonatomic, retain) AVCaptureSession *session;
@property (strong, nonatomic, retain) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront] ){
        NSLog(@"앞쪽 카메라 있엉");
    }
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("AVSessionQueue", DISPATCH_QUEUE_SERIAL);
    self.sessionQueue = sessionQueue;
    
    self.session = [AVCaptureSession new];
    self.session.sessionPreset = AVCaptureSessionPresetHigh;
}

#pragma AVMeta

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    [metadataObjects enumerateObjectsUsingBlock:^(AVMetadataObject *obj, NSUInteger idx, BOOL *stop) {
        AVMetadataMachineReadableCodeObject *readableObject = (AVMetadataMachineReadableCodeObject *)obj;
        NSLog(@"%@", readableObject.stringValue);
        dispatch_async(dispatch_get_main_queue(), ^{
            self.capturedLabel.text = readableObject.stringValue;
            [[self.previewLayer connection] setEnabled:NO];
            [self.previewLayer removeFromSuperlayer];
            [self.cameraView removeFromSuperview];
            
            [self.session stopRunning];
            NSLog(@"session stopped %d", [self.session isRunning]);
            self.previewLayer = nil;
        });
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)click:(id)sender {
    if ( !self.session || [self.session isRunning] ) return;
    
    self.capturedLabel.text = @"";
    
    self.cameraView = [[UIView alloc] initWithFrame:CGRectMake(0,100, 320, 400)];
    [self.view addSubview:self.cameraView];
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *err = nil;
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&err];
    if ( !input ) {
        // TODO 에러 처리
        NSLog(@"%@",err);
        return;
    }
    if ( [self.session canAddInput:input] ) [self.session addInput:input];
    
    AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
    if ( [self.session canAddOutput:output] ) {
        [self.session addOutput:output];
        [output setMetadataObjectsDelegate:self queue:self.sessionQueue];
        [output setMetadataObjectTypes:@[AVMetadataObjectTypeQRCode]];
    }
    
    CGRect bounds = self.cameraView.layer.bounds;
    self.previewLayer = [AVCaptureVideoPreviewLayer new];
    self.previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    self.previewLayer.session = self.session;
    self.previewLayer.frame = bounds;
    self.previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [self.cameraView.layer addSublayer:self.previewLayer];
    
    [self.session startRunning];
}
@end
