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

#import "MFDaemon.h"
#import "MFDefinitions.h"
#import "MFProtocol.h"
#import "smc.h"

#define MFApplicationIdentifier     "com.lobotomo.mbFanControl"


@implementation MFDaemon

- (id)init
{
    if (self = [super init]) {
        mustSavePrefs = NO;

        // set some sane defaults
        lowerTempThreshold = MFLowerTempThresholdBottom;
        upperTempThreshold = MFUpperTempThresholdTop;
        //
        leftFanBaseRPM = MFMinLeftFanRPM;
        rightFanBaseRPM = MFMinRightFanRPM;
        //
        leftFanTargetRPM = MFMinLeftFanRPM;
        rightFanTargetRPM = MFMinRightFanRPM;
        //
        sensorControlMode = 0;
    }
    return self;
}

// save the preferences
- (void)storePreferences
{
    CFPreferencesSetValue(CFSTR("leftFanBaseRPM"), (CFPropertyListRef)[NSNumber numberWithInt:leftFanBaseRPM],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFPreferencesSetValue(CFSTR("rightFanBaseRPM"), (CFPropertyListRef)[NSNumber numberWithInt:rightFanBaseRPM],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

    CFPreferencesSetValue(CFSTR("lowerTempThreshold"), (CFPropertyListRef)[NSNumber numberWithFloat:lowerTempThreshold],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    CFPreferencesSetValue(CFSTR("upperTempThreshold"), (CFPropertyListRef)[NSNumber numberWithFloat:upperTempThreshold],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

    CFPreferencesSetValue(CFSTR("sensorControlMode"), (CFPropertyListRef)[NSNumber numberWithInt:sensorControlMode],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

    CFPreferencesSetValue(CFSTR("showTempsAsFahrenheit"), (CFPropertyListRef)[NSNumber numberWithBool:showTempsAsFahrenheit],
                          CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);

    CFPreferencesSynchronize(CFSTR(MFApplicationIdentifier), kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
}

// retrieve the preferences
- (void)readPreferences
{
    CFPropertyListRef property;

    property = CFPreferencesCopyValue(CFSTR("lowerTempThreshold"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) lowerTempThreshold = [(NSNumber *)property floatValue];

    property = CFPreferencesCopyValue(CFSTR("upperTempThreshold"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) upperTempThreshold = [(NSNumber *)property floatValue];

    property = CFPreferencesCopyValue(CFSTR("leftFanBaseRPM"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) leftFanBaseRPM = [(NSNumber *)property intValue];

    property = CFPreferencesCopyValue(CFSTR("rightFanBaseRPM"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) rightFanBaseRPM = [(NSNumber *)property intValue];

    property = CFPreferencesCopyValue(CFSTR("sensorControlMode"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) sensorControlMode = [(NSNumber *)property intValue];

    property = CFPreferencesCopyValue(CFSTR("showTempsAsFahrenheit"), CFSTR(MFApplicationIdentifier),
               kCFPreferencesAnyUser, kCFPreferencesCurrentHost);
    if (property) showTempsAsFahrenheit = [(NSNumber *)property boolValue];

    // sanity/safety check in case of corrupted preferences
    if (lowerTempThreshold < MFLowerTempThresholdBottom) lowerTempThreshold = MFLowerTempThresholdBottom;
    if (upperTempThreshold < MFUpperTempThresholdBottom) upperTempThreshold = MFUpperTempThresholdBottom;
    //
    if (lowerTempThreshold > MFLowerTempThresholdTop) lowerTempThreshold = MFLowerTempThresholdBottom + ((MFLowerTempThresholdTop - MFLowerTempThresholdBottom) / 2);
    if (upperTempThreshold > MFUpperTempThresholdTop) upperTempThreshold = MFUpperTempThresholdBottom + ((MFUpperTempThresholdTop - MFUpperTempThresholdBottom) / 2);
    //
    if (leftFanBaseRPM < MFMinLeftFanRPM) leftFanBaseRPM = MFMinLeftFanRPM;
    if (rightFanBaseRPM < MFMinRightFanRPM) rightFanBaseRPM = MFMinRightFanRPM;
    //
    if (leftFanBaseRPM > MFMaxLeftFanRPM) leftFanBaseRPM = MFMinLeftFanRPM + ((MFMaxLeftFanRPM - MFMinLeftFanRPM) / 2);
    if (rightFanBaseRPM > MFMaxRightFanRPM) rightFanBaseRPM = MFMinRightFanRPM + ((MFMaxRightFanRPM - MFMinRightFanRPM) / 2);
    //
    if (leftFanTargetRPM < MFMinLeftFanRPM) leftFanTargetRPM = MFMinLeftFanRPM;
    if (rightFanTargetRPM < MFMinRightFanRPM) rightFanTargetRPM = MFMinRightFanRPM;
    //
    if (leftFanTargetRPM > MFMaxLeftFanRPM) leftFanTargetRPM = MFMinLeftFanRPM + ((MFMaxLeftFanRPM - MFMinLeftFanRPM) / 2);
    if (rightFanTargetRPM > MFMaxRightFanRPM) rightFanTargetRPM = MFMinRightFanRPM + ((MFMaxRightFanRPM - MFMinRightFanRPM) / 2);
    //
    if ((sensorControlMode < 0) || (sensorControlMode > 2)) sensorControlMode = 0;
}

// this gets called when the application starts
- (void)start
{
    [self readPreferences];
    [NSTimer scheduledTimerWithTimeInterval:MFUpdateInterval target:self selector:@selector(timer:) userInfo:nil repeats:YES];
}

// control loop called by NSTimer at the specified interval
- (void)timer:(NSTimer *)aTimer
{
    double CPUtemp;
    double GPUtemp;

    double leftControlTemp;
    double rightControlTemp;

    int leftFanRPM;
    int rightFanRPM;

    int adjustmentRPM;
    int alignmentRPM;

    SMCOpen();

    leftFanRPM = SMCGetFanRPM(SMC_KEY_LEFT_FAN_RPM);
    rightFanRPM = SMCGetFanRPM(SMC_KEY_RIGHT_FAN_RPM);

    CPUtemp = SMCGetTemperature(SMC_KEY_CPU_TEMP);
    GPUtemp = SMCGetTemperature(SMC_KEY_GPU_TEMP);

    // set the "controlling sensor" temperatures that will drive the fan speeds
    leftControlTemp = CPUtemp;
    rightControlTemp = CPUtemp;
    if (sensorControlMode == GPU_TEMP_CONTROLS_BOTH_FANS) leftControlTemp = GPUtemp;
    if ((sensorControlMode == GPU_TEMP_CONTROLS_BOTH_FANS) ||
        (sensorControlMode == CPU_TEMP_CONTROLS_LEFT_FAN_AND_GPU_TEMP_CONTROLS_RIGHT_FAN))
            rightControlTemp = GPUtemp;
    if (MFDebugLeft || MFDebugRight) NSLog (@"CPUtemp = %f\n", CPUtemp);
    if (MFDebugLeft || MFDebugRight) NSLog (@"GPUtemp = %f\n\n", GPUtemp);


    // ----- compute the desired/target left fan speed

    // determine the desired/target RPM indicated by the preference settings
    if (leftControlTemp < lowerTempThreshold) {
        leftFanTargetRPM = leftFanBaseRPM;
    } else if (leftControlTemp > upperTempThreshold) {
        leftFanTargetRPM = MFMaxLeftFanRPM;
    } else {
        leftFanTargetRPM = leftFanBaseRPM +
                           ((floor(leftControlTemp + 0.5) - lowerTempThreshold) /
                           (upperTempThreshold - lowerTempThreshold) *
                           (MFMaxLeftFanRPM - leftFanBaseRPM));
    }
    if (MFDebugLeft) NSLog (@"leftControlTemp = %f\n", leftControlTemp);
    if (MFDebugLeft) NSLog (@"rounded leftControlTemp = %f\n", floor(leftControlTemp + 0.5));
    if (MFDebugLeft) NSLog (@"ideal leftFanTargetRPM = %d\n", leftFanTargetRPM);
    if (MFDebugLeft) NSLog (@"leftFanRPM = %d\n", leftFanRPM);

    // correct the fan speed if we don't have a fan-speed value/reading from smc
    if (leftFanRPM == 0) {
        leftFanRPM = leftFanTargetRPM;
        if (MFDebugLeft) NSLog (@"corrected leftFanRPM = %d\n", leftFanRPM);
    } /*else { // pretend fan speed is aligned to nearest MFRPMspeedStep boundary
        alignmentRPM = (leftFanRPM % MFRPMspeedStep);
        leftFanRPM = leftFanRPM - alignmentRPM;
        if (alignmentRPM > (MFRPMspeedStep / 2)) leftFanRPM = leftFanRPM + MFRPMspeedStep;
        if (MFDebugLeft) NSLog (@"aligned leftFanRPM = %d\n", leftFanRPM);
    } */

    // determine difference between fan's desired/target RPM and the current RPM
    adjustmentRPM = (leftFanTargetRPM - leftFanRPM);
    if (abs(adjustmentRPM) < (MFRPMspeedStep / 2)) {
        adjustmentRPM = 0; // current speed's within 1/2 of an RPM step, leave it
    } else { // ensure the +/- difference is not greater than the maximum allowed
        if (adjustmentRPM < -MFMaxRPMspeedStep) adjustmentRPM = -MFMaxRPMspeedStep;
        if (adjustmentRPM > MFMaxRPMspeedStep) adjustmentRPM = MFMaxRPMspeedStep;
    }
    if (MFDebugLeft) NSLog (@"adjustmentRPM = %d\n", adjustmentRPM);

    // compute the new desired/target RPM
    leftFanTargetRPM = leftFanRPM + adjustmentRPM;
    if (MFDebugLeft) NSLog (@"next leftFanTargetRPM = %d\n", leftFanTargetRPM);

    // set the desired/target RPM to the nearest MFRPMspeedStep-RPM boundary
    alignmentRPM = (leftFanTargetRPM % MFRPMspeedStep);
    leftFanTargetRPM = leftFanTargetRPM - alignmentRPM;
    if (alignmentRPM > (MFRPMspeedStep / 2)) leftFanTargetRPM = leftFanTargetRPM + MFRPMspeedStep;
    if (MFDebugLeft) NSLog (@"%d RPM-aligned next leftFanTargetRPM = %d\n", MFRPMspeedStep, leftFanTargetRPM);

    // when decreasing speed, don't target below the set "slowest fan speed" and
    // when increasing speeds, don't target above the maximum safe fan speed
    if (MFDebugLeft) NSLog (@"leftFanBaseRPM = %d\n", leftFanBaseRPM);
    if ((adjustmentRPM < 1) && (leftFanTargetRPM < leftFanBaseRPM)) leftFanTargetRPM = leftFanBaseRPM;
    if (leftFanTargetRPM > MFMaxLeftFanRPM) leftFanTargetRPM = MFMaxLeftFanRPM;
    if (MFDebugLeft) NSLog (@"final next leftFanTargetRPM = %d\n\n", leftFanTargetRPM);


    // ----- compute the desired/target right fan speed

    // determine the desired/target RPM indicated by the preference settings
    if (rightControlTemp < lowerTempThreshold) {
        rightFanTargetRPM = rightFanBaseRPM;
    } else if (rightControlTemp > upperTempThreshold) {
        rightFanTargetRPM = MFMaxRightFanRPM;
    } else {
        rightFanTargetRPM = rightFanBaseRPM +
                           ((floor(rightControlTemp + 0.5) - lowerTempThreshold) /
                           (upperTempThreshold - lowerTempThreshold) *
                           (MFMaxRightFanRPM - rightFanBaseRPM));
    }
    if (MFDebugRight) NSLog (@"rightControlTemp = %f\n", rightControlTemp);
    if (MFDebugRight) NSLog (@"rounded rightControlTemp = %f\n", floor(rightControlTemp + 0.5));
    if (MFDebugRight) NSLog (@"ideal rightFanTargetRPM = %d\n", rightFanTargetRPM);
    if (MFDebugRight) NSLog (@"rightFanRPM = %d\n", rightFanRPM);

    // correct the fan speed if we don't have a fan-speed value/reading from smc
    if (rightFanRPM == 0) {
        rightFanRPM = rightFanTargetRPM;
        if (MFDebugRight) NSLog (@"corrected rightFanRPM = %d\n", rightFanRPM);
    } /*else { // pretend fan speed is aligned to nearest MFRPMspeedStep boundary
        alignmentRPM = (rightFanRPM % MFRPMspeedStep);
        rightFanRPM = rightFanRPM - alignmentRPM;
        if (alignmentRPM > (MFRPMspeedStep / 2)) rightFanRPM = rightFanRPM + MFRPMspeedStep;
        if (MFDebugRight) NSLog (@"aligned rightFanRPM = %d\n", rightFanRPM);
    } */

    // determine difference between fan's desired/target RPM and the current RPM
    adjustmentRPM = (rightFanTargetRPM - rightFanRPM);
    if (abs(adjustmentRPM) < (MFRPMspeedStep / 2)) {
        adjustmentRPM = 0; // current speed's within 1/2 of an RPM step, leave it
    } else { // ensure the +/- difference is not greater than the maximum
        if (adjustmentRPM < -MFMaxRPMspeedStep) adjustmentRPM = -MFMaxRPMspeedStep;
        if (adjustmentRPM > MFMaxRPMspeedStep) adjustmentRPM = MFMaxRPMspeedStep;
    }
    if (MFDebugRight) NSLog (@"adjustmentRPM = %d\n", adjustmentRPM);

    // compute the new desired/target RPM
    rightFanTargetRPM = rightFanRPM + adjustmentRPM;
    if (MFDebugRight) NSLog (@"next rightFanTargetRPM = %d\n", rightFanTargetRPM);

    // set the desired/target RPM to the nearest MFRPMspeedStep-RPM boundary
    alignmentRPM = (rightFanTargetRPM % MFRPMspeedStep);
    rightFanTargetRPM = rightFanTargetRPM - alignmentRPM;
    if (alignmentRPM > (MFRPMspeedStep / 2)) rightFanTargetRPM = rightFanTargetRPM + MFRPMspeedStep;
    if (MFDebugRight) NSLog (@"%d RPM-aligned next rightFanTargetRPM = %d\n", MFRPMspeedStep, rightFanTargetRPM);

    // when decreasing speed, don't target below the set "slowest fan speed" and
    // when increasing speeds, don't target above the maximum safe fan speed
    if (MFDebugRight) NSLog (@"rightFanBaseRPM = %d\n", rightFanBaseRPM);
    if ((adjustmentRPM < 1) && (rightFanTargetRPM < rightFanBaseRPM)) rightFanTargetRPM = rightFanBaseRPM;
    if (rightFanTargetRPM > MFMaxRightFanRPM) rightFanTargetRPM = MFMaxRightFanRPM;
    if (MFDebugRight) NSLog (@"final next rightFanTargetRPM = %d\n\n", rightFanTargetRPM);


    // request the "target" fan speeds
    SMCSetFanRPM(SMC_KEY_LEFT_FAN_RPM_MIN, leftFanTargetRPM);
    SMCSetFanRPM(SMC_KEY_RIGHT_FAN_RPM_MIN, rightFanTargetRPM);

    SMCClose();

    // save preferences, if required
    if (mustSavePrefs) {
        [self storePreferences];
        mustSavePrefs = NO;
    }
}

// accessors & setters
// -----------------------------------------------------------------------------
- (float)lowerTempThreshold
{
    return lowerTempThreshold;
}
- (float)upperTempThreshold
{
    return upperTempThreshold;
}
//
- (void)setLowerTempThreshold:(float)newLowerTempThreshold
{
    lowerTempThreshold = newLowerTempThreshold;
    mustSavePrefs = YES;
}
- (void)setUpperTempThreshold:(float)newUpperTempThreshold
{
    upperTempThreshold = newUpperTempThreshold;
    mustSavePrefs = YES;
}
// -------------------------------------
- (BOOL)showTempsAsFahrenheit
{
    return showTempsAsFahrenheit;
}
- (void)setShowTempsAsFahrenheit:(BOOL)newShowTempsAsFahrenheit
{
    showTempsAsFahrenheit = newShowTempsAsFahrenheit;
    mustSavePrefs = YES;
}
// -----------------------------------------------------------------------------
- (int)leftFanBaseRPM
{
    return leftFanBaseRPM;
}
- (int)rightFanBaseRPM
{
    return rightFanBaseRPM;
}
//
- (void)setLeftFanBaseRPM:(int)newLeftFanBaseRPM
{
    leftFanBaseRPM = newLeftFanBaseRPM;
    mustSavePrefs = YES;

    if ((sensorControlMode == CPU_TEMP_CONTROLS_BOTH_FANS) ||
        (sensorControlMode == GPU_TEMP_CONTROLS_BOTH_FANS))
            rightFanBaseRPM = newLeftFanBaseRPM;
}
- (void)setRightFanBaseRPM:(int)newRightFanBaseRPM
{
    rightFanBaseRPM = newRightFanBaseRPM;
    mustSavePrefs = YES;

    if ((sensorControlMode == CPU_TEMP_CONTROLS_BOTH_FANS) ||
        (sensorControlMode == GPU_TEMP_CONTROLS_BOTH_FANS))
            leftFanBaseRPM = newRightFanBaseRPM;
}
// -----------------------------------------------------------------------------
- (int)sensorControlMode
{
    return sensorControlMode;
}
- (void)setSensorControlMode:(int)newSensorControlMode
{
    sensorControlMode = newSensorControlMode;
    mustSavePrefs = YES;
}
// -----------------------------------------------------------------------------
- (int)leftFanTargetRPM
{
    return leftFanTargetRPM;
}
- (int)rightFanTargetRPM
{
    return rightFanTargetRPM;
}
// -----------------------------------------------------------------------------
- (void)CPUtemp:(float *)CPUtemp
        GPUtemp:(float *)GPUtemp
        leftFanRPM:(int *)leftFanRPM
        rightFanRPM:(int *)rightFanRPM
{
    SMCOpen();
    if (CPUtemp) *CPUtemp = SMCGetTemperature(SMC_KEY_CPU_TEMP);
    if (GPUtemp) *GPUtemp = SMCGetTemperature(SMC_KEY_GPU_TEMP);
    if (leftFanRPM) *leftFanRPM = SMCGetFanRPM(SMC_KEY_LEFT_FAN_RPM);
    if (rightFanRPM) *rightFanRPM = SMCGetFanRPM(SMC_KEY_RIGHT_FAN_RPM);
    SMCClose();
}

@end
