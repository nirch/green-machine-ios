//
//  BuyPicksViewController.h
//  King of the Riff
//
//  Created by Eyal Shpits on 2/3/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface BuyCreditsViewController : UIViewController <SKProductsRequestDelegate>
{
    
    NSArray *productIdentifiers ;
    IBOutlet UIImageView * imageviewThanks;
    NSArray * products;
    
    IBOutlet UIButton * buttonBuy1;
    IBOutlet UIButton * buttonBuy2;
    IBOutlet UIButton * buttonBuy3;
    IBOutlet UIButton * buttonBuy4;
    
    IBOutlet UILabel *  labelBuy1;
    IBOutlet UILabel *  labelBuy2;
    IBOutlet UILabel *  labelBuy3;
    IBOutlet UILabel *  labelBuy4;
}
-(IBAction) back:(id)sender;
- (IBAction)buy:(UIButton *)sender;
@end
