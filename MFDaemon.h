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
#import "MFProtocol.h"


@interface MFDaemon : NSObject <MFProtocol> {

    // the temperature threshold settings used to compute the desired/target fan RPMs
    float lowerTempThreshold;
    float upperTempThreshold;
    //
    BOOL showTempsAsFahrenheit;

    // the "base"/slowest/lower-limit fan RPMs
    int leftFanBaseRPM;
    int rightFanBaseRPM;

    // the mode used to apply the temperature sensors to control the fans
    // (see MFDefinitions.h)
    int sensorControlMode;

    // the computed desired/target fan RPMs based upon the pref settings
    int leftFanTargetRPM;
    int rightFanTargetRPM;

    BOOL mustSavePrefs;
}

- (void)start;

@end
