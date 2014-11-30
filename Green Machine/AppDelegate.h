//
//  AppDelegate.h
//  Green Machine
//
//  Created by Eyal Shpits on 5/29/14.
//  Copyright (c) 2014 GreenShpits. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, SKPaymentTransactionObserver>

@property (strong, nonatomic) UIWindow *window;

@end
