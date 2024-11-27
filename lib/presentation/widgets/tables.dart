import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lm_teams_app/presentation/widgets/avatars.dart';
import '../../logic/cubits/statistics_tab_cubit.dart';

class AppStatisticsTable extends StatefulWidget {
  const AppStatisticsTable({
    Key? key,
    required this.tableData,
    this.fixedColWidth = 50.0,
    this.cellWidth = 80.0,
    this.cellHeight = 30.0,
    this.cellMargin = 10.0,
    this.cellSpacing = 10.0,
    required this.borderColor,
  }) : super(key: key);

  final TableData tableData;
  final double fixedColWidth;
  final double cellWidth;
  final double cellHeight;
  final double cellMargin;
  final double cellSpacing;
  final Color borderColor;

  @override
  State<AppStatisticsTable> createState() => _AppStatisticsTableState();
}

class _AppStatisticsTableState extends State<AppStatisticsTable> {
  final _columnController = ScrollController();
  final _rowController = ScrollController();
  final _subTableYController = ScrollController();
  final _subTableXController = ScrollController();

  @override
  void initState() {
    _subTableXController.addListener(() {
      _rowController.jumpTo(_subTableXController.position.pixels);
    });
    _subTableYController.addListener(() {
      _columnController.jumpTo(_subTableYController.position.pixels);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: double.infinity,
        height: getTableHeight(widget.tableData.dispensedBooks.length),
        child: Column(children: [
          Row(children: [
            //fixed corner cell
            DataTable(
                border: _buildBorder(bottom: true, right: true),
                horizontalMargin: widget.cellMargin,
                columnSpacing: widget.cellHeight,
                headingRowHeight: widget.cellHeight,
                dataRowMinHeight: widget.cellHeight,
                columns: [
                  DataColumn(label: SizedBox(width: widget.fixedColWidth, child: const Text('')))
                ],
                rows: const []),
            //fixed row of member names
            Flexible(
                child: SingleChildScrollView(
              controller: _rowController,
              scrollDirection: Axis.horizontal,
              physics: const NeverScrollableScrollPhysics(),
              child: DataTable(
                  border: _buildBorder(verticalInside: true, bottom: true),
                  horizontalMargin: widget.cellMargin,
                  columnSpacing: widget.cellSpacing,
                  headingRowHeight: widget.cellHeight,
                  dataRowMinHeight: widget.cellHeight,
                  columns: widget.tableData.selectedMembers.isNotEmpty
                      ? widget.tableData.selectedMembers
                          .map((member) => DataColumn(
                              label: SizedBox(
                                  width: widget.cellWidth,
                                  child: Tooltip(
                                      message: member.name,
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                                        Avatar(
                                            isCircle: true,
                                            size: Size(15.0.spMin, 15.0.spMin),
                                            image: member.user?.image,
                                            placeholder: Text(
                                                member.user?.initials ??
                                                    member.user?.firstName ??
                                                    "Unknown",
                                                style: TextStyle(fontSize: 5.0.spMin))),
                                        SizedBox(width: 5.0.spMin),
                                        Text(member.initials)
                                      ])))))
                          .toList()
                      : [DataColumn(label: _buildEmptyCell(widget.cellWidth))],
                  rows: const []),
            ))
          ]),
          Expanded(
              child: Row(children: [
            //fixed book code column
            SingleChildScrollView(
                controller: _columnController,
                scrollDirection: Axis.vertical,
                physics: const NeverScrollableScrollPhysics(),
                child: DataTable(
                    border: _buildBorder(right: true),
                    horizontalMargin: widget.cellMargin,
                    columnSpacing: widget.cellSpacing,
                    headingRowHeight: widget.cellHeight,
                    dataRowMinHeight: widget.cellHeight,
                    columns: [
                      DataColumn(
                          label: SizedBox(
                              width: widget.fixedColWidth,
                              child: widget.tableData.dispensedBooks.isNotEmpty
                                  ? Tooltip(
                                      message: widget.tableData.dispensedBooks.first.name,
                                      triggerMode: TooltipTriggerMode.tap,
                                      child: Row(
                                        children: [
                                          Avatar(
                                              image: widget.tableData.dispensedBooks.first.image,
                                              placeholder: Text(
                                                  _code(widget.tableData.dispensedBooks.first.code),
                                                  style: TextStyle(fontSize: 8.0.spMin)),
                                              size: Size(15.spMin, 20.spMin)),
                                          SizedBox(width: 5.0.spMin),
                                          Text(_code(widget.tableData.dispensedBooks.first.code)),
                                        ],
                                      ))
                                  : _buildEmptyCell(widget.fixedColWidth)))
                    ],
                    rows: widget.tableData.dispensedBooks.length > 1
                        ? widget.tableData.dispensedBooks
                            .skip(1)
                            .map((item) => DataRow(cells: [
                                  DataCell(SizedBox(
                                      width: widget.fixedColWidth,
                                      child: Tooltip(
                                          message: item.name,
                                          triggerMode: TooltipTriggerMode.tap,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Avatar(
                                                  image: item.image,
                                                  placeholder: Text(_code(item.code),
                                                      style: TextStyle(fontSize: 8.0.spMin)),
                                                  size: Size(15.spMin, 20.spMin)),
                                              SizedBox(width: 5.0.spMin),
                                              Text(_code(item.code))
                                            ],
                                          ))))
                                ]))
                            .toList()
                        : [])),
            //subtable
            Flexible(
                child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    controller: _subTableXController,
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        controller: _subTableYController,
                        scrollDirection: Axis.vertical,
                        child: Material(
                            color: Colors.transparent,
                            child: DataTable(
                                border: _buildBorder(verticalInside: true),
                                horizontalMargin: widget.cellMargin,
                                columnSpacing: widget.cellSpacing,
                                headingRowHeight: widget.cellHeight,
                                dataRowMinHeight: widget.cellHeight,
                                columns: widget.tableData.quantityList.isNotEmpty
                                    ? widget.tableData.quantityList.first
                                        .map((i) => DataColumn(
                                            label: SizedBox(
                                                width: widget.cellWidth,
                                                child: Text(i.toString()))))
                                        .toList()
                                    : [DataColumn(label: _buildEmptyCell(widget.cellWidth))],
                                rows: widget.tableData.quantityList.length > 1
                                    ? widget.tableData.quantityList
                                        .skip(1)
                                        .map((row) => DataRow(
                                            cells: row
                                                .map((i) => DataCell(SizedBox(
                                                    width: widget.cellWidth,
                                                    child: Text(i.toString()))))
                                                .toList()))
                                        .toList()
                                    : [])))))
          ]))
        ]));
  }

  double getTableHeight(int length) {
    const headerHeight = 32.0;
    const cellHeight = 30.0;
    final calculatedHeight = cellHeight * length + headerHeight;

    return calculatedHeight.clamp(32.0, 150.0);
  }

  TableBorder _buildBorder({
    bool top = false,
    bool left = false,
    bool right = false,
    bool bottom = false,
    bool verticalInside = false,
  }) {
    return TableBorder(
      top: top ? BorderSide(color: widget.borderColor) : BorderSide.none,
      left: left ? BorderSide(color: widget.borderColor) : BorderSide.none,
      right: right ? BorderSide(color: widget.borderColor) : BorderSide.none,
      bottom: bottom ? BorderSide(color: widget.borderColor) : BorderSide.none,
      verticalInside: verticalInside ? BorderSide(color: widget.borderColor) : BorderSide.none,
    );
  }

  Widget _buildEmptyCell(double width) {
    return SizedBox(width: width);
  }
}

String _code(String? code) {
  if (code == null) {
    return 'N/A';
  }
  return code.length >= 2 ? code.substring(0, 2) : code;
}
