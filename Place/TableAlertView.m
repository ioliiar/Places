/******************************************************************************
 * Copyright (c) 2010, Maher Ali <maher.ali@gmail.com>
 * Advanced iOS 4 Programming: Developing Mobile Applications for Apple iPhone, iPad, and iPod touch
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included
 * in all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 ******************************************************************************/

#import "TableAlertView.h"
#import "PlaceEntity.h"

#define MAX_VISIBLE_ROWS 5

@implementation TableAlertView

@synthesize  caller, context, data;

-(id)initWithCaller:(id<TableAlertViewDelegate>)_caller data:(NSArray*)_data 
                    title:(NSString*)_title andContext:(id)_context{
  tableHeight = 0;
  NSMutableString *msgString = [NSMutableString string];
  if([_data count] >= MAX_VISIBLE_ROWS){
    tableHeight = 225;
    [msgString appendString: @"\n\n\n\n\n\n\n\n\n\n"];
  }
  else{
    tableHeight = [_data count]*50;
    for(id value in _data){
      [msgString appendString:@"\n\n"];
    }
    if([_data count] == 1){
      tableHeight +=5;
    }
    if([_data count] == MAX_VISIBLE_ROWS-1){
      tableHeight -=15;
    }
  }
  if(self = [super initWithTitle:_title message:msgString 
                   delegate:self cancelButtonTitle:@"Cancel" 
                   otherButtonTitles:nil]){
    self.caller = _caller;
    self.context = _context;
    self.data = _data;
    [self prepare];
  }
  return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
  [self.caller didSelectRowAtIndex:-1 withContext:self.context];
}

-(void)show{
  self.hidden = YES;
  [NSTimer scheduledTimerWithTimeInterval:.5 target:self 
           selector:@selector(myTimer:) userInfo:nil repeats:NO];
  [super show];
}

-(void)myTimer:(NSTimer*)_timer{
  self.hidden = NO;
  if([data count] > MAX_VISIBLE_ROWS){
    [myTableView flashScrollIndicators];
  }
}

-(void)prepare{
  myTableView = [[UITableView alloc] initWithFrame:CGRectMake(15, 35, 255, tableHeight) 
                                     style:UITableViewStyleGrouped];
  myTableView.backgroundColor = [UIColor clearColor];
  if([data count] < MAX_VISIBLE_ROWS){
    myTableView.scrollEnabled = NO;
  }
  myTableView.delegate = self;
  myTableView.dataSource = self;
  [self addSubview:myTableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView 
                     cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString  *cellID = @"ABC";
  UITableViewCell *cell = 
    (UITableViewCell*) [tableView dequeueReusableCellWithIdentifier:cellID];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                     reuseIdentifier:cellID] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
  }
  cell.textLabel.text =((PlaceEntity *)[data objectAtIndex:indexPath.row]).name;
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [self dismissWithClickedButtonIndex:0 animated:YES];
  [self.caller didSelectRowAtIndex:indexPath.row withContext:self.context];
}

- (NSInteger)tableView:(UITableView *)tableView 
             numberOfRowsInSection:(NSInteger)section {
	return [data count];
}

-(void)dealloc{
  self.data = nil;
  self.caller = nil;
  self.context = nil;
  [myTableView release];
  [super dealloc];
}

@end
