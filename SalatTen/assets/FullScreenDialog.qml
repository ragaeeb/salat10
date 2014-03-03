import bb.cascades 1.0
import bb.device 1.0

Dialog
{
    id: root
    property alias dialogContent: dialogContainer.controls
    signal closing();
    
    onOpened: {
        dialogContainer.opacity = 1;
    }
    
    Container
    {
        id: dialogContainer
        preferredWidth: displayInfo.pixelSize.width
        preferredHeight: displayInfo.pixelSize.height
        background: Color.create(0.0, 0.0, 0.0, 0.5)
        layout: DockLayout {}
        opacity: 0
        
        gestureHandlers: [
            TapHandler {
                onTapped: {
                    if (event.propagationPhase == PropagationPhase.AtTarget) {
                        closing();
                        root.close();
                    }
                }
            }
        ]
        
        attachedObjects: [
            DisplayInfo {
                id: displayInfo
            }
        ]
    }
    
    onClosed: {
        root.destroy();
    }
}