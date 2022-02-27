#ifndef TASKSLIST_H
#define TASKSLIST_H

#include <QObject>
#include <QVector>
#include <QDate>
//#include <QDebug>

struct TaskItem{
    bool done;
    QString description;
    QDate date;
    uint8_t progress;

    bool operator ==(const TaskItem &other) const
    {
       return std::tie(other.done, other.description, other.date, other.progress) ==
               std::tie(done, description, date, progress);
    }

    bool operator < (const TaskItem &other) const
    {
       return std::tie(other.done, other.description, other.date, other.progress) <
               std::tie(done, description, date, progress);
    }
};

class TasksList : public QObject
{
    Q_OBJECT
public:
    explicit TasksList(QObject *parent = nullptr);

    QVector<TaskItem> items() const;

    bool setItemAt(int index, const TaskItem &item);

    Q_INVOKABLE
    const int getTotalTasksCount();

    //void debug_debug(const QVector<TaskItem>&, bool);

signals:
    void on_preItemAppended();
    void on_postItemAppended();

    void on_preItemRemoved(int index);
    void on_postItemRemoved();

public slots:
    void appendItem(const QDate&);
    void removeCompletedItems();

    void writeDataToSQLiteBase();

    void updateCurrentItems(const QDate&);

private:
    QVector<TaskItem> mFullDataItems;
    QVector<TaskItem> mCurrentItems;

    void getDataFromDB();
    void updateFullDataItems();



};

#endif // TASKSLIST_H
