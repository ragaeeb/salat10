import bb.cascades 1.0
import bb.device 1.0
import bb.system 1.0
import com.canadainc.data 1.0

NavigationPane
{
    id: navigationPane
    
    onPopTransitionEnded: {
        page.destroy();
    }
    
    Page
    {
        onCreationCompleted: {
            persist.showToast( qsTr("Move away from metal and try to match the value on the compass to the Qibla azimuth value at the top. When you are pointing in the correct direction your device will vibrate.\n\nIf you see a spinning icon at the top it means the compass readings are still being adjusted. If you see this, keep rotating and moving until it goes away."), qsTr("OK"), "asset:///images/compass/ic_compass.png" );
        }
        
        Container
        {
            attachedObjects: [
                ImagePaintDefinition {
                    id: back
                    imageSource: "images/graphics/background.png"
                },
                
                CompassSensor {
                    id: compass
                }
            ]
            
            topPadding: 20; leftPadding: 20; rightPadding: 20
            background: back.imagePaint
            
            ActivityIndicator {
                running: compass.calibration < 1
                visible: running
                verticalAlignment: VerticalAlignment.Top
                horizontalAlignment: HorizontalAlignment.Center
            }
            
            Label {
                multiline: true
                text: qsTr("Qibla azimuth: %1°").arg(azimuthLabel.targetAzimuth);
                textStyle.base: SystemDefaults.TextStyles.SmallText
                textStyle.fontStyle: FontStyle.Italic
                textStyle.textAlign: TextAlign.Center
                horizontalAlignment: HorizontalAlignment.Fill
                
                onCreationCompleted: {
                    if ( !compass.connected() ) {
                        text = qsTr("Compass backend failed to connect! Either your device does not support Qibla detection or it is in a bad state and you should reset your device or the app and try again!") + Retranslate.onLanguageChanged
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
}