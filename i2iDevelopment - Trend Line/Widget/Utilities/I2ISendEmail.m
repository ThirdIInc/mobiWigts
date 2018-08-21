//
//  I2ISendEmail.m
//  i2iDevelopment
//
//  Created by Deepika Nahar on 04/02/17.
//  Modified by Pradeep Yadav on 14/03/17.
//  Copyright © 2017 i2iLogic (Australia) Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MicroStrategyMobileSDK/MSIGeneric.h"
#import "I2ISendEmail.h"
#import "RememberRecipient.h"

@implementation I2ISendEmail
@synthesize picker;
@synthesize rootView;
@synthesize transparentRect;
@synthesize hideCancelButton;
@synthesize radioEmail1;
@synthesize radioEmail2;
@synthesize txtTo;
@synthesize txtSubject;
@synthesize txtNote;
@synthesize selectedDomain;
@synthesize inputVC;
@synthesize disclaimer;
@synthesize arrDomains;
@synthesize rememberSwitch;

-(void)openMailComposingWindowWithAttachment:(id)contents
                                   whichType:(NSString *)type
                                    withPath:(NSString *)path
                              withDisclaimer:(NSString *)disclaimerMsg
                                 withDomains:(NSString *)emailDomains
                                 withCompany:(NSString *)company {
    
    disclaimer = disclaimerMsg;
    
    //Show intermediate view
    [self readInputsWithDomains:emailDomains];
    
    picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;
    
    NSDate *todayDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *convertedDateString = [dateFormatter stringFromDate:todayDate];
    
    //[picker setSubject:@"Default Subject???"];
    [picker setSubject:[NSString stringWithFormat:@"%@_%@", company, convertedDateString]];
    
    if ([type isEqualToString:@"Image"]) {
        
        NSData *myData = UIImagePNGRepresentation(contents);
        [picker addAttachmentData:myData
                         mimeType:@"image/png"
                         fileName:@"Image.png"];
        
    }
    else {
        
        [picker addAttachmentData:[NSData dataWithContentsOfFile:contents]
                         mimeType:@""
                         fileName:[path lastPathComponent]];
        
    }
    
    transparentRect = [[UIView alloc] initWithFrame:CGRectMake(0, picker.navigationBar.frame.size.height, picker.view.frame.size.width, picker.view.frame.size.height)];
    transparentRect.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.1];
    
    [picker.view addSubview:transparentRect];
    
    hideCancelButton = [[UIView alloc] initWithFrame:CGRectMake(0, 0, picker.view.frame.size.width / 11, picker.navigationBar.frame.size.height)];
    hideCancelButton.backgroundColor = [UIColor colorWithRed:0.97
                                                       green:0.97
                                                        blue:0.97
                                                       alpha:1];
    
    //add a UIButton to hideCancelButton View mimicking the functionality of Delete draft
    UIButton *btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnCancel addTarget:self
                  action:@selector(discardDraft:)
        forControlEvents:UIControlEventTouchUpInside];
    [btnCancel setTitle:@"Cancel"
               forState:UIControlStateNormal];
    btnCancel.frame = CGRectMake(0, 0, picker.view.frame.size.width / 11, picker.navigationBar.frame.size.height);
    [btnCancel setBackgroundColor:[UIColor colorWithRed:0.97
                                                  green:0.97
                                                   blue:0.97
                                                  alpha:1]];
    [btnCancel setTitleColor:[UIColor colorWithRed:0.08
                                             green:0.52
                                              blue:1.0
                                             alpha:1]
                    forState:UIControlStateNormal];
    [btnCancel.titleLabel setFont:[UIFont boldSystemFontOfSize:[UIFont buttonFontSize]]];
    
    [hideCancelButton addSubview:btnCancel];
    
    [picker.view addSubview:hideCancelButton];
    
}

-(void)readInputsWithDomains:(NSString *)emailDomains {
    
    inputVC = [[UIViewController alloc] init];
    UIView *inputView = [[UIView alloc] init];
    
    inputVC.view = inputView;
    
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 275, [UIScreen mainScreen].bounds.size.height / 2 - 175, 550, 350)];
    [mainView setBackgroundColor:[UIColor whiteColor]];
    mainView.layer.cornerRadius = 13.0;
    [inputView addSubview:mainView];
    
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 275, [UIScreen mainScreen].bounds.size.height / 2 - 175, 550, 40)];
    
    //To apply rounded corners only to topLeft and topRight of naviation bar
    CALayer *capa = navBar.layer;
    CGRect bounds = capa.bounds;
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                   byRoundingCorners:(UIRectCornerTopLeft | UIRectCornerTopRight)
                                                         cornerRadii:CGSizeMake(13.0, 13.0)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = bounds;
    maskLayer.path = maskPath.CGPath;
    
    [capa addSublayer:maskLayer];
    capa.mask = maskLayer;
    
    //To add buttons (Cancel and Next to the navigation bar)
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(cancelClicked:)];
    navItem.leftBarButtonItem = leftButton;
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                                    style:UIBarButtonItemStylePlain
                                                                   target:self
                                                                   action:@selector(showEmailPopover:)];
    navItem.rightBarButtonItem = rightButton;
    
    navBar.items = @[ navItem ];
    
    [inputView addSubview:navBar];
    
    //Label 'To:'
    UILabel *lblTo = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 255, [UIScreen mainScreen].bounds.size.height / 2 - 125, 50, 30)];
    lblTo.text = @"To:";
    lblTo.textColor = [UIColor lightGrayColor];
    [lblTo setFont:[UIFont systemFontOfSize:16]];
    [inputView addSubview:lblTo];
    
    //Textfield for email
    txtTo = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 215, [UIScreen mainScreen].bounds.size.height / 2 - 125, 480, 30)];
    txtTo.delegate = self;
    txtTo.placeholder = @"Enter email";
    txtTo.autocorrectionType = UITextAutocorrectionTypeNo;
    [txtTo setFont:[UIFont systemFontOfSize:16]];
    txtTo.delegate = self;
    [inputView addSubview:txtTo];
    
    //Add a cross button to clear the contents
    UIButton *clearBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    clearBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 90, [UIScreen mainScreen].bounds.size.height / 2 - 120, 20, 20);
    [clearBtn setBackgroundImage:[UIImage imageNamed:@"Cross.png"]
                        forState:UIControlStateNormal];
    
    [clearBtn addTarget:self
                 action:@selector(clearRecipients:)
       forControlEvents:UIControlEventTouchUpInside];
    [inputView addSubview:clearBtn];
    
    //Add a toggle button here for remember me
    rememberSwitch = [[UISwitch alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 + 130, [UIScreen mainScreen].bounds.size.height / 2 - 125, 40, 15)];
    [rememberSwitch addTarget:self
                       action:@selector(changeSwitch:)
             forControlEvents:UIControlEventValueChanged];
    [inputView addSubview:rememberSwitch];
    
    //Label for Remember
    UILabel *lblRemember = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 + 190, [UIScreen mainScreen].bounds.size.height/2 - 125, 80, 30)];
    lblRemember.text = @"Remember";
    lblRemember.textColor = [UIColor lightGrayColor];
    [lblRemember setFont:[UIFont systemFontOfSize:16]];
    [inputView addSubview:lblRemember];
    
    //Seperator line
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 255, [UIScreen mainScreen].bounds.size.height/2 - 95, 380, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [inputView addSubview:lineView];
    
    //Radio buttons to indicate domains
    radioEmail1 = [UIButton buttonWithType:UIButtonTypeCustom];
    radioEmail2 = [UIButton buttonWithType:UIButtonTypeCustom];
    
    arrDomains = [emailDomains componentsSeparatedByString:@","];
    
    radioEmail1.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 255, [UIScreen mainScreen].bounds.size.height / 2 - 85, 30, 30);
    [radioEmail1 setBackgroundImage:[UIImage imageNamed:@"RadioChecked.png"]
                           forState:UIControlStateNormal];
    [radioEmail1 setTag:1];
    [radioEmail1 addTarget:self
                    action:@selector(radiobuttonSelected:)
          forControlEvents:UIControlEventTouchUpInside];
    UILabel *lblEmailDomain1 = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 220, [UIScreen mainScreen].bounds.size.height / 2 - 85, 120, 30)];
    lblEmailDomain1.text = [arrDomains objectAtIndex:0];
    lblEmailDomain1.textColor = [UIColor blackColor];
    lblEmailDomain1.textAlignment = NSTextAlignmentLeft;
    [lblEmailDomain1 setFont:[UIFont systemFontOfSize:14]];
    selectedDomain = lblEmailDomain1.text;
    
    [inputView addSubview:radioEmail1];
    [inputView addSubview:lblEmailDomain1];
    
    radioEmail2.frame = CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 115, [UIScreen mainScreen].bounds.size.height / 2 - 85, 30, 30);
    [radioEmail2 setBackgroundImage:[UIImage imageNamed:@"RadioUncheck.png"]
                           forState:UIControlStateNormal];
    [radioEmail2 setTag:2];
    [radioEmail2 addTarget:self
                    action:@selector(radiobuttonSelected:)
          forControlEvents:UIControlEventTouchUpInside];
    UILabel *lblEmailDomain2 = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 80, [UIScreen mainScreen].bounds.size.height / 2 - 85, 120, 30)];
    lblEmailDomain2.text = [arrDomains objectAtIndex:1];
    lblEmailDomain2.textColor = [UIColor blackColor];
    lblEmailDomain2.textAlignment = NSTextAlignmentLeft;
    [lblEmailDomain2 setFont:[UIFont systemFontOfSize:14]];
    
    [inputView addSubview:radioEmail2];
    [inputView addSubview:lblEmailDomain2];

    //Seperator line
    lineView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 255, [UIScreen mainScreen].bounds.size.height / 2 - 50, 507, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [inputView addSubview:lineView];
    
    //Label 'Subject:'
    UILabel *lblSubject = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 255, [UIScreen mainScreen].bounds.size.height / 2 - 45, 70, 30)];
    lblSubject.text = @"Subject:";
    lblSubject.textColor = [UIColor lightGrayColor];
    [lblSubject setFont:[UIFont systemFontOfSize:16]];
    [inputView addSubview:lblSubject];
    
    //Textfield for email
    txtSubject = [[UITextField alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 180, [UIScreen mainScreen].bounds.size.height / 2 - 45, 480, 30)];
    txtSubject.placeholder = @"Subject";
    txtSubject.autocorrectionType = UITextAutocorrectionTypeNo;
    [txtSubject setFont:[UIFont systemFontOfSize:16]];
    [inputView addSubview:txtSubject];
    
    //Seperator line
    lineView = [[UIView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width / 2 - 255, [UIScreen mainScreen].bounds.size.height / 2 - 10, 507, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [inputView addSubview:lineView];
    
    txtNote = [[UITextView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 255, [UIScreen mainScreen].bounds.size.height / 2 - 5, 480, 150)];
    [txtNote setFont:[UIFont systemFontOfSize:14]];
    [inputView addSubview:txtNote];
    
    //Set the saved values if Remember was clicked
    
    //Check if Remember is 'ON'
    if ([[RememberRecipient sharedGlobalInstance] getAppCheckingCondtion:REMEMBERME]) {
        
        txtTo.text = [NSString stringWithFormat:@"%@", [[RememberRecipient sharedGlobalInstance] getRecipient:RECIPIENT]];
        
        //set the appropriate radio selected
        if ([lblEmailDomain1.text isEqualToString:[[RememberRecipient sharedGlobalInstance] getRecipient:EMAILDOMAIN]]) {
            
            [radioEmail1 setBackgroundImage:[UIImage imageNamed:@"RadioChecked.png"]
                                   forState:UIControlStateNormal];
            [radioEmail2 setBackgroundImage:[UIImage imageNamed:@"RadioUncheck.png"]
                                   forState:UIControlStateNormal];
            selectedDomain = [arrDomains objectAtIndex:0];
            
        }
        else {
            
            [radioEmail2 setBackgroundImage:[UIImage imageNamed:@"RadioChecked.png"]
                                   forState:UIControlStateNormal];
            [radioEmail1 setBackgroundImage:[UIImage imageNamed:@"RadioUncheck.png"]
                                   forState:UIControlStateNormal];
            selectedDomain = [arrDomains objectAtIndex:1];
            
        }
        
        //Set remember toggle to 'ON'
        rememberSwitch.on = YES;
    }
    
    rootView = [[UIApplication sharedApplication].delegate window].rootViewController;
    [[UIApplication sharedApplication].delegate window].rootViewController = self;
    [self presentViewController:inputVC animated:YES completion:nil];
    
}

-(void)radiobuttonSelected:(id)sender {
    
    switch ([sender tag]) {
            
        case 1:
            selectedDomain = [arrDomains objectAtIndex:0];
            [radioEmail1 setBackgroundImage:[UIImage imageNamed:@"RadioChecked.png"]
                                   forState:UIControlStateNormal];
            [radioEmail2 setBackgroundImage:[UIImage imageNamed:@"RadioUncheck.png"]
                                   forState:UIControlStateNormal];
            break;
            
        case 2:
            selectedDomain = [arrDomains objectAtIndex:1];
            [radioEmail2 setBackgroundImage:[UIImage imageNamed:@"RadioChecked.png"]
                                   forState:UIControlStateNormal];
            [radioEmail1 setBackgroundImage:[UIImage imageNamed:@"RadioUncheck.png"]
                                   forState:UIControlStateNormal];
            break;
            
        default:
            break;
            
    }
    
}

-(void)showEmailPopover:(id)sender {
    
    //Check if Remember is ON -> Save to NSUserDefaults
    if ([[RememberRecipient sharedGlobalInstance] getAppCheckingCondtion:REMEMBERME]) {
        
        //Save the recipients in NSUserDefaults
        [[RememberRecipient sharedGlobalInstance] saveRecipient:txtTo.text
                                                        withKey:RECIPIENT];
        [[RememberRecipient sharedGlobalInstance] saveRecipient:selectedDomain
                                                        withKey:EMAILDOMAIN];
        
    }
    
    //Validations for Textfield and Radio buttons
    if (![txtTo hasText]) {
        
        //show alert
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                       message:@"Please enter email id."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:nil];
        [alert addAction:ok];
        [inputVC presentViewController:alert
                              animated:YES
                            completion:nil];
        
    }
    else {
        
        //Check if it is valid using RegEx
        NSString *emailRegex = @"[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        if (![emailTest evaluateWithObject:txtTo.text]) {
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Alert"
                                                                           message:@"Please enter a valid email id."
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                         style:UIAlertActionStyleDefault
                                                       handler:nil];
            [alert addAction:ok];
            [inputVC presentViewController:alert
                                  animated:YES
                                completion:nil];
            
        }
        else {
            
            //Read the text field and radio button values to set the to field and subject
            [picker setToRecipients:@[[NSString stringWithFormat:@"%@%@",txtTo.text,selectedDomain]]];
            
            if ([txtNote hasText]) {
                
                /*NSMutableAttributedString *body = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n%@",txtNote.text,disclaimer]];
                [body addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:13.0] range:NSMakeRange(0, txtNote.text.length-1)];
                
                [body addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:11.0] range:NSMakeRange(txtNote.text.length,disclaimer.length)];
                [body addAttribute:NSForegroundColorAttributeName value:[UIColor lightGrayColor] range:NSMakeRange(txtNote.text.length,disclaimer.length)];
                 */
                
                NSString *emailBody = [NSString stringWithFormat:@"%@\n%@", txtNote.text, disclaimer];
                [picker setMessageBody:emailBody
                                isHTML:YES];
                
            }
            else [picker setMessageBody:disclaimer
                                 isHTML:YES];
            
            [self dismissViewControllerAnimated:YES
                                     completion:nil];
            [self presentViewController:picker
                               animated:YES
                             completion:nil];
            
        }
        
    }
    
    if ([txtSubject hasText]) [picker setSubject:txtSubject.text];

}

-(void)clearRecipients:(id)sender {
    
    txtTo.text = @"";
    
}

-(void)cancelClicked:(id)sender {
    
    //Reset NSUserDefaults
    [[RememberRecipient sharedGlobalInstance] saveAppCheckingCondition:NO
                                                               withKey:REMEMBERME];
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [[UIApplication sharedApplication].delegate window].rootViewController = rootView;
    
}

//-(void) discardDraft:(id)sender {
-(void)discardDraft:(UIButton *)sender {
    
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [[UIApplication sharedApplication].delegate window].rootViewController = rootView;
    
}

-(void)changeSwitch:(id)sender {
    
    if ([sender isOn]) [[RememberRecipient sharedGlobalInstance] saveAppCheckingCondition:YES
                                                                                  withKey:REMEMBERME];
    else [[RememberRecipient sharedGlobalInstance] saveAppCheckingCondition:NO
                                                                    withKey:REMEMBERME];
    
}

#pragma mark - MFMailComposeViewController delegate
-(void)mailComposeController:(MFMailComposeViewController *)controller
         didFinishWithResult:(MFMailComposeResult)result
                       error:(NSError *)error {
    
    switch (result) {
            
        case MFMailComposeResultCancelled: break;
            
        case MFMailComposeResultSaved: break;
            
        case MFMailComposeResultSent: break;
            
        case MFMailComposeResultFailed: NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
            
        default:
            break;
            
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES
                             completion:nil];
    [[UIApplication sharedApplication].delegate window].rootViewController = rootView;
    
}

#pragma mark - UITextField delegate
-(void)textFieldDidBeginEditing:(UITextField *)textField {
    
    rememberSwitch.on = NO;
    [[RememberRecipient sharedGlobalInstance] saveAppCheckingCondition:NO
                                                               withKey:REMEMBERME];
    
}

@end
