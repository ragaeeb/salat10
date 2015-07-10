import bb.cascades 1.0

Container
{
    property variant current
    property alias style: detailsLabel.textStyle
    
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    
    onCurrentChanged: {
        if (current)
        {
            var timeValue = offloader.renderStandardTime(current.value);
            detailsLabel.text = translator.render(current.key)+" "+timeValue;
            actionSet.title = translator.render(current.key);
            actionSet.subtitle = timeValue;
            athanStatus.defaultImageSource = global.renderAthanStatus(current);
        }
    }
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    ImageButton
    {
        id: athanStatus
        verticalAlignment: VerticalAlignment.Center
        pressedImageSource: defaultImageSource
        
        onClicked: {
            var athaans = persist.getValueFor("athaans");
            var notifications = persist.getValueFor("notifications");
            var k = current.key;
            
            athaans[k] = !athaans[k];
            notifications[k] = !notifications[k];
            persist.saveValueFor("athaans", athaans);
            persist.saveValueFor("notifications", notifications);
        }
    }
    
    Label
    {
        id: detailsLabel
        textStyle.fontSize: FontSize.XLarge
        verticalAlignment: VerticalAlignment.Center
        multiline: true
    }
    
    contextActions: [
        ActionSet
        {
            id: actionSet
            
            ActionItem {
                title: qsTr("Edit Time") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_edit.png"
                
                onTriggered: {
                    console.log("UserEvent: EditHijriDate");
                    editTiming(current.key);
                }
            }
        }
    ]
}