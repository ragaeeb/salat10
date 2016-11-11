import bb.cascades 1.0

FullScreenDialog
{
    id: root
    darkness: 0.7
    
    onOpened: {
        dtp.expanded = true;
        
        tutorial.execCentered("convertInfo", qsTr("This utility can be used to convert any Gregorian date (from the disbeliever's calendar) to the Hijri (Islamic) Calendar.\n\nSimply use the dropdown to select the Julian date and you will see the Hijri date being displayed.") );
        tutorial.exec("convertExit", qsTr("Tap anywhere outside the controls to dismiss this dialog."), HorizontalAlignment.Center, VerticalAlignment.Bottom, 0, 0, 0, tutorial.du(4));
        
        hijriLabel.text = hijriCalc.writeIslamicDate( persist.getValueFor("hijri"), dtp.value );
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
            
            contextActions: [
                ActionSet
                {
                    title: hijriLabel.text
                    
                    ActionItem
                    {
                        imageSource: "images/common/ic_copy.png"
                        title: qsTr("Copy") + Retranslate.onLanguageChanged
                        
                        onTriggered: {
                            console.log("UserEvent: CopyHijriDate");
                            persist.copyToClipboard(hijriLabel.text);
                        }
                    }
                }
            ]
            
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
    }
}