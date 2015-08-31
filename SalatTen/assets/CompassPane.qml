import bb.cascades 1.0
import bb.device 1.0
import com.canadainc.data 1.0

FullScreenDialog
{
    onOpened: {
        if ( compass.connected() )
        {
            tutorial.exec("compassAzimuth", qsTr("This is the calculated angle of the direction of the Qibla. Once properly calibrated, rotate the device until the needle points to this angle (in the centre of the compass)."), HorizontalAlignment.Center, VerticalAlignment.Top);
            tutorial.execCentered("compassSuccess", qsTr("When you are successfully pointing to the Qibla direction, your device will vibrate and the angle in the centre of the compass needle will turn green."));
            tutorial.exec("compassExit", qsTr("Tap anywhere outside the controls to dismiss this dialog."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, ui.du(4));
        }
    }
    
    dialogContent: Container
    {
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        attachedObjects: [
            CompassSensor {
                id: compass
            }
        ]
        
        gestureHandlers: [
            TapHandler {
                onTapped: {
                    if (event.propagationPhase == PropagationPhase.AtTarget && canClose) {
                        dismiss();
                    }
                }
            }
        ]
        
        topPadding: 20; leftPadding: 20; rightPadding: 20
        
        ProgressControl
        {
            id: busy
            asset: "images/loading/loading_compass.png"
            delegateActive: compass.calibration < 1
            loadingText: qsTr("Calibrating...") + Retranslate.onLanguageChanged
            
            onDelegateActiveChanged: {
                if (delegateActive) {
                    tutorial.exec("compassAzimuth", qsTr("When the '%1' text is being displayed it means the app is still adjusting and the result may not be correct. When you see this, keep tilting the device up and down over and over and move away from metal until it disappears."), HorizontalAlignment.Center, VerticalAlignment.Top);
                }
            }
        }
        
        Label {
            multiline: true
            text: qsTr("Qibla azimuth: %1°").arg(azimuthLabel.targetAzimuth);
            textStyle.base: SystemDefaults.TextStyles.SmallText
            textStyle.fontStyle: FontStyle.Italic
            textStyle.textAlign: TextAlign.Center
            horizontalAlignment: HorizontalAlignment.Center
            
            onCreationCompleted: {
                if ( !compass.connected() ) {
                    text = qsTr("Compass backend failed to connect! Either your device does not support Qibla detection or it is in a bad state and you should reset your device or the app and try again!") + Retranslate.onLanguageChanged
                    reporter.record("CompassFailure");
                }
            }
        }
        
        Container
        {
            id: mainContainer
            rotationZ: -compass.azimuth
            
            // Disable implicit animations to avoid ugly "jumps" when switching from 0 degrees to 360 degrees and vice versa
            attachedObjects: ImplicitAnimationController {
                propertyName: "rotationZ"
                enabled: false
            }
            
            layoutProperties: StackLayoutProperties {
                spaceQuota: 1
            }
            
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            layout: DockLayout {}
            
            ImageView {
                id: compFace
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                imageSource: "images/compass/face.png"
                scalingMethod: ScalingMethod.AspectFit
            }
            
            ImageView {
                id: needle
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                scalingMethod: ScalingMethod.AspectFit
                imageSource: "images/compass/arrow_bright.png"
            }
            
            Label {
                id: azimuthLabel
                property int targetAzimuth
                property int currentAzimuth: Math.round(compass.azimuth)
                
                onCurrentAzimuthChanged: {
                    if ( currentAzimuth == targetAzimuth && vibrator.isSupported() ) {
                        vibrator.start(100,750);
                    }
                }
                
                text: qsTr("%1°").arg(currentAzimuth)
                textStyle.base: SystemDefaults.TextStyles.BigText
                textStyle.fontWeight: FontWeight.Bold
                textStyle.textAlign: TextAlign.Center
                textStyle.color: targetAzimuth == currentAzimuth ? Color.Green : undefined
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                rotationZ: compass.azimuth
                opacity: 0.7
                
                onCreationCompleted: {
                    var meccaCoordinates = Qt.vector3d(21.4267, 39.8261, 277); // latitude, longitude, elevation
                    var target = compass.calculateAzimuth( persist.getValueFor("latitude"), persist.getValueFor("longitude"), 0, meccaCoordinates.x, meccaCoordinates.y, meccaCoordinates.z );
                    targetAzimuth = Math.round(target);
                }
                
                attachedObjects: [
                    VibrationController {
                        id: vibrator
                    }
                ]
            }
            
            animations: [
                ScaleTransition
                {
                    fromX: 0
                    fromY: 0
                    toX: 1
                    toY: 1
                    duration: 1000
                    easingCurve: StockCurve.CircularInOut
                    
                    onCreationCompleted: {
                        play();
                    }
                }
            ]
        }
    }
}