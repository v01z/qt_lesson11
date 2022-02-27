import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Window 2.12
import ru.geekbrains 1.0

Window {
    id: displayWindow
    title: qsTr("Список задач")
    height: 150
    width: 600
    Frame{
        id: mainFrame
        anchors.fill: parent
        Frame{
            id: displayTasksFrame
            width: parent.width
            height: parent.height - bottomFrame.height

            Label{
                id: dateColumnName
                text: qsTr("  Дата  ")
            }
            Label{
                id: progressColumnName
                anchors.left: dateColumnName.right
                text: qsTr("  Прогресс  ")

            }
            Label{
                text: qsTr("  Задача  ")
                anchors.left: progressColumnName.right
            }

            ListView{
                id: viewList
                anchors.top: dateColumnName.bottom
                height: parent.height - dateColumnName.height
                implicitHeight: 200

                model: TasksModel{
                    list: tasksList
                }

                delegate: RowLayout{
                    width: parent.width
                    Component.onCompleted: {
                        displayWindow.height = displayWindow.height + dateLabel.height
                    }

                    Label{
                        id: dateLabel
                        text: "\n" + Qt.formatDate(model.date, "dd.MM.yyyy") + "  "
                    }
                    Label{
                        id: progressLabel
                        text: "\n" + model.progress + "  "
                    }

                    Label{
                        id: descrLabel
                        text: "\n" + model.description
                    }

                }

            }

        }
        Frame{
            id: bottomFrame
            anchors.top: displayTasksFrame.bottom
            anchors.horizontalCenter: parent.horizontalCenter

            RoundButton{
                id: closeButton
                text: qsTr("Закрыть")
                palette{
                    button: "steelblue"
                    buttonText: "white"
                }

                onClicked: {
                    close()
                }
            }

        }
    }
}
