import bb.cascades 1.0

ControlDelegate
{
    delegateActive: !boundary.calculationFeasible && boundary.anglesSaved
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    visible: delegateActive
    
    sourceComponent: ComponentDefinition
    {
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            
            ImageView
            {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                imageSource: "images/empty/ic_no_location.png"
                scalingMethod: ScalingMethod.AspectFit
                loadEffect: ImageViewLoadEffect.FadeZoom
                
                gestureHandlers: [
                    TapHandler {
                        onTapped: {
                            console.log("EmptyLocationTapped");
                            var l = definition.init("LocationPane.qml");
                            navigationPane.push(l);
                        }
                    }
                ]
            }
            
            Label
            {
                horizontalAlignment: HorizontalAlignment.Center
                verticalAlignment: VerticalAlignment.Center
                multiline: true
                textStyle.fontSize: FontSize.Large
                textStyle.textAlign: TextAlign.Center
                text: qsTr("Could not calculate timings because your location has not yet been set.\n\nClick here to set it.") + Retranslate.onLanguageChanged
            }
        }
    }
}