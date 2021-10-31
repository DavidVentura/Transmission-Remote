import QtQuick 2.12
import QtQuick.Layouts 1.12

import QtQuick.Controls 2.12
import Qt.labs.settings 1.0
import io.thp.pyotherside 1.3

import Ubuntu.Components 1.3

Page {
    property string itemName
    property int itemID

    header: PageHeader {
        title: i18n.tr("Torrent Details")
    }
    Column {
        id: col
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(2)
        anchors.topMargin: parent.header.height + anchors.margins
        spacing: units.gu(2)

        Label {
            text: itemName
            anchors.left: parent.left
            anchors.right: parent.right
            textSize: Label.Large
            wrapMode: Label.WrapAtWordBoundaryOrAnywhere
        }
        Label {
            text: i18n.tr("Files")
        }
    }
    ListView {
        anchors.bottom: parent.bottom
        anchors.top: col.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: units.gu(1)
        model: ListModel {
            id: listModel
        }
        delegate: ListItem {
            RowLayout {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.margins: units.gu(2)
                Switch {
                    enabled: false // not implemented
                    checked: model.selected
                }

                Label {
                    Layout.fillWidth: true
                    text: name
                    wrapMode: Label.WrapAtWordBoundaryOrAnywhere
                }
            }
        }
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            importModule('main', function () {
                call("main.list_files", [itemID], function (files) {
                    for (var i = 0; i < files.length; i++) {
                        listModel.append(files[i])
                    }
                })
            })
        }
    }
}
