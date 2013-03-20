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


#define MFDaemonRegisteredName  @"com.lobotomo.MFDaemonRegisteredName"

@protocol MFProtocol

// the temperature threshold settings used to compute the desired/target fan RPMs
- (float)lowerTempThreshold;
- (float)upperTempThreshold;
- (void)setLowerTempThreshold:(float)newLowerTempThreshold;
- (void)setUpperTempThreshold:(float)newUpperTempThreshold;
//
- (BOOL)showTempsAsFahrenheit;
- (void)setShowTempsAsFahrenheit:(BOOL)newShowTempsAsFahrenheit;

// the "base"/slowest/lower-limit fan RPMs
- (int)leftFanBaseRPM;
- (int)rightFanBaseRPM;
- (void)setLeftFanBaseRPM:(int)newLeftFanBaseRPM;
- (void)setRightFanBaseRPM:(int)newRightFanBaseRPM;

// the mode used to apply the temperature sensors to control the fans
- (int)sensorControlMode;
- (void)setSensorControlMode:(int)newSensorControlMode;

// the computed desired/target fan RPMs based upon the pref settings
- (int)leftFanTargetRPM;
- (int)rightFanTargetRPM;

- (void)CPUtemp:(float *)CPUtemp
        GPUtemp:(float *)GPUtemp
        leftFanRPM:(int *)leftFanRPM
        rightFanRPM:(int *)rightFanRPM;

@end
