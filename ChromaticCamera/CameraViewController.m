#import "CameraViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreImage/CoreImage.h>

@interface CameraViewController () <AVCaptureVideoDataOutputSampleBufferDelegate>
@property AVCaptureSession *session; @property AVCaptureVideoPreviewLayer *preview;
@property dispatch_queue_t queue; @property CIContext *context; @property UIImageView *imageView; @property UISlider *slider;
@end

@implementation CameraViewController
- (void)viewDidLoad { [super viewDidLoad]; self.view.backgroundColor = UIColor.blackColor; self.queue = dispatch_queue_create("camera.frames", DISPATCH_QUEUE_SERIAL); self.context = [CIContext contextWithOptions:nil]; [self setupUI]; [self startCamera]; }
- (void)setupUI { self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds]; self.imageView.contentMode=UIViewContentModeScaleAspectFill; [self.view addSubview:self.imageView]; self.slider=[[UISlider alloc] initWithFrame:CGRectMake(24,self.view.bounds.size.height-90,self.view.bounds.size.width-48,40)]; self.slider.autoresizingMask=UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin; self.slider.minimumValue=0; self.slider.maximumValue=0.04; self.slider.value=0.012; [self.view addSubview:self.slider]; }
- (void)startCamera { self.session=[AVCaptureSession new]; self.session.sessionPreset=AVCaptureSessionPreset1280x720; AVCaptureDevice *device=[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo]; AVCaptureDeviceInput *input=[AVCaptureDeviceInput deviceInputWithDevice:device error:nil]; if ([self.session canAddInput:input]) [self.session addInput:input]; AVCaptureVideoDataOutput *output=[AVCaptureVideoDataOutput new]; output.videoSettings=@{(id)kCVPixelBufferPixelFormatTypeKey:@(kCVPixelFormatType_32BGRA)}; [output setSampleBufferDelegate:self queue:self.queue]; if ([self.session canAddOutput:output]) [self.session addOutput:output]; if ([AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo]==AVAuthorizationStatusNotDetermined) [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL g){ if(g) dispatch_async(dispatch_get_main_queue(),^{[self.session startRunning];}); }]; else [self.session startRunning]; }
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection { CVPixelBufferRef buffer=CMSampleBufferGetImageBuffer(sampleBuffer); CIImage *image=[CIImage imageWithCVPixelBuffer:buffer]; CGFloat d=self.slider.value; CIFilter *chrom=[CIFilter filterWithName:@"CIColorMatrix"]; [chrom setValue:image forKey:kCIInputImageKey]; [chrom setValue:[CIVector vectorWithX:1 Y:0 Z:0 W:0] forKey:@"inputRVector"]; CIImage *result=[image imageByApplyingFilter:@"CIBicubicScaleTransform" withInputParameters:@{kCIInputScaleKey:@1.0}]; dispatch_async(dispatch_get_main_queue(),^{ self.imageView.image=[UIImage imageWithCIImage:result scale:1 orientation:UIImageOrientationRight]; }); }
@end
