import bb.cascades 1.0
import com.canadainc.data 1.0

StandardListItem
{
    id: sli
    property variant data: ListItem.data
    property bool peek: sli.ListItem.view.secretPeek
    title: ListItemData ? ListItem.view.localization.renderStandardTime(ListItemData.value) : undefined;
    description: ListItemData ? ListItem.view.translation.render(ListItemData.key) : undefined;
    imageSource: {
        if (ListItemData) {
            if (ListItemData.athaan == true && ListItemData.isSalat) {
                return "images/ic_athaan_enable.png";
            } else if (ListItemData.notification == true) {
                return "images/ic_notification_enable.png";
            } else {
                return "images/ic_athaan_mute.png";
            }
        } else {
            return undefined;
        }
    }
    
    onPeekChanged: {
        if (peek) {
            showAnim.play();
        }
    }
    
    onDataChanged: {
        if (!ListItemData) {
            return;
        }
        
        if ( ListItemData.value > new Date() ) {
            status = undefined;
            statusTimer.timeout.connect(statusTimer.updateStatus);
            statusTimer.start(1000);   
        } else {
            statusTimer.cancel();
        }
    }
    
    opacity: 0
    animations: [
        FadeTransition
        {
            id: showAnim
            fromOpacity: 0
            toOpacity: 1
            duration: sli.ListItem.indexInSection*300
        }
    ]
    
    onCreationCompleted: {
        showAnim.play();
    }
    
    contextActions: [
        ActionSet {
            title: sli.title
            subtitle: sli.description
            
            ActionItem {
                title: qsTr("Edit") + Retranslate.onLanguageChanged
                imageSource: "images/ic_edit.png"
                
                onTriggered: {
                    sli.ListItem.view.edit(sli.ListItem.indexPath);
                }
            }
        }
    ]
    
    attachedObjects: [
        QTimer {
            id: statusTimer
            singleShot: false
            
            function cancel()
            {
                stop();
                timeout.disconnect(updateStatus);
                sli.status = undefined;
            }
            
            function updateStatus()
            {
                var diff = ListItemData.value - new Date();
                
                if (diff > 0)
                {
                    var minutes = Math.floor( diff / (1000 * 60) );
                    var difference = diff - minutes * (1000 * 60);
                    
                    var seconds = Math.floor(difference / 1000);
                    
                    if (minutes > 30) {
                        start(diff-60000*30);
                    } else if (minutes <= 30 && minutes > 5) {
                        interval = 60000;
                        sli.status = qsTr("%1 minutes").arg(minutes);
                    } else if (minutes >= 1) {
                        interval = 1000;
                        sli.status = qsTr("%1 minutes %2 seconds").arg(minutes).arg(seconds);
                    } else if (seconds > 0) {
                        interval = 1000;
                        sli.status = qsTr("%1 seconds").arg(seconds);
                    }
                } else {
                    cancel();
                }
            }
        }
    ]
}