import 'package:filesize/filesize.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:rutorrentflutter/AppTheme/AppStateNotifier.dart';
import 'package:rutorrentflutter/models/history_item.dart';
import 'package:rutorrentflutter/ui/shared/shared_styles.dart';
import 'package:rutorrentflutter/ui/views/History/history_viewmodel.dart';
import 'package:rutorrentflutter/ui/widgets/dumb_widgets/loading_shimmer.dart';
import 'package:stacked/stacked.dart';

class HistoryView extends StatelessWidget {
 const HistoryView({Key? key}) : super(key: key);

 @override
 Widget build(BuildContext context) {
   return ViewModelBuilder<HistoryViewModel>.reactive(
     builder: (context, model, child) => Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: TextStyle(fontWeight: FontWeight.w400),
        ),
        actions: <Widget>[
          PopupMenuButton<String>(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(Icons.filter_list),
            ),
            itemBuilder: (context) {
              return model.choices
                  .map((e) => PopupMenuItem<String>(
                        value: e,
                        child: Text(
                          e,
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ))
                  .toList();
            },
            onSelected: (e) {
              model.loadHistoryItems(lastHrs: int.parse(e.split(' ')[2]));
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: model.isBusy
            ? LoadingShimmer().loadingEffect(context)
            : (model.items.length != 0)
                ? ListView.builder(
                    itemCount: model.items.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        onLongPress: () {
                          _showRemoveDialog(model.items[index].hash,model,context);
                        },
                        title: SizedBox(
                            width: 40,
                            child: Text(model.items[index].name,
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600))),
                        trailing: Container(
                          padding: const EdgeInsets.all(4),
                          width: 70,
                          decoration: BoxDecoration(
                              border: Border.all(
                            color: getHistoryStatusColor(
                                context, model.items[index].action),
                          )),
                          child: Text(
                              HistoryItem.historyStatus[model.items[index].action]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: getHistoryStatusColor(
                                    context, model.items[index].action),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                        subtitle: Text(
                          '${DateFormat('HH:mm dd MMM yy').format(DateTime.fromMillisecondsSinceEpoch(model.items[index].actionTime * 1000))} | ${filesize(model.items[index].size)}',
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      );
                    },
                  )
                : Center(
                    child: SvgPicture.asset(
                      Theme.of(context).brightness == Brightness.light
                          ? 'assets/logo/empty.svg'
                          : 'assets/logo/empty_dark.svg',
                      width: 120,
                      height: 120,
                    ),
                  ),
      ),
    ),
     viewModelBuilder: () => HistoryViewModel(),
   );
 }

 Color getHistoryStatusColor(BuildContext context, int action) {
    switch (action) {
      case 1: // Added
        return Theme.of(context).accentColor;
      case 2: // Finished
        return !AppStateNotifier.isDarkModeOn
            ? kGreenActiveLT
            : kGreenActiveDT;
      case 3: // Deleted
        return !AppStateNotifier.isDarkModeOn
            ? kRedErrorLT
            : kRedErrorDT;
      default:
        return !AppStateNotifier.isDarkModeOn
            ? Colors.black
            : Colors.white;
    }
  }

  _showRemoveDialog(String hashValue,HistoryViewModel model,context) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(
                'Remove torrent from history',
                style: TextStyle(fontSize: 15),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Yes!',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: ()=> model.removeHistoryItem(hashValue),
                ),
                TextButton(
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).accentColor),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ));
  }
}