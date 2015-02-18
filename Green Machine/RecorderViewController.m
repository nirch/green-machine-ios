//

//  ViewController.m
//  Green Machine
//
//  Created by Eyal Shpits on 5/29/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import "RecorderViewController.h"
#import "DataBackground.h"
#import "GADInterstitial.h"
#import "Localytics.h"

@interface RecorderViewController ()
@property(nonatomic, strong) GADInterstitial *interstitial;
@end

@implementation RecorderViewController

-(IBAction) createMoviePressed:(id)sender {
    [Localytics tagEvent:@"CreateMovie pressed"];
    if ([self.interstitial isReady]) {
        [self.interstitial presentFromRootViewController:self];
        
        self.interstitial = [[GADInterstitial alloc] init];
        self.interstitial.adUnitID = @"ca-app-pub-3237461980709919/1152155383";
        GADRequest *request = [GADRequest request];
        // Requests test ads on simulators.
        request.testDevices = @[ GAD_SIMULATOR_ID ];
        [self.interstitial loadRequest:request];
    }
    
    [UIView animateWithDuration:0.5 animations:^{
        viewDone.alpha = 0.0;
        [writerView.videoProcessor saveMovieToCameraRoll];
    }];
}
    
-(IBAction) retakeMoviePressed:(id)sender {
    [Localytics tagEvent:@"Retake pressed"];
    [UIView animateWithDuration:0.5 animations:^{
        viewDone.alpha = 0.0;
        [self readyPressed:nil];
    }];
}

-(void) doneRecording {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"doneRecording" object:nil];
     [UIView animateWithDuration:0.5 animations:^{
         buttonToggleMenu.hidden = false;
         buttonToggleCamera.hidden = false;
         labelSeconds.text = @"";
        imageViewBackground.alpha = 1.0;
        buttonRecord.alpha = 1.0;
        buttonReady.alpha = 1.0;
        viewDone.alpha = 1.0;
    }];
}
-(void) cancelRecordingPressed {
    buttonToggleMenu.hidden = false;
    buttonToggleCamera.hidden = false;
    imageViewBackground.alpha = 1.0;
    [writerView.videoProcessor stopRecording];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"doneRecording" object:nil];
    buttonReady.alpha = 1.0;
    [cancelRecordingButton removeFromSuperview];
    cancelRecordingButton = nil;
}
-(IBAction)readyPressed:(UIButton *)sender {
    buttonToggleCamera.hidden = true;
    if ( nil == cancelRecordingButton ) {
        cancelRecordingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelRecordingButton setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
        [cancelRecordingButton setTitle:@"  Cancel efect" forState:UIControlStateNormal];
        [cancelRecordingButton addTarget:self action:@selector(cancelRecordingPressed) forControlEvents:UIControlEventTouchUpInside];
        cancelRecordingButton.center = self.view.center;
        cancelRecordingButton.frame = CGRectMake(5, self.view.frame.size.height-50, 200, 30 );
        [self.view addSubview:cancelRecordingButton];
    }
    DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
    if ( background.isLocked.boolValue ) {
        [alertLockedBackground show];
        return;
    }

    imageViewBackground.alpha = 0.0;
    
    if ( ![[Data shared] objectForKey:@"UnlimitedTime"] ) {
        writerView.seconds = [NSNumber numberWithInt:10];
        writerView.secondsLabel = labelSeconds;
    }
    [writerView initGreenMachine];
    sender.alpha = 0.0;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doneRecording) name:@"doneRecording" object:nil];
}

-(void ) viewWillAppear:(BOOL)animated {
    [UIViewController attemptRotationToDeviceOrientation];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.interstitial = [[GADInterstitial alloc] init];
    self.interstitial.adUnitID = @"ca-app-pub-3237461980709919/1152155383";
    GADRequest *request = [GADRequest request];
    // Requests test ads on simulators.
    request.testDevices = @[ GAD_SIMULATOR_ID ];
    [self.interstitial loadRequest:request];
    
    controllerBuyCredit = [[BuyCreditsViewController alloc]initWithNibName:@"BuyCreditsViewController" bundle:nil];


    self.navigationController.navigationBarHidden = true;
    data = [Data shared];
    [buttonBuyCredit setTitle:[NSString stringWithFormat:@"%@", [data objectForKey:@"credits"]] forState:UIControlStateNormal];
    data.currentFormat = [NSNumber numberWithInt:1];
    menuIsOpened = false;
    viewDone.alpha = 0.0;
    [self updateBackgroundImage];

    alertUseCredits = [[UIAlertView alloc]initWithTitle:@"Using credits" message:@"You may purchase this background using your existing credits" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Use Credits", nil];
    alertBuyCredits = [[UIAlertView alloc]initWithTitle:@"Purchase credits" message:@"You need to get more credits" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Get Credits", nil];

    alertLockedBackground = [[UIAlertView alloc]initWithTitle:@"Locked background" message:@"This background is still locked. would you like to get it?" delegate:self cancelButtonTitle:@"Skip" otherButtonTitles:@"Get it", nil];
    
    viewInstructionsPortraight.alpha = viewInstructionsLandscape.alpha = 0.0;
    
    NSString * skippedFirstTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"skippedFirstTime"];
    if ( !skippedFirstTime ) {
        [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"skippedFirstTime"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        viewInstructionsLandscape.alpha = 1.0;
        else
        viewInstructionsPortraight.alpha = 1.0;
    }
    
    
    writerView = [[RosyWriterViewController alloc]initWithNibName:@"RosyWriterViewController" bundle:nil];
    writerView.view.frame = [UIScreen mainScreen].bounds;
    if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        writerView.view.frame = CGRectMake(0,0, [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);

    [self.view insertSubview:writerView.view atIndex:0];
}

- (void) updateBackgroundImage {
    if ( data.currentBackground ) {
        DataBackground * background = [data.backgrounds objectAtIndex:data.currentBackground.intValue];
        if ( background.isLocked.boolValue ) {
            labelBackgroundCost.text = [NSString stringWithFormat:@"%@", background.cost];
            [self fadeIn:viewLocked];
            [self fadeIn:viewLock];
        }
        else {
            [self fadeOut:viewLocked];
            [self fadeOut:viewLock];
        }
    }
    else {
        [self fadeOut:viewLocked];
        [self fadeOut:viewLock];        
    }

    NSString * format = [data.formats objectAtIndex:data.currentFormat.intValue];
    int index = 0;
    if ( data.currentBackground )
        index = [data.currentBackground intValue];
    NSString * name = [NSString stringWithFormat:format, index+1];
    
//    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
//    if (UIDeviceOrientationIsLandscape(deviceOrientation))
        name = [name stringByReplacingOccurrencesOfString:@"port" withString:@"land"];

    UIImage * image = [UIImage imageNamed:name];
    if ( image )
        imageViewBackground.image = [UIImage imageNamed:name];
    else {
        ;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)leftPressed:(id)sender {
    if ( data.currentBackground.intValue > 0) data.currentBackground = [NSNumber numberWithInt:data.currentBackground.intValue-1];
    else data.currentBackground = [NSNumber numberWithInt:21];
    [self updateBackgroundImage];
}
-(IBAction)rightPressed:(id)sender {
    if ( data.currentBackground.intValue < 21 ) data.currentBackground = [NSNumber numberWithInt:data.currentBackground.intValue+1];
    else data.currentBackground = [NSNumber numberWithInt:0];
    [self updateBackgroundImage];
}

-(IBAction)upPressed:(id)sender {
    if ( data.currentFormat.intValue < 4) data.currentFormat = [NSNumber numberWithInt:data.currentFormat.intValue+1];
    else data.currentFormat = [NSNumber numberWithInt:0];
    [self updateBackgroundImage];

}
-(IBAction)closeInstructionsPressed:(id)sender {
    [UIView animateWithDuration:0.3 animations:^{
        viewInstructionsLandscape.alpha = 0.0;
        viewInstructionsPortraight.alpha = 0.0;
    } completion:nil];
}


-(void) refreshMovies {
    movies =  [[[[[Data shared] objectForKey:@"movies"] reverseObjectEnumerator] allObjects] mutableCopy];
    
    if ( ! movies )
        movies = [[NSMutableArray alloc]init];
    if ( ([[scrollerMovies subviews] count]/3) != [movies count] ) {
        for ( UIView * view in [scrollerMovies subviews] ) {
            [view removeFromSuperview];
        }
        
        int x = 30;
        int index=0;
        for ( NSDictionary * movie in movies ) {
            NSData * dataImage = [movie objectForKey:@"image"];
            bool usingFrontCamera = [[movie objectForKey:@"usingFrontCamera"] boolValue];
            UIImage * imageLoaded = [UIImage imageWithData:dataImage];
            UIImage * image;
            if (usingFrontCamera)
                image = [UIImage imageWithCGImage:imageLoaded.CGImage scale:imageLoaded.scale orientation:UIImageOrientationDown];
            else
                image = [UIImage imageWithCGImage:imageLoaded.CGImage scale:imageLoaded.scale orientation:UIImageOrientationUp];

            UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
            int width = 200;
            int height = (int) ( 200.0 / image.size.width * image.size.height);
            button.frame = CGRectMake(x, 30, width, height);
            
            button.layer.shadowColor = [UIColor whiteColor].CGColor;
            button.layer.shadowOpacity = 0.5;
            button.layer.shadowRadius = 10;
            button.layer.shadowOffset = CGSizeMake(3.0f,3.0f);
            
            button.backgroundColor = [UIColor whiteColor];
            button.layer.cornerRadius = 5.0;
            [button setImage:image  forState:UIControlStateNormal];
            [button addTarget:self action:@selector(playMovie:) forControlEvents:UIControlEventTouchUpInside];
            [scrollerMovies addSubview:button];
            
            UIButton * deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [deleteButton setImage:[UIImage imageNamed:@"remove"] forState:UIControlStateNormal];
            [deleteButton addTarget:self action:@selector(removePressed:) forControlEvents:UIControlEventTouchUpInside];
            deleteButton.frame = CGRectMake ( x+width-25, 5, 50, 50 );
            [scrollerMovies addSubview:deleteButton];

            UIButton * shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
            [shareButton addTarget:self action:@selector(sharePressed:) forControlEvents:UIControlEventTouchUpInside];
            shareButton.frame = CGRectMake ( x-25, 5, 50, 50 );
            [scrollerMovies addSubview:shareButton];

            
            x+= ( width  + 50 );
            button.tag = index++;
        }
        scrollerMovies.contentSize = CGSizeMake ( x, scrollerMovies.frame.size.height ) ;
        
    }
}
-(IBAction)menuTogglePressed:(UIButton *)sender {
    CGRect frame = [sender superview].frame;
    if ( menuIsOpened ) {
        buttonReady.hidden = buttonRecord.hidden = false;
        writerView.view.alpha = 1.0;
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
        buttonReady.hidden = buttonRecord.hidden = true;
        menuIsOpened = true;
        writerView.view.alpha = 0.0;
        [self refreshMovies];
        
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
    [self.view addSubview:controllerBuyCredit.view];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if ( buttonIndex == 0 ) return;
    if ( alertView == alertLockedBackground ) {
        [self buyBackgroundPressed:nil];
    }
    else if ( alertView == alertBuyCredits ) {
        [self.view addSubview:controllerBuyCredit.view];
    }
    else if ( alertView == alertUseCredits ) {
        DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
        background.isLocked = [NSNumber numberWithBool:false];
        [data setObject:[NSNumber numberWithInt:[[data objectForKey:@"credits"] intValue] - background.cost.intValue] forKey:@"credits"];
        [data synchronize];
        [buttonBuyCredit setTitle:[NSString stringWithFormat:@"%@", [data objectForKey:@"credits"]] forState:UIControlStateNormal];
        if ( background.isLocked.boolValue ) {
            [self fadeIn:viewLocked];
            [self fadeIn:viewLock];
        }
        else {
            [self fadeOut:viewLocked];
            [self fadeOut:viewLock];
        }
    }
    else {
        // Remove movie
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
        NSString * path = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [NSString stringWithFormat:@"Movie%d.mp4", (int)selectedMovie]];
        
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:path]) {
            NSError *error;
            [fileManager removeItemAtPath:path error:&error];
        }

        NSDictionary * movie = [movies objectAtIndex:selectedMovie];
        [movies removeObject:movie];
        [[Data shared] setObject:movies forKey:@"movies"];
        [[Data shared] synchronize];
        

        
        [self refreshMovies];
    }
}

-(IBAction)buyBackgroundPressed:(id)sender {
    
    int credits = [[[Data shared] objectForKey:@"credits"] intValue];
    DataBackground * background = [[data backgrounds] objectAtIndex:data.currentBackground.intValue];
    int cost = background.cost.intValue;

    NSDictionary *dictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSString stringWithFormat:@"%d", credits],
     @"Current Credits",
     [NSString stringWithFormat:@"%d", data.currentBackground.intValue],
     @"Current Background Index",
     [NSString stringWithFormat:@"%d", cost],
     @"Cost",
     nil];
    [Localytics tagEvent:@"BuyBackground pressed" attributes:dictionary];

    if ( credits >= cost )
        [alertUseCredits show];
    else
        [alertBuyCredits show];
}

-(IBAction)beginRecordPressed:(id)sender {
    buttonToggleMenu.hidden = true;
    NSDictionary *dictionary =
    [NSDictionary dictionaryWithObjectsAndKeys:
     [NSString stringWithFormat:@"%d",(int)data.currentFormat.intValue],
     @"Background id",
     ([Data shared].usingFrontCamera) ? @"Front camera" : @"Back camera",
     @"Cemra used",
     nil];
    if ( writerView.videoProcessor.recording )
        [Localytics tagEvent:@"End Record" attributes:dictionary];
    else
        [Localytics tagEvent:@"Begin Record" attributes:dictionary];

    [cancelRecordingButton removeFromSuperview];
    cancelRecordingButton = nil;

    writerView.recordButton = sender;
    [writerView toggleRecording:sender];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return scrollerMovies;
}
/*
- (void)orientationChanged:(NSNotification *)notification
{
    UIDeviceOrientation deviceOrientation = [UIDevice currentDevice].orientation;
    if (UIDeviceOrientationIsLandscape(deviceOrientation))
    {
        viewInstructionsPortraight.alpha = 0.0;
        viewInstructionsLandscape.alpha = 1.0;
    }
    else
    {
        viewInstructionsPortraight.alpha = 1.0;
        viewInstructionsLandscape.alpha = 0.0;
    }
    [self updateBackgroundImage];
}
*/

-(IBAction)toggleCameraPressed:(id)sender {
    [Data shared].usingFrontCamera = ![Data shared].usingFrontCamera;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"toggleCamera" object:nil];
}

-(IBAction)helpPressed:(id)sender {
    if ( [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
        viewInstructionsLandscape.alpha = 1.0;
    else
        viewInstructionsPortraight.alpha = 1.0;    
}

-(void)playMovieFinished:(NSNotification*)aNotification
{
    [Data shared].playingMovie = false;
    [UIViewController attemptRotationToDeviceOrientation];
    MPMoviePlayerController* player=[aNotification object];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:MPMoviePlayerPlaybackDidFinishNotification
                                                  object:player];
}


-(IBAction)playMovie:(UIButton *)sender {
    [Localytics tagEvent:@"PlayMovie pressed"];
    selectedMovie = sender.tag;
    // The path for the video
    NSDictionary * movie = [movies objectAtIndex:selectedMovie];
    NSString * path = [movie objectForKey:@"file"];
    NSURL * movieURL = [NSURL fileURLWithPath:path isDirectory:false];
    [Data shared].playingMovie = true;
    MPMoviePlayerViewController * player = [[MPMoviePlayerViewController alloc]initWithContentURL:movieURL];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playMovieFinished:)
                                                 name:MPMoviePlayerPlaybackDidFinishNotification
                                               object:[player moviePlayer]];
    [self presentMoviePlayerViewControllerAnimated:player];
}

-(IBAction)appReferelPressed:(id)sender {
    [Localytics tagEvent:@"AppReferal pressed"];
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:@"You have to see this app."];
    [sharingItems addObject:[NSURL URLWithString:@"https://itunes.apple.com/us/app/green-machine-everywhere/id934141102?ls=1&mt=8"]];
    
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [activityController setValue:@"A great app called Green Machine" forKey:@"subject"];
    
    if (  NSClassFromString(@"UIPopoverPresentationController")   ) {
        activityController.popoverPresentationController.sourceView = sender;
    }
    [self presentViewController:activityController animated:false completion:nil];    
}
-(IBAction) sharePressed:(UIButton *)sender {
    [Localytics tagEvent:@"Share pressed"];
    
    NSMutableArray *sharingItems = [NSMutableArray new];
    [sharingItems addObject:@"My latest creation, Using GreenMachine "];
    [sharingItems addObject:[NSURL URLWithString:@"https://itunes.apple.com/us/app/green-machine-everywhere/id934141102?ls=1&mt=8"]];
    
    selectedMovie = sender.tag;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    NSURL * movieURL = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", documentsDirectory, [NSString stringWithFormat:@"Movie%d.mp4", (int)selectedMovie]] isDirectory:false];
    [sharingItems addObject:movieURL];
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:sharingItems applicationActivities:nil];
    [activityController setValue:@"A movie I created with Green Machine" forKey:@"subject"];
    
    if (  NSClassFromString(@"UIPopoverPresentationController")   ) {
        activityController.popoverPresentationController.sourceView = sender;
    }
    [self presentViewController:activityController animated:false completion:nil];
}
-(IBAction)removePressed:(UIButton *)sender {
    selectedMovie = sender.tag;
    [[[UIAlertView alloc]initWithTitle:@"Delete this movie?" message:@"Do you want to delete this movie? You can not undo this action" delegate:self cancelButtonTitle:@"Keep" otherButtonTitles:@"Delete", nil]show ];
}
@end
