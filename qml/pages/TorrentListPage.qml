import QtQuick 2.12
import io.thp.pyotherside 1.3
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0

import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3
import QtGraphicalEffects 1.0

import "../components"

Page {
    property bool searchMode: false
    property bool connected: false
    Settings {
        id: settings
        property string host
        property bool use_ssl: true
        property int port: 443
    }

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
                iconName: "settings"
                onTriggered: stack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        ]
        trailingActionBar.actions: [

            Action {
                enabled: connected
                iconName: "add"
                onTriggered: {
                    PopupUtils.open(Qt.resolvedUrl("../popups/AddTorrent.qml"),
                                    null, {})
                }
            },
            Action {
                enabled: connected
                id: sort
                iconName: "filters"
                onTriggered: {
                    menu.open()
                }
            },
            Action {
                enabled: connected
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
        visible: connected
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

    Column {
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: units.gu(2)
        spacing: units.gu(1)

        Label {
            id: connectedLabel
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !connected
            text: "Not connected. Check settings."
            wrapMode: Label.WordWrap
        }
        Label {
            id: connectionErrorLabel
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !connected
            text: ""
            color: "red"
            font.bold: true
            wrapMode: Label.WrapAtWordBoundaryOrAnywhere
        }
        Button {
            anchors.left: parent.left
            anchors.right: parent.right
            visible: !connected
            text: "Connect"
            onClicked: connect()
        }
    }

    Timer {
        id: timer
        running: connected
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
    function connect() {
        if (settings.host === null || settings.host === undefined) {
            connectionErrorLabel.text = "Host is unset"
            return
        }

        python.call('main.connect', [settings.value("host"), settings.value(
                                         "port"), settings.value("use_ssl")],
                    function (ret) {
                        console.log(ret)
                        var success = ret[0]
                        var error = ret[1]
                        if (success) {
                            connected = true
                            loadTorrents()
                            return
                        }
                        connectionErrorLabel.text = error
                    })
    }

    Python {
        id: python
        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl('../../src/'))
            importModule('main', function () {
                connect()
            })
        }
    }
}
