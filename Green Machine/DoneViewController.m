//
//  DoneViewController.m
//  Green Machine
//
//  Created by Eyal Shpits on 8/19/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "DoneViewController.h"
#import "Data.h"
#import "DataBackground.h"
#import "Localytics.h"
@interface DoneViewController ()

@end

@implementation DoneViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = true;
    Data * data = [Data shared];
    NSString * format;
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        format = @"LANDSCAPE %d";
    else
        format = @"PORTRAIT %d";

    NSString * name = [NSString stringWithFormat:format, data.currentBackground.intValue+1];
    bg.image = [UIImage imageNamed:name];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) retakePressed:(id)sender {
    [Localytics tagEvent:@"Retake Pressed"];
    
    [self.navigationController popToRootViewControllerAnimated:true];
}

-(IBAction) previewPressed:(id)sender {
    [Localytics tagEvent:@"Preview Pressed"];
    [[[UIAlertView alloc]initWithTitle:@"See preview Not implemented yet" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
