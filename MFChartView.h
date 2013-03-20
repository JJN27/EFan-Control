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

#import <Cocoa/Cocoa.h>


@interface MFChartView : NSView {

    // the temperature threshold settings used to compute the desired/target fan RPMs
    float lowerTempThreshold;
    float upperTempThreshold;

    // the "base"/slowest/lower-limit fan RPMs
    int leftFanBaseRPM;
    int rightFanBaseRPM;

    // the computed desired/target fan RPMs based upon the pref settings
    int leftFanTargetRPM;
    int rightFanTargetRPM;

    // the current fan speeds
    int leftFanRPM;
    int rightFanRPM;

    // the current sensor temperatures
    float leftControlTemp;
    float rightControlTemp;
}

// setters

- (void)setLowerTempThreshold:(float)newLowerTempThreshold;
- (void)setUpperTempThreshold:(float)newUpperTempThreshold;

- (void)setLeftFanBaseRPM:(int)newLeftFanBaseRPM;
- (void)setRightFanBaseRPM:(int)newRightFanBaseRPM;

- (void)setLeftFanTargetRPM:(int)newLeftFanTargetRPM;
- (void)setRightFanTargetRPM:(int)newRightFanTargetRPM;

- (void)setLeftFanRPM:(int)newLeftFanRPM;
- (void)setRightFanRPM:(int)newRightFanRPM;

- (void)setLeftControlTemp:(float)newLeftControlTemp;
- (void)setRightControlTemp:(float)newRightControlTemp;

@end
