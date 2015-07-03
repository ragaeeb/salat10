import bb.cascades 1.2

Container
{
    property int listWidth: 1440
    property int listHeight: 1440

    onCreationCompleted: {
        //cityList.dataModel.insert("status");
    }

    layout: DockLayout {}
    
    ScrollView
    {
        id: backgroundView
        horizontalAlignment: HorizontalAlignment.Fill
        verticalAlignment: VerticalAlignment.Fill

        Container
        {
            horizontalAlignment: HorizontalAlignment.Fill
            verticalAlignment: VerticalAlignment.Fill
            layout: DockLayout {}

            ImageView
            {
                id: bg
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                imageSource: "images/graphics/maghrib.jpg"
                scalingMethod: ScalingMethod.AspectFill
                
                onCreationCompleted: {
                    var current = boundary.getCurrent( new Date() );
                    reporter.log(current);
                    //imageSource = "images/graphics/%1.jpg".arg(current.key);
                    console.log("***", imageSource);
                }
            }

            ImageView
            {
                id: bg2
                opacity: 0
                loadEffect: ImageViewLoadEffect.FadeZoom
                horizontalAlignment: HorizontalAlignment.Fill
                verticalAlignment: VerticalAlignment.Fill
                scalingMethod: ScalingMethod.AspectFill
                
                onCreationCompleted: {
                    localizer.blur(bg2);
                }
            }
        }
    }
    
    Label
    {
        multiline: true
        text: "\nldksjf slkjfsdlkfjd sfalksjf ljaksdlfjlasdf\n\nlakjsdflkjf lkajsdflkj\nkajsf"
        visible: !cityList.draggingStarted
        textStyle.textAlign: TextAlign.Center
        horizontalAlignment: HorizontalAlignment.Fill
    }

    ResultListView
    {
        id: cityList
        // Lists tries to expand as much as possible and since it's located inside another listView it will get unlimited widht. 
        maxWidth: listWidth
        maxHeight: listHeight
        stickToEdgePolicy: ListViewStickToEdgePolicy.Beginning
        property bool draggingStarted: false
        property alias hijriCalc: hijri
        scrollIndicatorMode: ScrollIndicatorMode.None

        attachedObjects: [
            ListScrollStateHandler {
                onScrollingChanged: {
                    if (scrolling) {
                        cityList.draggingStarted = true
                        bg2.opacity = 1;
                    } else if (atBeginning) {
                        cityList.draggingStarted = false
                        bg2.opacity = 0;
                    }
                }
            },
            
            HijriCalculator {
                id: hijri
            }
        ]

		// list offset. Currently set from HeaderItem.qml. Ideally something similar to visibleArea would be nice instead.
        property int offset
        onOffsetChanged: {
            // paralax-scrolling the background based on offset.
            backgroundView.scrollToPoint(0, - offset / 3, ScrollAnimation.None);
        }

        listItemComponents: [
            ListItemComponent {
                type: "header"
                HeaderItem {
                }
            },
            
            ListItemComponent
            {
                type: "item"
                
                EventListItem {
                    id: eli
                }
            }
        ]
    }

    function showAnim() {
        show.play();
    }
    function hideAnim() {
        show.stop();
        hide.play();
        cityList.scrollToPosition(ScrollPosition.Beginning,ScrollAnimation.Smooth);
    }
    
    animations: [
        ParallelAnimation {
            id: show
            target: cityList
            FadeTransition {
                fromOpacity: 0
                toOpacity: 1
                duration: 500
                easingCurve: StockCurve.CubicOut
            }
            TranslateTransition {
                fromY: 300
                toY: 0
                duration: 500
                easingCurve: StockCurve.CubicOut
            }
        },
        ParallelAnimation {
            id: hide
            target: cityList
            FadeTransition {
                toOpacity: 0
                duration: 100
                easingCurve: StockCurve.CubicIn
            }
            TranslateTransition {
                fromY: 0
                toY: 300
                duration: 500
                easingCurve: StockCurve.CubicIn
            }
        }
    ]
}
