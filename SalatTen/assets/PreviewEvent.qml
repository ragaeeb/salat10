import bb.cascades 1.2
import com.canadainc.data 1.0

Container
{
    property variant current
    property alias style: detailsLabel.textStyle
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Center
    
    function cleanUp() {
        statusTimer.timeout.disconnect(statusTimer.updateStatus);
        heartBeat.stop();
    }
    
    onCreationCompleted: {
        statusTimer.timeout.connect(statusTimer.updateStatus);
    }
    
    onCurrentChanged: {
        if (current)
        {
            var timeValue = offloader.renderStandardTime(current.value);
            detailsLabel.text = translator.render(current.key)+" "+timeValue;
            athanStatus.defaultImageSource = global.renderAthanStatus(current);
            
            var now = new Date();
            
            if ( current.value > now || current.iqamah > now ) {
                statusTimer.start(1000);
            } else {
                statusTimer.stop();
            }
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
        
        animations: [
            SequentialAnimation
            {
                id: heartBeat
                
                ScaleTransition
                {
                    fromX: 1
                    fromY: 1
                    toX: 0.8
                    toY: 0.8
                    duration: 500
                    easingCurve: StockCurve.DoubleElasticOut
                }
                
                ScaleTransition
                {
                    fromX: 0.8
                    fromY: 0.8
                    toX: 1
                    toY: 1
                    duration: 500
                    easingCurve: StockCurve.DoubleElasticIn
                }
            }
        ]
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
        id: iqamahButton
        horizontalAlignment: HorizontalAlignment.Right
        verticalAlignment: VerticalAlignment.Center
        defaultImageSource: "images/menu/ic_set_jamaah.png"
        pressedImageSource: defaultImageSource
        translationX: 300
        visible: current && current.isSalat
        
        onClicked: {
            console.log("UserEvent: EditIqamah");
            editIqaamah(current.key, current.value);
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
                target: iqamahButton
                
                fromX: 300
                toX: 0
                duration: global.getRandomReal(200, 400)
                delay: global.getRandomReal(100, 250)
                easingCurve: StockCurve.CircularInOut
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
            
            onEnded: {
                if ( iqamahButton.visible && tutorial.isTopPane(navigationPane, timingsPage) ) {
                    tutorial.exec("iqamahShortcut", qsTr("Tap on the iqamah clock icon to set the time that the congregational prayer begins at your local musalla or masjid."), HorizontalAlignment.Right, VerticalAlignment.Bottom, 0, tutorial.du(8), 0, tutorial.du(1) );
                }
            }
        }
    ]
    
    attachedObjects: [
        QTimer
        {
            id: statusTimer
            singleShot: false
            
            function renderIqamah(now)
            {
                var diff = current.iqamah - now;
                var diffDays = Math.ceil( diff/(1000*3600*24) );
                
                if (diff > 0 && diffDays < 2 && current.active)
                {
                    var minutes = Math.floor( diff / (1000 * 60) );
                    var difference = diff - minutes * (1000 * 60);
                    var seconds = Math.floor(difference / 1000);
                    var eventName = translator.render(current.key);
                    
                    if (minutes > 30) {
                        detailsLabel.text = qsTr("%2 Iqamah: %1").arg( offloader.renderStandardTime(current.iqamah) ).arg(eventName);
                        start(diff-60000*30);
                    } else if (minutes <= 30 && minutes > 5) {
                        interval = 60000;
                        detailsLabel.text = qsTr("%1 Iqamah in %n minutes", "", minutes).arg(eventName);
                    } else if (minutes >= 1) {
                        interval = 1000;
                        detailsLabel.text = qsTr("%3 Iqamah in %1 minutes %2 seconds").arg(minutes).arg(seconds).arg(eventName);
                    } else if (seconds > 0) {
                        interval = 1000;
                        detailsLabel.text = qsTr("%1 Iqamah in %n seconds", "", seconds).arg(eventName);
                    }
                } else {
                    stop();
                    heartBeat.stop();
                }
            }
            
            function updateStatus()
            {
                var now = new Date();
                var diff = current.value - now;

                if (diff > 0)
                {
                    var minutes = Math.floor( diff / (1000 * 60) );
                    var difference = diff - minutes * (1000 * 60);
                    var seconds = Math.floor(difference / 1000);
                    var eventName = translator.render(current.key);
                    
                    if (minutes > 30)
                    {
                        start(diff-60000*30);
                        
                        if (current.iqamah) {
                            renderIqamah(now);
                        }
                    } else if (minutes <= 30 && minutes > 5) {
                        interval = 60000;
                        detailsLabel.text = qsTr("%1 %n minutes", "", minutes).arg(eventName);
                    } else if (minutes >= 1) {
                        interval = 1000;
                        detailsLabel.text = qsTr("%3 %1 minutes %2 seconds").arg(minutes).arg(seconds).arg(eventName);
                    } else if (seconds > 0) {
                        interval = 1000;
                        detailsLabel.text = qsTr("%1 %n seconds", "", seconds).arg(eventName);
                        
                        if ( !heartBeat.isPlaying() ) {
                            heartBeat.play();
                        }
                    }
                } else if (current.iqamah) {
                    renderIqamah(now);
                } else {
                    stop();
                    heartBeat.stop();
                }
            }
        }
    ]
}