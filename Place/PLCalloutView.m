//


#import "PLCalloutView.h"


@implementation PLCalloutView
@synthesize mainTitleLabel, leftLabel, rightLabel;

- (void)dealloc
{
    [mainTitleLabel release];
    [leftLabel release];
    [rightLabel release];
    [super dealloc];
}

- (id)initWithAnnotation:(id<MKAnnotation>)annotation
{
    if(!(self = [super initWithAnnotation:annotation reuseIdentifier:@"PLCalloutView"]))
        return nil;
    
    [[NSBundle mainBundle] loadNibNamed:@"PLCalloutView" owner:self options:nil];
    
    return self;
}

@end
