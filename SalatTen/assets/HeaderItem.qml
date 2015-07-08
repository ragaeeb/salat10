import bb.cascades 1.2

Container
{
    id: root
    horizontalAlignment: HorizontalAlignment.Fill
    
    ListItem.onDataChanged: {
        var gregDate = Qt.formatDate(ListItemData, Qt.SystemLocaleLongDate);
        currentDetails.text = root.ListItem.view.hijriCalc.writeIslamicDate( persist.getValueFor("hijri") )+"\n"+gregDate;
    }
    
    gestureHandlers: [
        DoubleTapHandler {
            onDoubleTapped: {
                if (event.propagationPhase == PropagationPhase.AtTarget) {
                    root.ListItem.view.refresh();
                }
            }
        }
    ]
    
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
        
        Label
        {
            id: currentDetails
            textStyle.base: root.ListItem.view.fontStyle
            bottomMargin: 0
            multiline: true
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
        }
    }
}