//
//  TwoLabelCell.m
//  Place
//
//  Created by Iurii Oliiar on 4/11/13.
//  Copyright (c) 2013 Iurii Oliiar. All rights reserved.
//

#import "TwoLabelCell.h"

@implementation TwoLabelCell

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
    [_dateLabel release];
    [super dealloc];
}
@end
