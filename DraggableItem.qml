import QtQuick 2.0

// Draggable Item (all draggable content should be inherited from it)
Item {
    id: root
    signal dragChanged(var drag)
    property Component highlight
}
