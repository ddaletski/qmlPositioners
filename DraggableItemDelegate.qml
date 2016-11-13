import QtQuick 2.7
import QtQml.Models 2.2

MouseArea {
    id: root
    property int visualIndex // index of current object in view
    property var delegateData
    property var view // view where this object is placed
    property Component content // content of wrapper
    property Component highlight // highlight of dragged item
    property var item: contentLoader.item

    // signal to move 'first' and 'second' items in view
    signal move(int first, int second)
    drag.target: container

    content: Component { Item {} } // default content
    width: contentLoader.item.width
    height: contentLoader.item.height

    Item {
        id: container
        anchors {
            horizontalCenter: parent.horizontalCenter
            verticalCenter: parent.verticalCenter
        }

        width: root.width
        height: root.height

        Drag.active: root.drag.active
        Drag.source: root
        Drag.hotSpot.x: width / 2
        Drag.hotSpot.y: height / 2

        Drag.onActiveChanged: contentLoader.item.dragChanged(root.drag)

        states: [
            State {
                name: "DRAG"
                when: container.Drag.active
                PropertyChanges {
                    target: container
                    parent: root.view
                }
                AnchorChanges {
                    target: container
                    anchors.horizontalCenter: undefined
                    anchors.verticalCenter: undefined
                }
                PropertyChanges {
                    target: highlight
                    opacity: 1
                }

            }
        ]

        transitions: [
            Transition {
                from: "DRAG"
                to: ""
                AnchorAnimation {
                    duration: 0
                }
                NumberAnimation {
                    target: highlight
                    property: "opacity"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
           }
        ]

        Loader {
            id: contentLoader
            anchors.centerIn: container
            opacity: parent.opacity
            sourceComponent: root.content
            property int index: root.visualIndex
            property var modelData: root.delegateData
        }

        Loader {
            id: highlight
            anchors.centerIn: container
            width: root.width
            height: root.height
            sourceComponent: root.highlight
            opacity: 0
        }
    }

    Timer {
        id: dropTimer
        interval: 300
        onTriggered: {
            if(visualIndex !== dropArea.draggedItemIndex) {
                root.move(dropArea.draggedItemIndex, visualIndex)
            }
        }
    }

    DropArea {
        id: dropArea
        anchors.fill: parent
        property int draggedItemIndex
        onEntered: {
            draggedItemIndex = drag.source.visualIndex
            dropTimer.start()
        }
        onExited: {
            dropTimer.stop()
        }
    }

    Component.onCompleted: {
        root.highlight = contentLoader.item.highlight
    }
}
