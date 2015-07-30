import bb.cascades 1.0

FullScreenDialog
{
    id: root
    darkness: 0.7
    
    onOpened: {
        dtp.expanded = true;
    }
    
    dialogContent: Container
    {
        id: dialogContainer
        bottomPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Center
        
        Label {
            id: hijriLabel
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.textAlign: TextAlign.Center
            textStyle.fontSize: FontSize.Large
            
            animations: [
                FadeTransition {
                    id: ft
                    fromOpacity: 0
                    toOpacity: 1
                    easingCurve: StockCurve.ElasticOut
                    duration: 1500
                },
                
                SequentialAnimation
                {
                    id: expander
                    
                    ScaleTransition {
                        fromX: 1
                        toX: 0.5
                        easingCurve: StockCurve.QuinticInOut
                        duration: 500
                    }
                    
                    ScaleTransition {
                        fromX: 0.5
                        toX: 1
                        easingCurve: StockCurve.CircularInOut
                        duration: 500
                    }
                    
                    onEnded: {
                        hijriLabel.text = hijri.writeIslamicDate( persist.getValueFor("hijri"), dtp.value );
                    }
                }
            ]
        }
        
        DateTimePicker
        {
            id: dtp
            mode: DateTimePickerMode.Date
            horizontalAlignment: HorizontalAlignment.Center
            verticalAlignment: VerticalAlignment.Center
            title: qsTr("Gregorian Date") + Retranslate.onLanguageChanged
            
            onValueChanged: {
                if (hijriLabel.text.length == 0) {
                    ft.play();
                    hijriLabel.text = hijri.writeIslamicDate( persist.getValueFor("hijri"), value );
                } else {
                    expander.play();
                }
            }
        }
        
        attachedObjects: [
            HijriCalculator {
                id: hijri
            }
        ]
    }
}