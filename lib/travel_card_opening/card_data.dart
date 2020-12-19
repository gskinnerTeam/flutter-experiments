import 'package:lipsum/lipsum.dart' as lipsum;

// Some mock data for the demo
class CardData {
  CardData({this.title, this.desc, this.url});
  final String title;
  final String desc;
  final String url;
}

List<String> unsplashIds = [
  "1494548162494-384bba4ab999",
  "1567878130373-9c952877ed1d",
  "1574579991264-a87099cc17b1",
  "1532465473170-c5a4ce480bee",
  "1517699418036-fb5d179fef0c"
];
String imgFromId(String id) => "https://images.unsplash.com/photo-$id?w=1800&q=95";

List<CardData> cards = List.generate(
  12,
  (index) => CardData(
    title: lipsum.createWord(numWords: 2),
    desc: "${lipsum.createWord(numWords: 2)} - ${lipsum.createWord(numWords: 2)}",
    url: imgFromId(unsplashIds[index % unsplashIds.length]),
  ),
);
