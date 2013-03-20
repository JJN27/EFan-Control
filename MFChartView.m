//
// Fan Control
// Copyright 2006 Lobotomo Software
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//

#import "MFChartView.h"
#import "MFDefinitions.h"

// definitions depending on view size and labels - adjust when changing graph view
#define MFPixelPerDegree  2.4857 // <width in pixels (174)> / (MFGraphMaxTemp - MFGraphMinTemp)
#define MFPixelPerRPM     0.028846 // <height in pixels (150)> / (MFGraphMaxRPM - MFGraphMinRPM)
#define MFGraphMinTemp    25.0
#define MFGraphMaxTemp    95.0
#define MFGraphMinRPM     900
#define MFGraphMaxRPM     6100


@implementation MFChartView

- (id)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame]) {
        // Initialization code here.
    }
    return self;
}

- (NSPoint)pointOnGraphWithTemp:(float)theTemp andRPM:(int)theRPM
{
    NSPoint coordinate = [self bounds].origin;
    coordinate.x += roundf((theTemp - MFGraphMinTemp) * MFPixelPerDegree);
    coordinate.y += roundf((theRPM - MFGraphMinRPM) * MFPixelPerRPM);
    return coordinate;
}

- (void)drawRect:(NSRect)rect
{
    // draw background and border
    [[NSColor whiteColor] set];
    NSRectFill([self bounds]);
    [[NSColor blackColor] set];
    NSBezierPath *path = [NSBezierPath bezierPathWithRect:[self bounds]];
    [path stroke];

    // draw left fan control-path graph
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:leftFanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:lowerTempThreshold andRPM:leftFanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:upperTempThreshold andRPM:MFMaxLeftFanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:MFMaxLeftFanRPM]];
    [path setLineWidth:2.0];
    [path stroke];

    // draw right fan control-path graph
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:rightFanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:lowerTempThreshold andRPM:rightFanBaseRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:upperTempThreshold andRPM:MFMaxRightFanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:MFMaxRightFanRPM]];
    [path setLineWidth:2.0];
    [path stroke];

    // draw left fan temperature line
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:leftControlTemp andRPM:MFGraphMinRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:leftControlTemp andRPM:MFGraphMaxRPM]];
    [path stroke];

    // draw right fan temperature line
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:rightControlTemp andRPM:MFGraphMinRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:rightControlTemp andRPM:MFGraphMaxRPM]];
    [path stroke];

    // draw target left fan's desired/target RPM O-indicator
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:
              [self pointOnGraphWithTemp:leftControlTemp andRPM:leftFanTargetRPM]
          radius:3.0 startAngle:0.0 endAngle:360.0];
    [path setLineWidth:2.0];
    [path stroke];

    // draw target right fan's desired/target RPM O-indicator
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path appendBezierPathWithArcWithCenter:
              [self pointOnGraphWithTemp:rightControlTemp andRPM:rightFanTargetRPM]
          radius:3.0 startAngle:0.0 endAngle:360.0];
    [path setLineWidth:2.0];
    [path stroke];

    // draw target left fan's current RPM line
    [[NSColor colorWithDeviceRed:0.625 green:0.0 blue:0.0 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:leftFanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:leftFanRPM]];
    [path stroke];

    // draw target right fan's current RPM line
    [[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.625 alpha:1.0] set];
    path = [NSBezierPath bezierPath];
    [path moveToPoint:[self pointOnGraphWithTemp:MFGraphMinTemp andRPM:rightFanRPM]];
    [path lineToPoint:[self pointOnGraphWithTemp:MFGraphMaxTemp andRPM:rightFanRPM]];
    [path stroke];
}

// setters
// -----------------------------------------------------------------------------
- (void)setLowerTempThreshold:(float)newLowerTempThreshold
{
    lowerTempThreshold = newLowerTempThreshold;
    [self setNeedsDisplay:YES];
}
- (void)setUpperTempThreshold:(float)newUpperTempThreshold
{
    upperTempThreshold = newUpperTempThreshold;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setLeftFanBaseRPM:(int)newLeftFanBaseRPM
{
    leftFanBaseRPM = newLeftFanBaseRPM;
    [self setNeedsDisplay:YES];
}
- (void)setRightFanBaseRPM:(int)newRightFanBaseRPM
{
    rightFanBaseRPM = newRightFanBaseRPM;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setLeftFanTargetRPM:(int)newLeftFanTargetRPM
{
    leftFanTargetRPM = newLeftFanTargetRPM;
    [self setNeedsDisplay:YES];
}
- (void)setRightFanTargetRPM:(int)newRightFanTargetRPM
{
    rightFanTargetRPM = newRightFanTargetRPM;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setLeftFanRPM:(int)newLeftFanRPM
{
    leftFanRPM = newLeftFanRPM;
    [self setNeedsDisplay:YES];
}
- (void)setRightFanRPM:(int)newRightFanRPM
{
    rightFanRPM = newRightFanRPM;
    [self setNeedsDisplay:YES];
}
// -----------------------------------------------------------------------------
- (void)setLeftControlTemp:(float)newLeftControlTemp
{
    leftControlTemp = newLeftControlTemp;
    [self setNeedsDisplay:YES];
}
- (void)setRightControlTemp:(float)newRightControlTemp
{
    rightControlTemp = newRightControlTemp;
    [self setNeedsDisplay:YES];
}

@end
