//

//  ViewController.m
//  Green Machine
//
//  Created by Eyal Shpits on 5/29/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "RecorderViewController.h"
#import "DataBackground.h"

@interface RecorderViewController ()

@end

@implementation RecorderViewController


-(IBAction)readyPressed:(id)sender {
    // Hide siluevte
//    [self.view bringSubviewToFront:writerView.view];
    imageViewBackground.alpha = 0.0;
    
    [writerView initGreenMachine];
    [sender removeFromSuperview];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    useFrontCamera = true;
    controllerBuyCredit = [[BuyCreditsViewController alloc]initWithNibName:@"BuyCreditsViewController" bundle:nil];


    self.navigationController.navigationBarHidden = true;
    data = [Data shared];
    [buttonBuyCredit setTitle:[NSString stringWithFormat:@"%@", data.credits] forState:UIControlStateNormal];
    bgNameIndex = 1;
    menuIsOpened = false;
    [self updateBackgroundImage];

    alertUseCredits = [[UIAlertView alloc]initWithTitle:@"Using credits" message:@"You may purchase this background using your existing credits" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Use Credits", nil];
    alertBuyCredits = [[UIAlertView alloc]initWithTitle:@"Purchase credits" message:@"You need to get more credits" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Get Credits", nil];

    alertLockedBackground = [[UIAlertView alloc]initWithTitle:@"Locked background" message:@"This background is still locked. would you like to get it?" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Get it", nil];
    
    viewInstructionsPortraight.alpha = viewInstructionsLandscape.alpha = 0.0;
    
    if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        viewInstructionsLandscape.alpha = 1.0;
    else
        viewInstructionsPortraight.alpha = 1.0;
    
    
    writerView = [[RosyWriterViewController alloc]initWithNibName:@"RosyWriterViewController" bundle:nil];
    writerView.view.frame = [UIScreen mainScreen].bounds;
    if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        writerView.view.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);

    [self.view insertSubview:writerView.view atIndex:0];

    
    // Hide siluevte
//    [self.view bringSubviewToFront:writerView.view];

    
//    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                             selector:@selector(orientationChanged:)
//                                                 name:UIDeviceOrientationDidChangeNotification
//                                               object:nil];
//    [self orientationChanged:nil];


}

- (void) updateBackgroundImage {
    DataBackground * background = [data.backgrounds objectAtIndex:data.currentBackground.intValue];
    if ( background.isLocked.boolValue ) {
        [self fadeIn:viewLocked];
        [self fadeIn:viewLock];
    }
    else {
        [self fadeOut:viewLocked];
        [self fadeOut:viewLock];
    }

    NSString * format = [data.formats objectAtIndex:bgNameIndex];
    NSString * name = [NSString stringWithFormat:format, data.currentBackground.intValue+1];
    
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        name = [name stringByReplacingOccurrencesOfString:@"port" withString:@"land"];

        
    imageViewBackground.image = [UIImage imageNamed:name];
    if ( !background.isLocked.boolValue ) {
        labelBackgroundCost.text = [NSString stringWithFormat:@"%@", background.cost];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)leftPressed:(id)sender {
    if ( data.currentBackground.intValue > 0) data.currentBackground = [NSNumber numberWithInt:data.currentBackground.intValue-1];
    else data.currentBackground = [NSNumber numberWithInt:22];
    [self updateBackgroundImage];
}
-(IBAction)rightPressed:(id)sender {
    if ( data.currentBackground.intValue < 22 ) data.currentBackground = [NSNumber numberWithInt:data.currentBackground.intValue+1];
    else data.currentBackground = [NSNumber numberWithInt:0];
    [self updateBackgroundImage];
}

-(IBAction)upPressed:(id)sender {
    if ( bgNameIndex < 4) bgNameIndex++;
    else bgNameIndex = 0;
    [self updateBackgroundImage];

}
-(IBAction)closeInstructionsPressed:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        viewInstructionsLandscape.alpha = 0.0;
        viewInstructionsPortraight.alpha = 0.0;
    } completion:^(BOOL finished) {
        [viewInstructionsLandscape removeFromSuperview];
        [viewInstructionsPortraight removeFromSuperview];
    }];
}

-(IBAction)menuTogglePressed:(UIButton *)sender {
    CGRect frame = [sender superview].frame;
    if ( menuIsOpened ) {
        [self fadeOut:bgResolutions];
        [self fadeOut:viewLocked];
        menuIsOpened = false;
        [UIView animateWithDuration:0.3 animations:^{
            [sender superview].frame = CGRectMake ( frame.origin.x, frame.origin.y+200, frame.size.width, frame.size.height-200 );
            secondsView.alpha = 1.0;
        } completion:^(BOOL finished) {
            [sender setImage:[UIImage imageNamed:@"menuOpen"] forState:UIControlStateNormal];
        }];
    }
    else {
        menuIsOpened = true;
        [UIView animateWithDuration:0.3 animations:^{
            secondsView.alpha = 0.0;
            [sender superview].frame = CGRectMake ( frame.origin.x, frame.origin.y-200, frame.size.width, frame.size.height+200 );
        } completion:^(BOOL finished) {
            [sender setImage:[UIImage imageNamed:@"menuClose"] forState:UIControlStateNormal];
        }];
    }
}

-(void) fadeOut:(UIView *) view {
    [UIView animateWithDuration:0.1 animations:^{
        view.alpha = 0.0;
    } completion:^(BOOL finished) {
        ;
    }];
}
-(void) fadeIn:(UIView *) view {
    [UIView animateWithDuration:0.1 animations:^{
        view.alpha = 1.0;
    } completion:^(BOOL finished) {
        ;
    }];
}
-(IBAction) buycreditPressed:(id)sender {
    [self fadeOut:bgResolutions];
    
    [self.view addSubview:controllerBuyCredit.view];
//    [self fadeIn:bgBuyCredit];
}
-(IBAction) upgradePressed:(id)sender {
    [self fadeOut:bgResolutions];
    
    [[[UIAlertView alloc]initWithTitle:@"Upgrade Not implemented yet" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}
-(IBAction)resolution360Pressed:(UIButton * )sender {
    sender.selected = !sender.selected;
    [(UIButton *)[bgResolutions viewWithTag:720] setSelected:false];
    data.resolution = [NSNumber numberWithInt:360];
}
-(IBAction)resolution720Pressed:(UIButton *)sender {
    sender.selected = !sender.selected;
    [(UIButton *)[bgResolutions viewWithTag:360] setSelected:false];
    data.resolution = [NSNumber numberWithInt:720];
}
-(IBAction) resolutionPressed:(id)sender {
    int resolution = data.resolution.intValue; 
    [(UIButton *)[bgResolutions viewWithTag:resolution] setSelected:true];
    
    [self fadeIn:bgResolutions];
//    [self fadeOut:bgBuyCredit];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) return;
    if ( alertView == alertLockedBackground ) {
        [self buyBackgroundPressed:nil];
    }
    if ( alertView == alertBuyCredits ) {
        [self.view addSubview:controllerBuyCredit.view];
//        [self presentViewController:controller animated:YES completion:nil];
    }
    if ( alertView == alertUseCredits ) {
        DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
        background.isLocked = [NSNumber numberWithBool:false];
        data.credits = [NSNumber numberWithInt:data.credits.intValue - background.cost.intValue];
        [buttonBuyCredit setTitle:[NSString stringWithFormat:@"%@", data.credits] forState:UIControlStateNormal];
        if ( background.isLocked.boolValue ) {
            [self fadeIn:viewLocked];
            [self fadeIn:viewLock];
        }
        else {
            [self fadeOut:viewLocked];
            [self fadeOut:viewLock];
        }
    }
}

-(IBAction)buyBackgroundPressed:(id)sender {
    int credits = [data credits].intValue;
    DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
    int cost = background.cost.intValue;
    
    if ( credits >= cost )
        [alertUseCredits show];
    else
        [alertBuyCredits show];
}

-(IBAction)beginRecordPressed:(id)sender {
    DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
    if ( background.isLocked.boolValue ) {
        [alertLockedBackground show];
        return;
    }
    writerView.recordButton = sender;
//    [self performSegueWithIdentifier:@"record" sender:self];
    [writerView toggleRecording:sender];
    
//    [[[UIAlertView alloc]initWithTitle:@"Not yet" message:@"We will be able to record only after the preview looks OK" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollerMovies;
}


//- (void)orientationChanged:(NSNotification *)notification
//{
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation))
//    {
//        viewInstructionsPortraight.alpha = 0.0;
//        viewInstructionsLandscape.alpha = 1.0;
//    }
//    else
//    {
//        viewInstructionsPortraight.alpha = 1.0;
//        viewInstructionsLandscape.alpha = 0.0;
//    }
//    [self updateBackgroundImage];
//    if ( deviceOrientation == UIDeviceOrientationPortrait)
//        [self.view sendSubviewToBack:writerView.view];
//    if ( deviceOrientation == UIDeviceOrientationPortraitUpsideDown)
//        [self.view bringSubviewToFront:writerView.view];
//}


-(IBAction)toggleCameraPressed:(id)sender {
    useFrontCamera = !useFrontCamera;
}



@end
