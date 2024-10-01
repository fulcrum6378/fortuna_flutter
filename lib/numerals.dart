import 'dart:math';

abstract class BaseNumeral {
  late int n;
  bool supportsZero = false;
  bool supportsNegative = false;

  BaseNumeral(this.n,
      [this.supportsZero = false, this.supportsNegative = false]);

  abstract List<String> chars;
  String defaultStr = "NaN";

  String parse();

  @override
  String toString() {
    if ((n > 0 || supportsZero) && (n >= 0 || supportsNegative)) {
      try {
        return parse();
      } catch (e) {
        return defaultStr;
      }
    } else {
      return defaultStr;
    }
  }

  static List<NumeralType> all = [
    NumeralType('arabic'),
    NumeralType('roman'),
    NumeralType('brahmi'),
    NumeralType('oldPersian'),
    NumeralType('etruscan'),
    NumeralType('attic'),
    NumeralType('hieroglyph', true),
  ];
  static final String key = "numeral_type";
  static final String defType = "arabic";

  static BaseNumeral? construct(String? type, int n) {
    switch (type) {
      case 'roman':
        return RomanNumeral(n);
      case 'brahmi':
        return BrahmiNumeral(n);
      case 'oldPersian':
        return OldPersianNumeral(n);
      case 'etruscan':
        return EtruscanNumeral(n);
      case 'attic':
        return AtticNumeral(n);
      case 'hieroglyph':
        return HieroglyphNumeral(n);
      default:
        return null;
    }
  }

  static NumeralType findById(String selectedNumType) =>
      BaseNumeral.all.firstWhere((element) => element.id == selectedNumType,
          orElse: () => BaseNumeral.all.first);
}

class NumeralType {
  late String id;
  late bool enlarge;

  NumeralType(this.id, [this.enlarge = false]);
}

abstract class AtticBasedNumeral extends BaseNumeral {
  late bool subtract4th;
  bool rtl = false;

  AtticBasedNumeral(super.n);

  @override
  String parse() {
    String sn = n.toString();
    int ln = sn.length;
    StringBuffer s = StringBuffer();
    for (int ii = 0; ii < sn.length; ii++) {
      int i = int.parse(sn[ii]);
      String base = chars[((ln - ii) - 1) * 2];
      String half = chars[(((ln - ii) - 1) * 2) + 1];
      if ((i >= 0 && i <= 3) || (subtract4th && i == 4)) {
        s.write(base * i);
      } else if (!subtract4th && i == 4) {
        s.write(base + half);
      } else if ((i >= 5 && i <= 8) || (subtract4th && i == 9)) {
        s.write(half + (base * (i - 5)));
      } else if (!subtract4th && i == 9) {
        s.write(base + chars[(((ln - ii) - 1) * 2) + 2]);
      }
    }
    String ret = s.toString();
    if (rtl) ret = ret.split('').reversed.join();
    return ret;
  }
}

class AtticNumeral extends AtticBasedNumeral {
  AtticNumeral(super.n) {
    subtract4th = true;
  }

  @override
  List<String> chars = [
    "I", "\ud800\udd43", // 1, 5
    "Δ", "\ud800\udd44", // 10, 50
    "Η", "\ud800\udd45", // 100, 500
    "Χ", "\ud800\udd46", // 1,000, 5,000
    "M", "\ud800\udd47" // 10,000, 50,000
  ];
}

class EtruscanNumeral extends AtticBasedNumeral {
  EtruscanNumeral(super.n) {
    subtract4th = true;
    rtl = true;
  }

  @override
  List<String> chars = [
    "\uD800\udf20",
    "\uD800\uDF21",
    "\uD800\uDF22",
    "\uD800\uDF23",
    "\uD800\uDF1F"
  ];
}

class RomanNumeral extends AtticBasedNumeral {
  RomanNumeral(super.n) {
    subtract4th = false;
  }

  @override
  List<String> chars = [
    "I",
    "V",
    "X",
    "L",
    "C",
    "D",
    "M",
    "I\u0305",
    "V\u0305",
    "X\u0305",
    "L\u0305",
    "C\u0305",
    "D\u0305",
    "M\u0305"
  ];
}

abstract class GematriaLikeNumeral extends BaseNumeral {
  GematriaLikeNumeral(super.n);

  @override
  String parse() {
    String sn = n.toString();
    int ln = sn.length;
    StringBuffer s = StringBuffer();
    for (int ii = 0; ii < sn.length; ii++) {
      int i = int.parse(sn[ii]);
      if (i == 0) continue;
      s.write(chars[((((ln - ii) - 1) * 9) - 1) + i]);
    }
    return s.toString();
  }
}

class HieroglyphNumeral extends GematriaLikeNumeral {
  HieroglyphNumeral(super.n) {
    defaultStr = "\uD80C\uDC4F";
  }

  @override
  List<String> chars = [
    // 1..9
    "\uD80C\uDFFA",
    "\uD80C\uDFFB",
    "\uD80C\uDFFC",
    "\uD80C\uDFFD",
    "\uD80C\uDFFE",
    "\uD80C\uDFFF",
    "\uD80D\uDC00",
    "\uD80D\uDC01",
    "\uD80D\uDC02",
    // 10..90
    "\uD80C\uDF86",
    "\uD80C\uDF8F",
    "\uD80C\uDF88",
    "\uD80C\uDF89",
    "\uD80C\uDF8A",
    "\uD80C\uDF8B",
    "\uD80C\uDF8C",
    "\uD80C\uDF8D",
    "\uD80C\uDF8E",
    // 100..900
    "\uD80C\uDF62",
    "\uD80C\uDF63",
    "\uD80C\uDF64",
    "\uD80C\uDF65",
    "\uD80C\uDF66",
    "\uD80C\uDF67",
    "\uD80C\uDF68",
    "\uD80C\uDF69",
    "\uD80C\uDF6A",
    // 1,000..9,000
    "\uD80C\uDDBC",
    "\uD80C\uDDBD",
    "\uD80C\uDDBE",
    "\uD80C\uDDBF",
    "\uD80C\uDDC0",
    "\uD80C\uDDC1",
    "\uD80C\uDDC2",
    "\uD80C\uDDC3",
    "\uD80C\uDDC4",
    // 10,000..100,000
    "\uD80C\uDCAD",
    "\uD80C\uDCAE",
    "\uD80C\uDCAF",
    "\uD80C\uDCB0",
    "\uD80C\uDCB1",
    "\uD80C\uDCB2",
    "\uD80C\uDCB3",
    "\uD80C\uDCB4",
    "\uD80C\uDCB5",
    "\uD80C\uDD90"
  ];
}

class BrahmiNumeral extends GematriaLikeNumeral {
  BrahmiNumeral(super.n);

  @override
  List<String> chars = [
    // 1..9
    "\uD804\uDC52",
    "\uD804\uDC53",
    "\uD804\uDC54",
    "\uD804\uDC55",
    "\uD804\uDC56",
    "\uD804\uDC57",
    "\uD804\uDC58",
    "\uD804\uDC59",
    "\uD804\uDC5A",
    // 10..90
    "\uD804\uDC5B",
    "\uD804\uDC5C",
    "\uD804\uDC5D",
    "\uD804\uDC5E",
    "\uD804\uDC5F",
    "\uD804\uDC60",
    "\uD804\uDC61",
    "\uD804\uDC62",
    "\uD804\uDC63",
    // 100 (the rest are not available in unicode!)
    "\uD804\uDC64"
    // except 1,000: "\uD804\uDC65" which is useless without the previous chars!
  ];
}

class OldPersianNumeral extends BaseNumeral {
  OldPersianNumeral(super.n);

  @override
  List<String> chars = [
    "\uD800\uDFD1", "\uD800\uDFD2", // 1, 2
    "\uD800\uDFD3", "\uD800\uDFD4", // 10, 20
    "\uD800\uDFD5" // 100
  ];

  int charToInt(int i) {
    double ii = i.toDouble();
    if (i % 2 == 1) ii -= 1.0;
    ii /= 2;
    return pow(10.0, ii).toInt() * ((i % 2 == 0) ? 1 : 2);
  }

  @override
  String parse() {
    StringBuffer s = StringBuffer();
    int nn = n;
    while (nn > 0) {
      int subVal = 0;
      int subChar = 0;
      for (int ch = 0; ch < chars.length; ch++) {
        int charVal = charToInt(ch);
        if (charVal > nn) break;
        subChar = ch;
        subVal = charVal;
      }
      nn -= subVal;
      s.write(chars[subChar]);
    }
    return s.toString();
  }
}
