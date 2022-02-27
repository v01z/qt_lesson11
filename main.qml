import QtQuick 2.12
import QtQuick.Layouts 1.3
import QtQuick.Controls 2.5
import QtQuick.Window 2.12
import QtQuick.Controls 1.4 //for calendar
import QtQuick.Dialogs 1.2
import ru.geekbrains 1.0

Window {
    id: root
    width: calendar.width + frameList.width + 30
    height: calendar.height + frameButtons.height + buttonClose.height + 50
    visible: true
    title: qsTr("Органайзер")
    Frame{
        id: frameMain
        anchors.fill: parent

        Calendar{
            id: calendar
            onClicked: {
                labelDate.text = qsTr("Выбранная дата: ") +
                        Qt.formatDate(calendar.selectedDate, "dd.MM.yyyy")

                listView.model.list.updateCurrentItems(calendar.selectedDate)
                listView.model.list = tasksList
                labelTotalCount.text = qsTr("Всего заданий: ")
                        + tasksList.getTotalTasksCount()
            }
        }
        Label {
            id: labelDate
            anchors.left: calendar.right
            anchors.leftMargin: 10
            anchors.topMargin: 10
            text: qsTr("Выбранная дата: ") +
                  Qt.formatDate(new Date(), "dd.MM.yyyy")
        }

        Label {
            id: labelTotalCount
            anchors.top: labelDate.bottom
            anchors.left: calendar.right
            anchors.leftMargin: 10
            text: qsTr("Всего заданий: ") + tasksList.getTotalTasksCount()
        }
        Frame{
            id: frameList
            anchors.left: calendar.right
            anchors.top: labelTotalCount.bottom
            anchors.topMargin: 5
            anchors.leftMargin: 10
            height: calendar.height - labelDate.height
                    - labelDate.anchors.topMargin -
                    labelTotalCount.height

            ListView{
                id: listView
                implicitWidth: 330
                implicitHeight: 200
                clip: true

                model: TasksModel {
                    list: tasksList
                }

                delegate: RowLayout{
                    width: listView.width

                    CheckBox{
                        id: checkBoxTaskStatus
                        checked: model.done
                        onClicked: model.done = checked
                    }

                    Slider{
                        id: slider
                        minimumValue: 0
                        value: model.progress
                        maximumValue: 10
                        stepSize: 1
                        onValueChanged: {
                            labelProgress.text = value

                            if (value === 10)
                            {
                                checkBoxTaskStatus.checked = true
                                model.done = true
                            }
                            if(value < 10)
                            {
                                checkBoxTaskStatus.checked = false
                                model.done = false
                            }

                            model.progress = value

                        }
                    }

                    Label{
                        id: labelProgress
                        text: model.progress

                    }
                    TextField{
                        id: textFieldDescr
                        text: model.description
                        onEditingFinished: model.description = text
                        Layout.fillWidth: true
                        onAccepted: {
                            labelTotalCount.text = qsTr("Всего заданий: ")
                                    + tasksList.getTotalTasksCount()

                        }
                    }
                    TextField{
                        id: textFieldDate
                        text: model.date
                        visible: false
                    }
                }
            }
        }
        Frame{
            id: frameButtons
            anchors.top: calendar.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            RowLayout{
                MessageDialog{
                    id: warningDialog
                    title: qsTr("Внимание")
                    icon: StandardIcon.Warning
                    text: qsTr("Нельзя запланировать задания в прошлом.\nНо их можно удалить.")
                }

                RoundButton{
                    id: btnAdd
                    text: qsTr("Добавить задание")
                    palette{
                        button: "steelblue"
                        buttonText: "white"
                    }
                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Спланировать новое задание")
                    onClicked: {

                        if (calendar.selectedDate.getDate() >= (new Date()).getDate()) //current day
                        {
                            tasksList.appendItem(calendar.selectedDate)

                            labelTotalCount.text =  qsTr("Всего заданий: ")
                                    + tasksList.getTotalTasksCount() +
                                    "<font color=\"red\"> +1 (создаётся)</font>"
                        }
                        else
                        {
                            console.log("dialog here")
                            warningDialog.open()

                        }
                    }

                }
                RoundButton {
                    id: btnRemove
                    text: qsTr("Удалить отмеченные задания")
                    palette{
                        button: "steelblue"
                        buttonText: "white"
                    }

                    ToolTip.visible: hovered
                    ToolTip.text: qsTr("Удалить выполненные либо ошибочно введённые")
                    onClicked:  {
                        tasksList.removeCompletedItems()
                        labelTotalCount.text = qsTr("Всего заданий: ")
                                + tasksList.getTotalTasksCount()
                    }
                }
            }
        }
        Frame{
            anchors.top: frameButtons.bottom
            anchors.topMargin: 5
            anchors.horizontalCenter: parent.horizontalCenter
            RowLayout{
                RoundButton{
                    id: buttonDisplayTasks
                    text: qsTr("Показать список задач")
                    palette{
                        button: "steelblue"
                        buttonText: "white"
                    }

                    onClicked: {
                        var component = Qt.createComponent("tasks_display.qml")
                        var window    = component.createObject(root)
                        window.show()
                    }
                }
                RoundButton{
                    id: buttonClose
                    text: qsTr("Выход")
                    palette{
                        button: "steelblue"
                        buttonText: "white"
                    }

                    onClicked: {
                        listView.model.list.writeDataToSQLiteBase()
                        close()
                    }
                }

            }
        }
    }
}
