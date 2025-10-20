import 'package:flutter/material.dart';
import '../services/break_manager.dart';
import '../widgets/logo_widget.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final bm = BreakManager();

  @override
  void initState(){
    super.initState();
    bm.init();
    bm.onUpdate = () => setState((){});
  }

  @override
  void dispose(){
    bm.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rem = bm.remaining();
    return Scaffold(
      appBar: AppBar(title: Text('Restly', style: Theme.of(context).textTheme.headline6)),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            LogoWidget(),
            SizedBox(height:18),
            if (rem!=null) Card(child: Padding(padding: EdgeInsets.all(12), child: Text('Kalan mola: ${rem.inMinutes}:${(rem.inSeconds%60).toString().padLeft(2,'0')}'))),
            SizedBox(height:12),
            ElevatedButton(
              onPressed: () async {
                if (bm.currentBreakId==null) {
                  await bm.startBreak('short', requestedMinutes: 10);
                } else {
                  await bm.stopBreak();
                }
                setState((){});
              },
              child: Text(bm.currentBreakId==null ? 'Mola Başlat (max 10 dk)' : 'Mola Bitir'),
            ),
            SizedBox(height:8),
            ElevatedButton(
              onPressed: () async {
                if (bm.currentBreakId==null) {
                  await bm.startBreak('meal', requestedMinutes: 25);
                } else {
                  await bm.stopBreak();
                }
                setState((){});
              },
              child: Text('Yemek Molası (25 dk)'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.grey.shade800),
            ),
            Expanded(child: Container()),
            Text('Restly — Sağlıklı molalar için', style: TextStyle(color: Colors.grey))
          ],
        ),
      ),
    );
  }
}
