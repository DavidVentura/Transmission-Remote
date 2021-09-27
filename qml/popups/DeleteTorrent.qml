import QtQuick 2.0
import QtQuick.Layouts 1.12
import Ubuntu.Components 1.3 as UITK
import Ubuntu.Components.Popups 1.3
import io.thp.pyotherside 1.3

Dialog {
    id: dialog
    property string itemName
    property int itemID

    Column {
        spacing: units.gu(1)
        UITK.Label {
            text: "Delete " + itemName
            wrapMode: UITK.Label.WrapAtWordBoundaryOrAnywhere
            anchors.left: parent.left
            anchors.right: parent.right
        }
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            UITK.Label {
                Layout.fillWidth: true
                text: "Delete data"
            }
            UITK.Switch {
                checked: false
                id: deleteData
            }
        }

        UITK.Button {
            text: "Delete"
            anchors.left: parent.left
            anchors.right: parent.right
            color: "#ED3146"
            onTriggered: {
                python.call("main.delete_torrent",
                            [itemID, deleteData.checked], function () {
                                PopupUtils.close(dialog)
                            })
            }
        }
        UITK.Button {
            text: "Cancel"
            anchors.left: parent.left
            anchors.right: parent.right
            onTriggered: PopupUtils.close(dialog)
        }
    }
    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            importModule('main', function () {})
        }
    }
}
