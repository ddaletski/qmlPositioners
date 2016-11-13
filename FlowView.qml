import QtQuick 2.7
import QtQml.Models 2.2

Item {
    id: root
    readonly property alias count: repeater.count
    property alias interactive: flickable.interactive
    property alias model: delegateModel.model
    property alias spacing: flow.spacing
    property bool dragEnabled: true
    property Item contentItem: flickable.contentItem
    property Component delegate

    signal move(int first, int second)
    signal drop()

    property var itemAt: function(idx) {
        return repeater.itemAt(idx)
    }

    Flickable {
        id: flickable
        anchors.fill: parent
        contentWidth: width;
        contentHeight: flow.childrenRect.height
        boundsBehavior: Flickable.StopAtBounds

        Flow {
            id: flow
            width: parent.width
            Repeater {
                id: repeater
                model: DelegateModel {
                    id: delegateModel
                    delegate: DraggableItemDelegate {
                        id: itemDelegate
                        // index in view
                        visualIndex: DelegateModel.itemsIndex
                        delegateData: modelData
                        content: root.delegate
                        view: root

                        highlight: Item {}
                        enabled: root.dragEnabled

                        onMove: {
                            delegateModel.items.move(first, second)
                            if(second > first) {
                                delegateModel.items.move(second - 1, first)
                            } else {
                                delegateModel.items.move(second + 1, first)
                            }
                            root.move(first, second)
                        }
                        drag.onActiveChanged: if(!drag.active) root.drop()
                    }
                }

            }
            move: Transition {
                NumberAnimation {
                    properties: "x,y"
                    duration: 200
                    easing.type: Easing.InOutQuad
                }
            }
            add: move
            populate: move
        }
    }
}
