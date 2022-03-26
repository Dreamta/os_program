import 'dart:math';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';

import 'button.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 分配页面数
  int memoryLen = 4;
  // 序列长度
  int exeNum = 15;
  // 缺页次数
  int faultPage = 0;
  List<int> initList = [];
  // 内存
  List<int> memory = [];
  int queueHead = 0;
  // 外存块数
  int storageLen = 9;
  // 存储内存数据
  List<Widget> tableList = [];
  //
  bool chartMod = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("操作系统课程设计"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
            Row(
              children: [
                myField(
                  "分配页面：",
                  (text) =>
                      text == "" ? memoryLen = 4 : memoryLen = int.parse(text),
                ),
                myField(
                    "执行次数：",
                    (text) =>
                        text == "" ? exeNum = 15 : exeNum = int.parse(text)),
              ],
            ),

            /// [按钮]
            Container(
              margin: EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  algButton(
                      text: "FIFO", onPressed: () => change(fifoAlgorithm)),
                  algButton(text: "OPT", onPressed: () => change(optAlgorithm)),
                  algButton(text: "LRU", onPressed: () => change(lruAlgorithm)),
                  Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: algButton(
                        text: "生成对比图表", onPressed: () => generateChart()),
                  ),
                ],
              ),
            ),

            /// [数据展示]
            Container(
              // margin: EdgeInsets.sonly(top: 10),
              child: SingleChildScrollView(
                // shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                child: chartMod
                    ? Container(
                        width: 500,
                        height: 200,
                        child: Row(
                          children: chartList,
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            tableList.length != 0
                                ? Container(
                                    margin: EdgeInsets.all(10),
                                    child: Text(
                                        "缺页率：${(faultPage / exeNum).toStringAsFixed(3)}"))
                                : Container(),
                            Row(
                              children: tableList,
                            )
                          ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // 返回不同页面数的缺页率
  List<LinearRate> generateAve(Function alg) {
    // List<int> aveFaultRate = [];
    memoryLen = 0;
    storageLen = 20;
    List<LinearRate> list = [];

    for (var i = 0; i < 7; i++) {
      double rate = 0;
      memoryLen++;
      for (var i = 0; i < 100; i++) {
        execute(alg);
        rate += faultPage / exeNum;
      }
      list.add(LinearRate(i + 1, rate / 100));
    }
    memoryLen = 4;
    storageLen = 9;
    // aveFaultRate.add(faultPage);
    return list;
  }

  List<Widget> chartList = [];
  generateChart() {
    chartList.clear();
    List<List<LinearRate>> aves = [];
    aves.add(generateAve(fifoAlgorithm));
    aves.add(generateAve(optAlgorithm));
    aves.add(generateAve(lruAlgorithm));
    chartList.add(Container(
      width: 400,
      child: charts.LineChart(
        _getSeriesData(aves),
        animate: true,
        defaultRenderer:
            new charts.LineRendererConfig(includeArea: false, stacked: false),
      ),
    ));
    setState(() {
      chartMod = true;
    });
  }

  _getSeriesData(List<List<LinearRate>> data) {
    List<charts.Series<LinearRate, num>> series = [
      charts.Series(
        id: "fifo",
        data: data[0],
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,

        domainFn: (LinearRate series, _) => series.pageNum,
        measureFn: (LinearRate series, _) => series.faultRate,
        // colorFn: (SalesData series, _) => charts.MaterialPalette.blue.shadeDefault
      ),
      charts.Series(
        id: "opt",
        data: data[1],
        colorFn: (_, __) => charts.MaterialPalette.yellow.shadeDefault,

        domainFn: (LinearRate series, _) => series.pageNum,
        measureFn: (LinearRate series, _) => series.faultRate,
        // colorFn: (SalesData series, _) => charts.MaterialPalette.blue.shadeDefault
      ),
      charts.Series(
        id: "lru",
        data: data[2],
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,

        domainFn: (LinearRate series, _) => series.pageNum,
        measureFn: (LinearRate series, _) => series.faultRate,
        // colorFn: (SalesData series, _) => charts.MaterialPalette.blue.shadeDefault
      )
    ];
    return series;
  }

  Container myField(String text, Function(String) onChange) {
    return Container(
        margin: EdgeInsets.all(5),
        height: 40,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                width: 80,
                child:
                    Center(child: Text(text, style: TextStyle(fontSize: 15)))),
            Container(width: 110, child: TextField(onChanged: onChange)),
          ],
        ));
  }

  List<Widget> generateTable(int index) {
    List<Widget> list = [];
    list.add(Text("${initList[index]}",
        style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800)));
    list = [
      ...list,
      ...memory
          .map((e) => Container(
              height: 35,
              width: 45,
              margin: EdgeInsets.all(3),
              decoration: BoxDecoration(
                  color: storageLen > 9
                      ? Colors.white
                      : Color(int.parse("0xF0${colors[e].substring(1)}"))),
              child: Center(
                  child: Text("$e",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)))))
          .toList()
    ];
    while (list.length < memoryLen + 1) {
      list.add(Container(
        decoration: BoxDecoration(color: Colors.black),
        height: 35,
        width: 45,
        margin: EdgeInsets.all(3),
        child: Center(
          child: Text(
            "empty",
            style: TextStyle(
              fontSize: 11,
              color: Colors.white,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ));
    }
    tableList.add(Column(
      children: list,
    ));
    return [];
  }

  change(Function algorithm) {
    chartMod = false;
    execute(algorithm);
  }

  execute(Function algorithm) {
    setState(() {
      initList = init();
    });
    for (int i = 0; i < initList.length; i++) {
      if (memory.contains(initList[i])) {
        setState(() {
          generateTable(i);
        });
        continue;
      } else if (memory.length >= memoryLen) {
        faultPage++;
        memory.remove(algorithm(i));
      }
      memory.add(initList[i]);
      setState(() {
        generateTable(i);
      });
    }
  }

  // 对各项参数初始化
  List<int> init() {
    tableList = [];
    faultPage = 0;
    memory = [];
    List<int> list = [];
    for (var i = 0; i < exeNum; i++) {
      // 生成随机数 1 + [0,i)
      list.add(1 + Random().nextInt(storageLen));
    }
    return list;
  }

  int fifoAlgorithm(int index) {
    return memory[0];
  }

  int optAlgorithm(int index) {
    // 遍历数组，将最后一个找到的内存中进程号返回以删除（未来最久未使用）
    List<int> list = [];
    for (var i = index; i < initList.length - 1; i++) {
      int number = initList[i];
      if (list.contains(number))
        continue;
      else if (memory.contains(number)) {
        list.add(number);
        if (list.length == memoryLen) {
          return list[memoryLen - 1];
        }
      }
    }
    // 若出现未来未使用的内存遵循未使用的先进先出（未来未使用）
    for (var item in memory) {
      if (!list.contains(item)) {
        return item;
      }
    }
    return 0;
  }

  // 最近最久未使用
  int lruAlgorithm(int index) {
    List<int> list = [];
    for (var i = index; i >= 0; i--) {
      int number = initList[i];
      if (list.contains(number))
        continue;
      else if (memory.contains(number)) {
        list.add(number);
        if (list.length == memoryLen) {
          return list[memoryLen - 1];
        }
      }
    }
    return -1;
  }
}

const List<String> colors = [
  '#fd999a',
  '#66cc99',
  '#66bdb0',
  '#2196f3',
  '#bf83da',
  //
  '#68c4cf',
  '#ff5722',
  '#00d4bb',
  '#968cdc',
  '#ff7878',
];

class LinearRate {
  final int pageNum;
  final double faultRate;
  LinearRate(this.pageNum, this.faultRate);
}
