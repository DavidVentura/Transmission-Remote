import QtQuick 2.12
import io.thp.pyotherside 1.3
import QtQuick.Controls 2.12

import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

import "../components"

Page {
    property bool searchMode: false
    header: PageHeader {
        title: "Torrents"
        contents: Item {
            anchors.fill: parent
            anchors.margins: units.gu(1)
            Label {
                visible: !searchMode
                anchors.verticalCenter: parent.verticalCenter
                text: "Torrents"
            }
            TextField {
                anchors.fill: parent
                id: torrentFilter
                text: ""
                placeholderText: "Filter.."
                visible: searchMode
                onTextChanged: {

                    loadTorrents()
                    timer.restart()
                }
            }
        }

        leadingActionBar.actions: [
            Action {
                iconName: "contextual-menu"
            }
        ]
        trailingActionBar.actions: [

            Action {
                iconName: "add"
                onTriggered: {
                    PopupUtils.open(Qt.resolvedUrl("../popups/AddTorrent.qml"),
                                    null, {})
                }
            },
            Action {
                id: sort
                iconName: "filters"
                onTriggered: {
                    menu.open()
                }
            },
            Action {
                iconName: "toolkit_input-search"
                onTriggered: {
                    searchMode = !searchMode
                    torrentFilter.forceActiveFocus()
                }
            }
        ]
    }
    Menu {
        id: menu
        width: units.gu(20)
        x: parent.width - width
        y: parent.header.height

        background: Rectangle {
            id: bgRectangle

            layer.enabled: true
            layer.effect: DropShadow {
                width: bgRectangle.width
                height: bgRectangle.height
                x: bgRectangle.x
                y: bgRectangle.y
                visible: bgRectangle.visible

                source: bgRectangle

                horizontalOffset: 0
                verticalOffset: 5
                radius: 10
                samples: 20
                color: "#999"
            }
        }

        MenuItem {
            Label {
                text: i18n.tr("Active")
                anchors {
                    left: parent.left
                    leftMargin: units.gu(1)
                    verticalCenter: parent.verticalCenter
                }
                height: units.gu(2)
            }
            onTriggered: {
                console.log("sh")
            }
        }
    }
    ListView {
        anchors.topMargin: parent.header.height
        anchors.fill: parent
        model: ListModel {
            id: listModel
        }
        delegate: TorrentItem {
            name: listModel.get(index).name
            progress: listModel.get(index).progress
            status: listModel.get(index).status
            eta: listModel.get(index).eta

            size_when_done: sizeWhenDone.toString()
        }
    }

    Timer {
        id: timer
        repeat: true
        interval: 5000
        onTriggered: loadTorrents()
    }

    function loadTorrents() {
        python.call("main.list_torrents", [torrentFilter.text],
                    function (items) {
                        listModel.clear()
                        for (var i = 0; i < items.length; i++) {
                            listModel.append(items[i])
                        }
                    })
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            importModule('main', function () {

                loadTorrents()
            })
        }
    }
}
