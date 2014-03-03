import bb.cascades 1.0

Container
{
    id: rootContainer
    horizontalAlignment: HorizontalAlignment.Fill
    property alias toggle: checkBox
    property alias slideControl: slider
    
    layout: StackLayout {
        orientation: LayoutOrientation.LeftToRight
    }
    
    CheckBox
    {
        id: checkBox
        horizontalAlignment: HorizontalAlignment.Fill
        checked: rootContainer.enabled
        
        layoutProperties: StackLayoutProperties {
            spaceQuota: 1
        }
    }
    
    Slider
    {
        id: slider
        preferredWidth: 300
        fromValue: -30
        toValue: 30
        value: 0
        horizontalAlignment: HorizontalAlignment.Right
    }
}