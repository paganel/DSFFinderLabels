//
//  DSFFinderLabelsTests_objc.m
//  DSFFinderLabelsTests_objc
//
//  Created by Darren Ford on 8/2/19.
//  Copyright © 2019 Darren Ford. All rights reserved.
//

#import <XCTest/XCTest.h>

#import <DSFFinderLabels/DSFFinderLabels.h>

@interface DSFFinderLabelsTests_objc : XCTestCase

@end

@interface DSFTempFile: NSObject

@property (nonatomic, strong) NSURL* fileURL;

@end

@implementation DSFTempFile

- (id)init
{
	self = [super init];
	if (self != nil)
	{
		[self setup];
	}
	return self;
}

- (void)setup
{
	NSString* tempDir = NSTemporaryDirectory();
	NSString* filename = [[[NSUUID alloc] init] UUIDString];
	[self setFileURL:[NSURL fileURLWithPathComponents:@[tempDir, filename]]];
}

- (id)initWithDummyContent
{
	self = [super init];
	if (self != nil)
	{
		[self setup];
		NSString* content = @"This is dummy content";
		if ([content writeToURL:[self fileURL] atomically:NO encoding:NSUTF8StringEncoding error:nil] == NO)
		{
			return nil;
		}
	}
	return self;
}

- (void)dealloc
{
	[[NSFileManager defaultManager] removeItemAtURL:[self fileURL] error:nil];
}

@end

@implementation DSFFinderLabelsTests_objc

- (void)setUp {
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testGetAndUpdate {
	DSFTempFile* file = [[DSFTempFile alloc] initWithDummyContent];
	XCTAssertNotNil(file);

	DSFFinderLabels* labels = [file.fileURL finderLabels];
	XCTAssertNotNil(labels);
	XCTAssertEqual(0, [[labels getTags] count]);
	XCTAssertEqual(0, [[labels getColorValues] count]);

	// Add labels and colors
	[labels addTagWithTag:@"Work Related"];
	NSError* error = nil;

	NSSet<NSNumber*>* colors = [NSSet setWithObjects:@(DSFFinderLabelsColorIndexRed), @(DSFFinderLabelsColorIndexBlue), nil];
	[labels setColorsValuesWithColorValues:colors error:&error];
	[labels addColorWithIndex:DSFFinderLabelsColorIndexBlue];
	XCTAssertNil(error);

	[[file fileURL] setFinderLabelsWithFinderLabels:labels error:&error];
	XCTAssertNil(error);

	DSFFinderLabels* updated = [file.fileURL finderLabels];
	XCTAssertNotNil(updated);
	NSSet<NSString*>* tags = [updated getTags];
	XCTAssertEqual(1, [tags count]);
	XCTAssertTrue([tags containsObject:@"Work Related"]);

	NSSet<NSNumber*>* colorValues = [updated getColorValues];
	XCTAssertEqual(2, [colorValues count]);
	XCTAssertTrue([colorValues containsObject:@(DSFFinderLabelsColorIndexRed)]);
	XCTAssertTrue([colorValues containsObject:@(DSFFinderLabelsColorIndexBlue)]);
}

@end
