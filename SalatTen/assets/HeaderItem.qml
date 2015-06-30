import bb.cascades 1.2

Container
{
    id: root
    topPadding: ListItem.view.maxHeight - contentContainer.preferredHeight//904
    horizontalAlignment: HorizontalAlignment.Fill
    
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

        Container {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Center
            Label {
                text: {
                    if (!root.ListItem.view.draggingStarted) {
                        var n = boundary.getCurrent( new Date() );
                        return translator.render(n.key);
                    } else {
                        return "HeaderTitle";
                    }
                }
                textStyle.base: header.style
                bottomMargin: 0
            }

            Container {
                topMargin: 0
                layout: StackLayout {
                    orientation: LayoutOrientation.LeftToRight
                }
                Label {
                    horizontalAlignment: HorizontalAlignment.Fill
                    multiline: true
                    text: {
                        if (!root.ListItem.view.draggingStarted) {
                            var n = boundary.getCurrent( new Date() );
                            return localizer.renderStandardTime(n.value)+"\n"+root.ListItem.view.hijriCalc.writeIslamicDate( persist.getValueFor("hijri") );
                        } else {
                            return Qt.formatDate(ListItemData, Qt.SystemLocaleLongDate);
                        }
                    }
                    textStyle.base: header.style
                }
                
                Container {
                    verticalAlignment: VerticalAlignment.Center
                    layout: DockLayout {
                    }
                    //                verticalAlignment: VerticalAlignment.Fill
                    ImageView {
                        verticalAlignment: VerticalAlignment.Center
                        imageSource: "asset:///images/list/ic_athaan_enable.png"
                    }
                }
            }

        }
    }

    attachedObjects: [
        // attaching textStyleDefinitions in each item might not be the most optimal solution but with few item list like this it shouldn't affect much.
        TextStyleDefinition {
            id: header
            fontFamily: "sans-serif"
            fontSize: FontSize.Large
        },

        LayoutUpdateHandler {
            onLayoutFrameChanged: {
                if (root.ListItem.indexPath == 0) {
                    // set the property offset residing in ListView based on this items y position.
                	   root.ListItem.view.offset = layoutFrame.y;
                }
            }
        }
    ]
}