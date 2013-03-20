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
#import "MFPreferencePane.h"
#import "MFProtocol.h"
#import "MFTemperatureTransformer.h"


@implementation MFPreferencePane


- (id)initWithBundle:(NSBundle *)bundle
{
    if (self = [super initWithBundle:bundle]) {
        transformer = [MFTemperatureTransformer new];
        [NSValueTransformer setValueTransformer:transformer forName:@"MFTemperatureTransformer"];
    }
    return self;
}

- (void)dealloc
{
    [transformer release];
    [super dealloc];
}

// update the preference-pane display
- (void)updateDisplay:(NSTimer *)aTimer
{
    int leftFanRPM;
    int rightFanRPM;
    int sensorCntrlMode;

    float CPUtemp;
    float GPUtemp;
    float leftControlTemp;
    float rightControlTemp;

    int leftFanTargetRPM = [daemon leftFanTargetRPM];
    int rightFanTargetRPM = [daemon rightFanTargetRPM];

    [daemon CPUtemp:&CPUtemp GPUtemp:&GPUtemp leftFanRPM:&leftFanRPM rightFanRPM:&rightFanRPM];

    // set the "controlling sensor" temperatures that are driving the fan speeds
    sensorCntrlMode = [daemon sensorControlMode];
    leftControlTemp = CPUtemp;
    rightControlTemp = CPUtemp;
    if (sensorCntrlMode == GPU_TEMP_CONTROLS_BOTH_FANS) leftControlTemp = GPUtemp;
    if ((sensorCntrlMode == GPU_TEMP_CONTROLS_BOTH_FANS) ||
        (sensorCntrlMode == CPU_TEMP_CONTROLS_LEFT_FAN_AND_GPU_TEMP_CONTROLS_RIGHT_FAN))
            rightControlTemp = GPUtemp;

    // update the textual fields
    [leftFanRPMfield setIntValue:leftFanRPM];
    [rightFanRPMfield setIntValue:rightFanRPM];

    [leftFanTargetRPMfield setIntValue:leftFanTargetRPM];
    [rightFanTargetRPMfield setIntValue:rightFanTargetRPM];

    [CPUtempField setStringValue:[transformer transformedValue:[NSNumber numberWithFloat:CPUtemp]]];
    [GPUtempField setStringValue:[transformer transformedValue:[NSNumber numberWithFloat:GPUtemp]]];

    // update the radio-button group
    [sensorControlMode selectCellAtRow:sensorCntrlMode column:0];

    // update the graph/chart
    [chartView setLowerTempThreshold:[daemon lowerTempThreshold]];
    [chartView setUpperTempThreshold:[daemon upperTempThreshold]];
    //
    [chartView setLeftFanBaseRPM:[daemon leftFanBaseRPM]];
    [chartView setRightFanBaseRPM:[daemon rightFanBaseRPM]];
    //
    [chartView setLeftFanTargetRPM:leftFanTargetRPM];
    [chartView setRightFanTargetRPM:rightFanTargetRPM];
    //
    [chartView setLeftFanRPM:leftFanRPM];
    [chartView setRightFanRPM:rightFanRPM];
    //
    [chartView setLeftControlTemp:leftControlTemp];
    [chartView setRightControlTemp:rightControlTemp];
}

- (void)awakeFromNib
{
    // connect to daemon
    NSConnection *connection =
        [NSConnection connectionWithRegisteredName:MFDaemonRegisteredName host:nil];
    daemon = [[connection rootProxy] retain];
    [(id)daemon setProtocolForProxy:@protocol(MFProtocol)];

    // set transformer mode
    [transformer setShowTempAsFahrenheit:[daemon showTempsAsFahrenheit]];

    // connect to object controller
    [fileOwnerController setContent:self];
}

// message sent before preference pane is displayed (starts udpate the timer)
- (void)willSelect
{
    // update display immediately, then every MFUpdateInterval seconds
    [self updateDisplay:nil];
    timer = [NSTimer scheduledTimerWithTimeInterval:MFUpdateInterval
                     target:self selector:@selector(updateDisplay:)
                     userInfo:nil repeats:YES];
}

// message sent after preference pane is ordered out
- (void)didUnselect
{
    // stop updates
    [timer invalidate];
    timer = nil;
}

// handles radio-button action
- (IBAction)radioButtonClicked:(id)sender
{
    int sensorCntrlMode = [sensorControlMode selectedRow];
    int theLeftFanBaseRPM = [daemon leftFanBaseRPM];
    int theRightFanBaseRPM = [daemon rightFanBaseRPM];

    if (MFDebugPrefs) NSLog (@"sensorCntrlMode = %d\n", sensorCntrlMode);
    if (MFDebugPrefs) NSLog (@"theLeftFanBaseRPM = %d\n", theLeftFanBaseRPM);
    if (MFDebugPrefs) NSLog (@"theRightFanBaseRPM = %d\n\n", theRightFanBaseRPM);

    [daemon setSensorControlMode:sensorCntrlMode];

    // if changing to control both fans via the CPU temp,
    // set the right-fan slider to the current left-fan slider's setting
    if (sensorCntrlMode == CPU_TEMP_CONTROLS_BOTH_FANS) {
        [rightFanBaseRPMslider setFloatValue:(float)theLeftFanBaseRPM];
        [self setRightFanBaseRPM:theLeftFanBaseRPM];
    }

    // if changing to control both fans via the GPU temp,
    // set the left-fan slider to the current right-fan slider's setting
    if (sensorCntrlMode == GPU_TEMP_CONTROLS_BOTH_FANS) {
        [leftFanBaseRPMslider setFloatValue:(float)theRightFanBaseRPM];
        [self setLeftFanBaseRPM:theRightFanBaseRPM];
    }

    [self updateDisplay:nil];
}

// handles fans-speed slider action
- (IBAction)leftFanBaseRPMslide:(id)sender
{
    int sensorCntrlMode = [sensorControlMode selectedRow];
    float sliderValue = [sender floatValue];

    if (MFDebugPrefs) NSLog (@"left sensorCntrlMode = %d\n", sensorCntrlMode);
    if (MFDebugPrefs) NSLog (@"left sliderValue = %f\n\n", sliderValue);

    [self setLeftFanBaseRPM:(int)sliderValue];

    // if one temp controls both fans,
    // set the right-fan slider to the current left-fan slider's setting
    if ((sensorCntrlMode == CPU_TEMP_CONTROLS_BOTH_FANS) ||
        (sensorCntrlMode == GPU_TEMP_CONTROLS_BOTH_FANS)) {
        [rightFanBaseRPMslider setFloatValue:sliderValue];
        [self setRightFanBaseRPM:(int)sliderValue];
    }
}
- (IBAction)rightFanBaseRPMslide:(id)sender
{
    int sensorCntrlMode = [sensorControlMode selectedRow];
    float sliderValue = [sender floatValue];

    if (MFDebugPrefs) NSLog (@"right sensorCntrlMode = %d\n", sensorCntrlMode);
    if (MFDebugPrefs) NSLog (@"right sliderValue = %f\n\n", sliderValue);

    [self setRightFanBaseRPM:(int)sliderValue];

    // if one temp controls both fans,
    // set the left-fan slider to the current right-fan slider's setting
    if ((sensorCntrlMode == CPU_TEMP_CONTROLS_BOTH_FANS) ||
        (sensorCntrlMode == GPU_TEMP_CONTROLS_BOTH_FANS)) {
        [leftFanBaseRPMslider setFloatValue:sliderValue];
        [self setLeftFanBaseRPM:(int)sliderValue];
    }
}

// accessors & setters
// -----------------------------------------------------------------------------
- (float)lowerTempThreshold
{
    return [daemon lowerTempThreshold];
}
- (float)upperTempThreshold
{
    return [daemon upperTempThreshold];
}
//
- (void)setLowerTempThreshold:(float)newLowerTempThreshold
{
    [daemon setLowerTempThreshold:newLowerTempThreshold];
    [chartView setLowerTempThreshold:newLowerTempThreshold];
}
- (void)setUpperTempThreshold:(float)newUpperTempThreshold
{
    [daemon setUpperTempThreshold:newUpperTempThreshold];
    [chartView setUpperTempThreshold:newUpperTempThreshold];
}
// -----------------------------------------------------------------------------
- (BOOL)showTempsAsFahrenheit
{
    return [daemon showTempsAsFahrenheit];
}
- (void)setShowTempsAsFahrenheit:(BOOL)newShowTempsAsFahrenheit
{
    [daemon setShowTempsAsFahrenheit:newShowTempsAsFahrenheit];
    [transformer setShowTempAsFahrenheit:newShowTempsAsFahrenheit];
    // force display update
    [self updateDisplay:nil];
    [fileOwnerController setContent:nil];
    [fileOwnerController setContent:self];
}
// -----------------------------------------------------------------------------
- (int)leftFanBaseRPM
{
    return [daemon leftFanBaseRPM];
}
- (int)rightFanBaseRPM
{
    return [daemon rightFanBaseRPM];
}
//
- (void)setLeftFanBaseRPM:(int)newLeftFanBaseRPM
{
    [daemon setLeftFanBaseRPM:newLeftFanBaseRPM];
    [chartView setLeftFanBaseRPM:newLeftFanBaseRPM];
}
- (void)setRightFanBaseRPM:(int)newRightFanBaseRPM
{
    [daemon setRightFanBaseRPM:newRightFanBaseRPM];
    [chartView setRightFanBaseRPM:newRightFanBaseRPM];
}
// -----------------------------------------------------------------------------
- (void)setLeftFanTargetRPM:(int)newLeftFanTargetRPM
{
    [daemon setLeftFanTargetRPM:newLeftFanTargetRPM];
    [chartView setLeftFanTargetRPM:newLeftFanTargetRPM];
}
- (void)setRightFanTargetRPM:(int)newRightFanTargetRPM
{
    [daemon setRightFanTargetRPM:newRightFanTargetRPM];
    [chartView setRightFanTargetRPM:newRightFanTargetRPM];
}

@end
