import bb.cascades 1.0

ControlDelegate
{
    id: progressDelegate
    horizontalAlignment: HorizontalAlignment.Center
    verticalAlignment: VerticalAlignment.Center
    delegateActive: false;
    visible: delegateActive
    
    sourceComponent: ComponentDefinition
    {
        Container
        {
            property alias value: progress.value
            property alias toValue: progress.toValue
            horizontalAlignment: HorizontalAlignment.Fill
            
            ProgressControl
            {
                id: busy
                asset: "images/loading/loading_calendar.png"
                preferredHeight: 100; preferredWidth: 100
                verticalAlignment: VerticalAlignment.Top
                delegateActive: true
            }
            
            ProgressIndicator
            {
                id: progress
                fromValue: 0;
                horizontalAlignment: HorizontalAlignment.Center
                state: ProgressIndicatorState.Progress
            }
            
            function onProgressChanged(current, total)
            {
                busy.delegateActive = true;
                value = current;
                toValue = total;
            }
            
            function onComplete(message, icon)
            {
                delegateActive = false;
                persist.showToast(message, icon);
            }
            
            onCreationCompleted: {
                offloader.operationProgress.connect(onProgressChanged);
                offloader.operationComplete.connect(onComplete);
            }
        }
    }
}