import bb.cascades 1.0

Container
{
    signal swipedUp();
    signal swipedDown();
    signal swipedRight();
    signal swipedLeft();
    signal swipedUpRight();
    signal swipedUpLeft();
    signal swipedDownLeft();
    signal swipedDownRight();
    property int downX;
    property int downY;
    
    onTouch:
    {
        if ( event.isDown() ) {
            downX = event.windowX;
            downY = event.windowY;
        } else if ( event.isUp() ) {
            var yDiff = downY - event.windowY;
            var xDiff = downX - event.windowX;
            
            if (yDiff < 0) {
                yDiff = -1 * yDiff;
            }
            
            if (xDiff < 0) {
                xDiff = -1 * xDiff;
            }
            
            if (yDiff < 200) {
                if ((downX - event.windowX) > 320) {
                    swipedLeft();
                } else if ((event.windowX - downX) > 320) {
                    swipedRight();
                }
            } else if (xDiff < 200) {
                if ((downY - event.windowY) > 320) {
                    swipedUp();
                } else if ( (event.windowY - downY) > 320 ) {
                    swipedDown();
                }
            } else if (yDiff >= 200 && xDiff >= 200) { // diagonal swipe
                if ( (downX - event.windowX) > 320 && (downY - event.windowY) > 320 ) {
                    swipedUpLeft();
                } else if ( (event.windowX - downX) > 320 && (downY - event.windowY) > 320 ) {
                    swipedUpRight();
                } if ( (downX - event.windowX) > 320 && (event.windowY - downY) > 320 ) {
                    swipedDownLeft();
                } else if ( (event.windowX - downX) > 320 && (event.windowY - downY) > 320 ) {
                    swipedDownRight();
                }
            }
        }
    }
}