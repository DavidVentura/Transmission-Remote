
/*
 * Copyright (C) 2021  David Ventura
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * tr is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
import QtQuick 2.7
import Ubuntu.Components 1.3 as UITK
import QtQuick.Layouts 1.3
import Qt.labs.settings 1.0

UITK.MainView {
    id: root
    objectName: 'mainView'
    applicationName: 'tr.davidv.dev'
    automaticOrientation: true

    width: units.gu(45)
    height: units.gu(75)

    UITK.PageStack {
        id: stack
        anchors.fill: parent
    }

    Component.onCompleted: stack.push(Qt.resolvedUrl(
                                          "pages/TorrentListPage.qml"))
}
