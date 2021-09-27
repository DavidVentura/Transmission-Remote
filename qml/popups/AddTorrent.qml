import QtQuick 2.0
import Ubuntu.Components 1.3 as UITK
import Ubuntu.Components.Popups 1.3
import io.thp.pyotherside 1.3

Dialog {
    id: dialog
    property bool pathOk: false
    Column {
        spacing: units.gu(1)

        UITK.Button {
            enabled: magnet.text === ""
            text: "Pick a torrent file"
            anchors.left: parent.left
            anchors.right: parent.right
        }
        UITK.Label {
            text: "OR"
            anchors.horizontalCenter: parent.horizontalCenter
            textSize: UITK.Label.Small
        }
        UITK.Label {
            text: "Magnet"
        }
        UITK.TextField {
            id: magnet
            anchors.left: parent.left
            anchors.right: parent.right
            onTextChanged: error.text = ""
        }

        UITK.Label {
            anchors.left: parent.left
            anchors.right: parent.right
            text: "Destination folder"
        }
        UITK.Label {
            id: destinationDetails
            anchors.left: parent.left
            anchors.right: parent.right
            text: ""
            font.pixelSize: units.gu(1.5)
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        UITK.TextField {
            id: downloadPath
            anchors.left: parent.left
            anchors.right: parent.right
            text: "/media/downloads"
            onTextChanged: {
                if (error !== null) {
                    error.text = ""
                }
                if (python === null)
                    return
                checkSpace()
            }
        }
        UITK.Label {
            id: error
            visible: text.length > 0
            anchors.left: parent.left
            anchors.right: parent.right
            text: ""
            font.pixelSize: units.gu(1.5)
            color: "red"
            wrapMode: Text.WrapAtWordBoundaryOrAnywhere
        }

        UITK.Button {
            enabled: pathOk
            anchors.right: parent.right
            anchors.left: parent.left
            text: "Confirm"
            color: "green"
            onClicked: {
                if (magnet.text === "") {
                    python.call("main.add_torrent",
                                [torrentPath, downloadPath.text],
                                function (err) {
                                    if (err === null) {
                                        PopupUtils.close(dialog)
                                        return
                                    }
                                    error.text = err
                                })
                } else {
                    python.call("main.add_magnet",
                                [magnet.text, downloadPath.text],
                                function (err) {
                                    if (err === null || err === undefined) {
                                        PopupUtils.close(dialog)
                                        return
                                    }
                                    error.text = err
                                })
                }
            }
        }
        UITK.Button {
            anchors.right: parent.right
            anchors.left: parent.left
            text: "Cancel"
            onClicked: {
                PopupUtils.close(dialog)
            }
        }
    }
    function checkSpace() {
        python.call("main.free_space", [downloadPath.text], function (res) {
            pathOk = res[0]
            destinationDetails.text = res[1]
        })
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            importModule('main', function () {
                checkSpace()
            })
        }
    }
}
