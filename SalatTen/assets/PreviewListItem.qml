import bb.cascades 1.2

Container
{
    id: root
    horizontalAlignment: HorizontalAlignment.Fill
    
    contextActions: [
        ActionSet {
            id: actionSet
            
            ActionItem {
                title: qsTr("Edit") + Retranslate.onLanguageChanged
                imageSource: "images/menu/ic_edit.png"
                
                onTriggered: {
                    console.log("UserEvent: EditHijriDate");
                    root.ListItem.view.editHijriDate();
                }
            }
        }
    ]
    
    function onSettingChanged(newValue, key)
    {
        if (key == "hijri")
        {
            var now = new Date();
            var current = boundary.getCurrent(now);
            var timeValue = offloader.renderStandardTime(current.value);
            var adjust = persist.getValueFor("hijri");
            var hijriDate = root.ListItem.view.hijriCalc.writeIslamicDate(adjust);
            
            actionSet.title = hijriDate;
            actionSet.subtitle = adjust == 0 ? qsTr("No adjustments") : adjust > 0 ? "+"+adjust.toString() : adjust.toString();
            currentDetails.text = hijriDate+"\n"+translator.render(current.key)+" "+timeValue;
            
            var next = boundary.getNext(now);
            nextDetails.text = translator.render(next.key)+" "+offloader.renderStandardTime(next.value);
        }
    }
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            persist.registerForSetting(root, "hijri");
        }
    }
    
    onCreationCompleted: {
        topPadding = ListItem.view.maxHeight - contentContainer.preferredHeight
    }
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    Container
    {
        id: contentContainer
        background: Color.create("#66000000")
        leftPadding: 30
        rightPadding: 30
        bottomPadding: 30
        topPadding: 30
        horizontalAlignment: HorizontalAlignment.Fill
        preferredHeight: 376
        layout: DockLayout {}
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
        
        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            
            Label
            {
                id: currentDetails
                textStyle.base: root.ListItem.view.fontStyle
                bottomMargin: 0
                multiline: true
            }
            
            Label
            {
                id: nextDetails
                textStyle.fontSize: FontSize.Medium
                bottomMargin: 0
                multiline: true
            }
        }
    }
}