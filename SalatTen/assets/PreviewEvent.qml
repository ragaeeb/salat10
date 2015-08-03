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
        translationX: -200
        
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
        textStyle.fontSize: FontSize.Large
        verticalAlignment: VerticalAlignment.Center
        multiline: true
        opacity: 0
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    ImageButton
    {
        id: editButton
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Center
        defaultImageSource: "images/menu/ic_edit.png"
        pressedImageSource: defaultImageSource
        translationX: 200
        
        onClicked: {
            console.log("UserEvent: EditHijriDate");
            editTiming(current.key);
        }
    }
    
    animations: [
        SequentialAnimation
        {
            id: ttx
            
            onCreationCompleted: {
                play();
            }
            
            FadeTransition {
                target: detailsLabel
                fromOpacity: 0
                toOpacity: 1
                delay: 250
                duration: 800
                easingCurve: StockCurve.QuinticOut
            }
            
            TranslateTransition
            {
                target: editButton
                
                fromX: 200
                toX: 0
                duration: global.getRandomReal(200, 400)
                delay: global.getRandomReal(100, 250)
                easingCurve: StockCurve.SineOut
            }
            
            TranslateTransition
            {
                target: athanStatus
                
                fromX: -200
                toX: 0
                duration: global.getRandomReal(200, 400)
                delay: global.getRandomReal(100, 250)
                easingCurve: StockCurve.ExponentialOut
            }
        }
    ]
}