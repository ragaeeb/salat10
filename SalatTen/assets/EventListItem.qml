import bb.cascades 1.0
import com.canadainc.data 1.0

StandardListItem
{
    id: sli
    property variant data: ListItem.data
    title: ListItemData ? ListItem.view.localization.renderStandardTime(ListItemData.value) : undefined;
    description: ListItemData ? ListItem.view.translation.render(ListItemData.key) : undefined;
    
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
                title: qsTr("Copy") + Retranslate.onLanguageChanged
                imageSource: "images/ic_copy.png"
                
                onTriggered: {
                    sli.ListItem.view.util.copyEvent(ListItemData);
                }
            }
            
            InvokeActionItem {
                title: qsTr("Share") + Retranslate.onLanguageChanged
                
                query {
                    mimeType: "text/plain"
                    invokeActionId: "bb.action.SHARE"
                }
                
                onTriggered: {
                    data = sli.ListItem.view.util.toUtf8(sli.ListItem);
                }
            }
            
            ActionItem {
                title: {
                    if (ListItemData && ListItemData.athaan == true) {
                        return ListItemData.isSalat ? qsTr("Mute Athaan") : qsTr("Mute Alarm");
                    } else {
                        return ListItemData.isSalat ? qsTr("Enable Athaan") : qsTr("Enable Alarm");
                    }
                }
                
                imageSource: ListItemData && ListItemData.athaan == true ? "images/ic_athaan_mute.png" : "images/ic_athaan_enable.png"
                
                onTriggered: {
                    sli.ListItem.view.util.toggleAthaan(sli.ListItem);
                }
            }
            
            ActionItem {
                title: qsTr("Set Custom Sound") + Retranslate.onLanguageChanged
                imageSource: "images/ic_athaan_custom.png"
                
                onTriggered: {
                    sli.ListItem.view.util.setCustomAthaans([ListItemData.key]);
                }
            }
            
            ActionItem {
                title: qsTr("Edit") + Retranslate.onLanguageChanged
                imageSource: "images/ic_edit.png"
                
                onTriggered: {
                    sli.ListItem.view.edit(sli.ListItem.indexPath);
                }
            }
            
            DeleteActionItem {
                title: qsTr("Reset Sound") + Retranslate.onLanguageChanged
                imageSource: "images/ic_reset_athaan.png"
                
                onTriggered: {
                    sli.ListItem.view.util.resetSound([ListItemData.key]);
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