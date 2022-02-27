#include "tasksmodel.h"
#include "taskslist.h"

TasksModel::TasksModel(QObject *parent)
    : QAbstractListModel { parent },
      mList { nullptr }
{

}

int TasksModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid() || !mList)
        return 0;

    return mList->items().size();
}

QVariant TasksModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || !mList)
        return QVariant();

    const TaskItem item { mList->items().at(index.row()) };
    switch (role){

    case DoneRole:
        return QVariant(item.done);
    case DescriptionRole:
        return QVariant(item.description);
    case DateRole:
        return QVariant(item.date);
    case ProgressRole:
        return QVariant(item.progress);
    }

    return QVariant();
}

bool TasksModel::setData(const QModelIndex &index, const QVariant &value, int role)
{
    if (!mList)
        return false;

    TaskItem item { mList->items().at(index.row()) };
    switch (role){
    case DoneRole:
        item.done = value.toBool();
        break;
    case DescriptionRole:
        item.description = value.toString();
        break;
    case DateRole:
        item.date = value.toDate();
        break;
    case ProgressRole:
        item.progress = value.toUInt();
        break;
    }

    if (mList->setItemAt(index.row(), item)) {
        emit dataChanged(index, index, QVector<int>() << role);
         return true;
    }
    return false;
}

Qt::ItemFlags TasksModel::flags(const QModelIndex &index) const
{
    if (!index.isValid())
        return Qt::NoItemFlags;

    return Qt::ItemIsEditable;
}

QHash<int, QByteArray> TasksModel::roleNames() const
{
   QHash<int, QByteArray> names;

   names[DoneRole] = "done";
   names[DescriptionRole] = "description";
   names[DateRole] = "date";
   names[ProgressRole] = "progress";

   return names;
}

TasksList *TasksModel::list() const
{
    return mList;
}

void TasksModel::setList(TasksList *list)
{
    beginResetModel();

    if (mList)
        mList->disconnect(this);

    mList = list;

    if (mList)
    {
        connect(mList, &TasksList::on_preItemAppended, this, [=]{
            const int index { mList->items().size() };
            beginInsertRows(QModelIndex(), index, index);
        });

        connect(mList, &TasksList::on_postItemAppended, this, [=]{
            endInsertRows();
        });

        connect(mList, &TasksList::on_preItemRemoved, this, [=](int index){
            beginRemoveRows(QModelIndex(), index, index);
        });

        connect(mList, &TasksList::on_postItemRemoved, this, [=]{
            endRemoveRows();
        });

    }
    endResetModel();
}
