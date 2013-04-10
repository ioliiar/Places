//
//  TextFieldCell.h
//  Place
//
//  Created by Iurii Oliiar on 4/10/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell
@property (retain, nonatomic) IBOutlet UILabel *whatLabel;
@property (retain, nonatomic) IBOutlet UITextField *valueTextField;

+ (NSString *)reuseIdentifier;

@end
