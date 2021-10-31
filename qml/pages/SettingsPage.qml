import QtQuick 2.12
import QtQuick.Layouts 1.12

import QtQuick.Controls 2.12
import Qt.labs.settings 1.0

import Ubuntu.Components 1.3

Page {
    header: PageHeader {
        title: i18n.tr("Settings")
    }
    Settings {
        id: settings
        property string host
        property bool use_ssl: true
        property int port
    }
    Column {
        anchors.fill: parent
        anchors.margins: units.gu(2)
        anchors.topMargin: parent.header.height + anchors.margins
        spacing: units.gu(2)

        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            Label {
                text: i18n.tr("Hostname")
                Layout.fillWidth: true
            }
            TextField {
                text: settings.host
                onTextChanged: settings.setValue("host", text)
            }
        }
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            Label {
                text: i18n.tr("Port")
                Layout.fillWidth: true
            }
            TextField {
                text: settings.value("port")
                inputMethodHints: Qt.ImhDigitsOnly
                onTextChanged: settings.setValue("port", parseInt(text))
            }
        }
        RowLayout {
            anchors.left: parent.left
            anchors.right: parent.right
            Label {
                text: i18n.tr("Use SSL")
                Layout.fillWidth: true
            }

            Switch {
                onCheckedChanged: settings.setValue("use_ssl", checked)

                checked: settings.use_ssl
            }
        }
    }
}
