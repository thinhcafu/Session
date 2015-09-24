//
//  ViewController.m
//  Session
//
//  Created by ECEP2010 on 9/24/15.
//  Copyright (c) 2015 ECEP. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    NSURLSession *_session;
}

@property (strong, nonatomic) NSURLSessionDownloadTask *downloadTask;
@property (strong, nonatomic) NSData *resumeData;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:@"https://itunes.apple.com/search?term=apple&media=software"] completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
//    
//    
//        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//        NSLog(@"%@", json);
//    }];
//    
//    [dataTask resume];

    /* dowload image*/
//    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
//    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithURL:[NSURL URLWithString:@"http://cdn.tutsplus.com/mobile/uploads/2013/12/sample.jpg"]];
//    [downloadTask resume];
    
    /* Using configuration session*/
    // Create Session Configuration
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Configure Session Configuration
    [sessionConfiguration setAllowsCellularAccess:YES];
    [sessionConfiguration setHTTPAdditionalHeaders:@{@"Accept" : @"application/json"}];
    
    // Create Session
    NSURLSession *session  = [NSURLSession sessionWithConfiguration:sessionConfiguration];
    
    // Send request
    NSURL *url = [NSURL URLWithString:@"https://itunes.apple.com/search?term=apple&media=software"];
    [[session dataTaskWithURL:url completionHandler:
      ^(NSData *data, NSURLResponse *response, NSError *error){
          NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
      }] resume];
    
    // Add Observer
    [self addObserver:self forKeyPath:@"resumeData" options:NSKeyValueObservingOptionNew context:NULL];
    [self addObserver:self forKeyPath:@"downloadTask" options:NSKeyValueObservingOptionNew context:NULL];
    
    // Setup User Interface
    [self.cancelButton setHidden:YES];
    [self.resumeButton setHidden:YES];
    
    // Create Dowload Task
    self.downloadTask = [self.session downloadTaskWithURL:[NSURL URLWithString:@"http://cdn.tutsplus.com/mobile/uploads/2014/01/5a3f1-sample.jpg"]];
    
    // Resume Dowload Task
    [self.downloadTask resume];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)contex{
    
    if ([keyPath isEqualToString:@"resumeData"]) {
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.resumeButton setHidden:(self.resumeData == nil)];
        });
    } else if ([keyPath isEqualToString:@"downloadTask"]){
        
        dispatch_async(dispatch_get_main_queue(), ^{
        
            [self.cancelButton setHidden:(self.downloadTask == nil)];
        });
    }

}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{

    NSData *data = [NSData dataWithContentsOfURL:location];
    
    dispatch_async(dispatch_get_main_queue(), ^{
    
        [self.cancelButton setHidden:YES];
        [self.progressView setHidden:YES];
        [self.imageView setImage:[UIImage imageWithData:data]];
    });
    
    // Invalidaye Session
    [session finishTasksAndInvalidate];
}

- (IBAction)cancel:(id)sender{

    if (!self.downloadTask) {
        return;
    }
    
    // Hide Cacel Button
    [self.cancelButton setHidden:YES];
    
    [self.downloadTask cancelByProducingResumeData:^(NSData *resumeData){
    
        if (!resumeData) {
            return ;
        }
        [self setResumeData:resumeData];
        [self setDownloadTask:nil];
    }];
}

- (IBAction)resume:(id)sender{

    if (!self.resumeData) {
        return;
    }
    
    // Hide Resume Button
    [self.resumeButton setHidden:YES];
    
    // Create Dowload task
    self.downloadTask = [self.session downloadTaskWithResumeData:self.resumeData];
    
    // Resume Download Task
    [self.downloadTask resume];
    
    // CLeanup
    [self setResumeData:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSURLSession *)session{

    if (!_session) {
        // Create Session Configuratoin
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        
        // Create Session
        _session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    }
    
    return _session;
}

//- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location{
//
//    NSData *data = [NSData dataWithContentsOfURL:location];
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//    
//        [self.progressView setHidden:YES];
//        [self.imageView setImage:[UIImage imageWithData:data]];
//    });
//}


- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didResumeAtOffset:(int64_t)fileOffset expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}

- (void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    float progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self.progressView setProgress:progress];
    });
}
@end
