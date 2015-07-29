import bb.cascades 1.2

Container
{
    id: root
    horizontalAlignment: HorizontalAlignment.Fill
    
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
        if ( "navigation" in root ) {
            var nav = root.navigation;
            nav.focusPolicy = 0x1;
            nav.defaultHighlightEnabled = false;
        }
    }
    
    ListItem.onInitializedChanged: {
        if (initialized) {
            topPadding = ListItem.view.maxHeight - contentContainer.preferredHeight
        }
    }
    
    ListItem.onDataChanged: {
        dateDetails.text = root.ListItem.view.hijriCalc.writeIslamicDate( persist.getValueFor("hijri") );
        gregDate.text = Qt.formatDate(ListItemData, Qt.SystemLocaleLongDate);
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
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                bottomPadding: 20
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                ImageView
                {
                    imageSource: "images/list/ic_calendar_hijri.png"
                    verticalAlignment: VerticalAlignment.Center
                }
                
                Label
                {
                    id: dateDetails
                    textStyle.fontSize: FontSize.XLarge
                    verticalAlignment: VerticalAlignment.Center
                    multiline: true
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                }
            }
            
            Container
            {
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Center
                topPadding: 20
                
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                
                ImageView
                {
                    imageSource: "images/list/ic_calendar.png"
                    verticalAlignment: VerticalAlignment.Center
                }
                
                Label
                {
                    id: gregDate
                    textStyle.fontSize: FontSize.XLarge
                    verticalAlignment: VerticalAlignment.Center
                    multiline: true
                    
                    layoutProperties: StackLayoutProperties {
                        spaceQuota: 1
                    }
                }
            }
        }
    }
}