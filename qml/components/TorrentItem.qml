import Ubuntu.Components 1.3 as UITK
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Shapes 1.12
import QtQuick 2.12

UITK.ListItem {
    property string name
    property int id
    property string status
    property string eta
    property string size_when_done
    property double progress

    signal deleted
    signal settingsClicked

    leadingActions: UITK.ListItemActions {
        actions: [
            UITK.Action {
                iconName: "delete"
                onTriggered: deleted()
            }
        ]
    }
    trailingActions: UITK.ListItemActions {
        actions: [
            UITK.Action {
                iconName: "settings"
                onTriggered: settingsClicked()
            }
        ]
    }

    height: units.gu(8)
    RowLayout {
        anchors.margins: units.gu(1)
        anchors.fill: parent
        Shape {
            id: shape
            height: units.gu(5)
            layer.enabled: true
            layer.samples: 16
            width: units.gu(6)

            ShapePath {
                fillColor: "transparent"
                strokeColor: "green"
                strokeWidth: units.gu(0.2)
                capStyle: ShapePath.RoundCap
                PathAngleArc {
                    centerX: shape.width / 2
                    centerY: shape.height / 2
                    radiusX: units.gu(2)
                    radiusY: units.gu(2)
                    startAngle: -90
                    sweepAngle: progress * 3.6
                }
            }
            ShapePath {
                fillColor: "transparent"
                strokeColor: Theme.palette.normal.backgroundTertiaryText
                strokeWidth: units.gu(0.2)
                capStyle: ShapePath.RoundCap
                PathAngleArc {

                    centerX: shape.width / 2
                    centerY: shape.height / 2
                    radiusX: units.gu(2)
                    radiusY: units.gu(2)
                    startAngle: -90 + progress * 3.6
                    sweepAngle: 270 - startAngle
                }
            }
        }

        Column {
            Layout.fillWidth: true
            spacing: units.gu(0.2)
            UITK.Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.bold: true
                text: name
                elide: UITK.Label.ElideRight
            }
            UITK.Label {
                anchors.left: parent.left
                anchors.right: parent.right
                text: size_when_done + (["unknown", "not available"].indexOf(
                                            eta) !== -1 ? "" : " - " + eta)
                font.pixelSize: units.gu(1.2)
            }
            UITK.Label {
                anchors.left: parent.left
                anchors.right: parent.right
                font.bold: true
                text: status
                font.pixelSize: units.gu(1.2)
            }
        }
    }
}
