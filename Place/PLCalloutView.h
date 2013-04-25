
#import <Foundation/Foundation.h>
#import "CalloutAnnotationView.h"

@interface PLCalloutView : CalloutAnnotationView {
    
}

@property (nonatomic, retain) IBOutlet UILabel* mainTitleLabel;
@property (nonatomic, retain) IBOutlet UILabel* leftLabel;
@property (nonatomic, retain) IBOutlet UILabel* rightLabel;


@end
