//
//  DoneViewController.h
//  Green Machine
//
//  Created by Eyal Shpits on 8/19/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DoneViewController : UIViewController
{
    IBOutlet UIImageView * bg;
}

-(IBAction) retakePressed:(id)sender;
-(IBAction) previewPressed:(id)sender;
@end
