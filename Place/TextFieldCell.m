//
//  TextFieldCell.m
//  Place
//
//  Created by Iurii Oliiar on 4/10/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "TextFieldCell.h"

@implementation TextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [_whatLabel release];
    [_valueTextField release];
    [super dealloc];
}

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

@end
