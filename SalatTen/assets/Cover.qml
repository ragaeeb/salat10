import bb.cascades 1.0

Container
{   
    attachedObjects: [
        ImagePaintDefinition {
            id: back
            imageSource: "asset:///images/graphics/banner_expanded.amd"
        }
    ]
        
    background: back.imagePaint
    leftPadding: 10; rightPadding: 10
    horizontalAlignment: HorizontalAlignment.Fill
    verticalAlignment: VerticalAlignment.Fill
    layout: DockLayout {}

    Container
    {
	    horizontalAlignment: HorizontalAlignment.Fill
	    verticalAlignment: VerticalAlignment.Center
        
        ImageView {
            horizontalAlignment: HorizontalAlignment.Center
            imageSource: "images/tabs/ic_clock.png"
        }
        
        Label {
            id: currentLabel
            text: qsTr("Salat10")
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.base: SystemDefaults.TextStyles.SubtitleText
            textStyle.textAlign: TextAlign.Center
            multiline: true
        }
        
        Label {
            id: nextLabel
            horizontalAlignment: HorizontalAlignment.Fill
            textStyle.base: SystemDefaults.TextStyles.SmallText
            textStyle.textAlign: TextAlign.Center
            multiline: true
        }
    }
    
    function onCurrentEventChanged()
    {
        var now = new Date();
        var current = boundary.getCurrent(now);
        var next = boundary.getNext(now);
        
        var n = translator.render(current.key);
        var t = offloader.renderStandardTime(current.value);
        currentLabel.text = n + ": " + t;
        
        n = translator.render(next.key);
        t = offloader.renderStandardTime(next.value);
        nextLabel.text = n + ": " + t;
    }
    
    onCreationCompleted: {
        notification.currentEventChanged.connect(onCurrentEventChanged);
        
        if (boundary.calculationFeasible) {
            onCurrentEventChanged();
        }
    }
}