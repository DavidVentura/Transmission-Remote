import QtQuick 2.12
import io.thp.pyotherside 1.3
import QtQuick.Controls 2.12
import Qt.labs.settings 1.0

import Ubuntu.Components.Popups 1.3
import Ubuntu.Components 1.3 as UITK
import QtGraphicalEffects 1.0

import "../components"

UITK.Page {
    property bool searchMode: false
    property bool connected: false
    property string torrentStatus: null

    Settings {
        id: settings
        property string host
        property bool use_ssl: true
        property int port: 443
    }

    header: UITK.PageHeader {
        title: i18n.tr("Torrents")
        contents: Item {
            anchors.fill: parent
            anchors.topMargin: units.gu(1)
            anchors.bottomMargin: units.gu(1)
            UITK.Label {
                visible: !searchMode
                anchors.verticalCenter: parent.verticalCenter
                textSize: Label.Large
                text: i18n.tr("Torrents")
            }
            UITK.TextField {
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
            UITK.Action {
                iconName: "settings"
                onTriggered: stack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
        ]
        trailingActionBar.actions: [

            UITK.Action {
                enabled: connected
                iconName: "add"
                onTriggered: {
                    PopupUtils.open(Qt.resolvedUrl("../popups/AddTorrent.qml"),
                                    null, {})
                }
            },
            UITK.Action {
                enabled: connected
                id: sort
                iconName: "filters"
                onTriggered: {
                    menu.open()
                }
            },
            UITK.Action {
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
        MenuPanelItem {
            label: i18n.tr("All")
            iconName: torrentStatus == "" ? "tick" : ""
            onTriggered: {
                torrentStatus = ""
                loadTorrents()
            }
        }
        MenuPanelItem {
            label: i18n.tr("Downloading")
            iconName: torrentStatus == "downloading" ? "tick" : ""
            onTriggered: {
                torrentStatus = "downloading"
                loadTorrents()
            }
        }
        MenuPanelItem {
            label: i18n.tr("Seeding")
            iconName: torrentStatus == "seeding" ? "tick" : ""
            onTriggered: {
                torrentStatus = "seeding"
                loadTorrents()
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
            name: model.name
            progress: model.progress
            status: model.status
            eta: model.eta

            size_when_done: sizeWhenDone.toString()
            onDeleted: PopupUtils.open(Qt.resolvedUrl(
                                           "../popups/DeleteTorrent.qml"),
                                       null, {
                                           "itemName": model.name,
                                           "itemID": model.id
                                       })
            onSettingsClicked: stack.push(Qt.resolvedUrl("TorrentDetails.qml"),
                                          {
                                              "itemName": name,
                                              "itemID": model.id
                                          })
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
        python.call("main.list_torrents", [torrentFilter.text, torrentStatus],
                    function (items) {
                        if (items.length < listModel.count) {
                            listModel.clear()
                        }
                        const itemCount = listModel.count

                        for (var i = 0; i < items.length; i++) {
                            if (i >= itemCount) {
                                listModel.append(items[i])
                            } else {
                                listModel.set(i, items[i])
                            }
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
