import 'package:adiary/screens/about.dart';
import 'package:adiary/screens/dashboard.dart';
import 'package:adiary/screens/export.dart';
import 'package:adiary/screens/import.dart';
import 'package:adiary/screens/notification.dart';
import 'package:adiary/screens/password.dart';
import 'package:adiary/screens/summary.dart';
import 'package:adiary/screens/visualization.dart';
import 'package:flutter/material.dart';


// ─── Colors ───────────────────────────────────────────────────────────────
abstract final class PinkColors {
  static const shade50  = Color(0xFFFCE4EC);
  static const shade100 = Color(0xFFF8BBD0);
  static const shade200 = Color(0xFFF48FB1);
  static const shade300 = Color(0xFFF06292);
  static const shade400 = Color(0xFFEC407A);
  static const shade500 = Color(0xFFE91E63);
  static const shade600 = Color(0xFFD81B60);
  static const shade700 = Color(0xFFC2185B);
  static const shade800 = Color(0xFFAD1457);
  static const shade900 = Color(0xFF880E4F);
}

abstract final class PinkAccentColors {
  static const shade100 = Color(0xFFFF80AB);
  static const shade200 = Color(0xFFFF4081);
  static const shade400 = Color(0xFFF50057);
  static const shade700 = Color(0xFFC51162);
}

abstract final class IndigoColors {
  static const shade100 = Color(0xFFE8EAF6);
  static const shade200 = Color(0xFFC5CAE9);
  static const shade300 = Color(0xFF9FA8DA);
  static const shade400 = Color(0xFF7986CB);
  static const shade600 = Color(0xFF3949AB);
  static const shade800 = Color(0xFF283593);
  static const shade900 = Color(0xFF1A237E);
}

abstract final class IndigoAccentColors {
  static const shade100 = Color(0xFF8C9EFF);
  static const shade200 = Color(0xFF536DFE);
  static const shade400 = Color(0xFF3D5AFE);
  static const shade700 = Color(0xFF304FFE);
}

abstract final class OrangeColors {
  static const shade100 = Color(0xFFFFE0B2);
  static const shade200 = Color(0xFFFFCC80);
  static const shade300 = Color(0xFFFFB74D);
  static const shade800 = Color(0xFFEF6C00);
}

abstract final class OrangeAccentColors {
  static const shade100 = Color(0xFFFFD180);
  static const shade200 = Color(0xFFFFAB40);
  static const shade400 = Color(0xFFFF9100);
  static const shade700 = Color(0xFFFF6D00);
}

abstract final class PurpleColors {
  static const shade100 = Color(0xFFE1BEE7);
  static const shade200 = Color(0xFFCE93D8);
  static const shade300 = Color(0xFFBA68C8);
  static const shade800 = Color(0xFF6A1B9A);
}

abstract final class DeepPurpleColors {
  static const shade100 = Color(0xFFEDE7F6);
  static const shade200 = Color(0xFFD1C4E9);
  static const shade600 = Color(0xFF5E35B1);
  static const shade800 = Color(0xFF4527A0);
}

abstract final class RedColors {
  static const shade100 = Color(0xFFFFCDD2);
  static const shade200 = Color(0xFFEF9A9A);
  static const shade300 = Color(0xFFE57373);
  static const shade600 = Color(0xFFE53935);
  static const shade800 = Color(0xFFC62828);
}

abstract final class DeepOrangeColors {
  static const shade100 = Color(0xFFFFE0B2);
  static const shade200 = Color(0xFFFFCC80);
  static const shade300 = Color(0xFFFFB74D);
  static const shade600 = Color(0xFFF4511E);
  static const shade800 = Color(0xFFBF360C);
}

abstract final class AmberColors {
  static const shade100 = Color(0xFFFFECB3);
  static const shade200 = Color(0xFFFFE082);
  static const shade800 = Color(0xFFFF8F00);
}

abstract final class BrownColors {
  static const shade100 = Color(0xFFD7CCC8);
  static const shade200 = Color(0xFFBCAAA4);
  static const shade300 = Color(0xFFA1887F);
  static const shade600 = Color(0xFF6D4C41);
  static const shade800 = Color(0xFF4E342E);
  static const shade900 = Color(0xFF3E2723);
}

abstract final class GreyColors {
  static const shade200 = Color(0xFFEEEEEE);
  static const shade400 = Color(0xFFBDBDBD);
  static const shade600 = Color(0xFF757575);
  static const shade900 = Color(0xFF212121);
}

abstract final class TealColors {
  static const shade100 = Color(0xFFB2DFDB);
  static const shade300 = Color(0xFF4DB6AC);
  static const shade800 = Color(0xFF00695C);
}

abstract final class CyanColors {
  static const shade100 = Color(0xFFB2EBF2);
  static const shade300 = Color(0xFF4DD0E1);
  static const shade800 = Color(0xFF00838F);
}

abstract final class BlueColors {
  static const shade100 = Color(0xFFBBDEFB);
  static const shade300 = Color(0xFF64B5F6);
  static const shade800 = Color(0xFF1565C0);
}

abstract final class GreenColors {
  static const shade100 = Color(0xFFC8E6C9);
  static const shade300 = Color(0xFF81C784);
  static const shade800 = Color(0xFF2E7D32);
}

abstract final class LimeColors {
  static const shade100 = Color(0xFFF9FBE7);
  static const shade300 = Color(0xFFDCE775);
  static const shade900 = Color(0xFF827717);
}

// ─── Navigation ───────────────────────────────────────────────────────────────

const homePageWidgetListsForDrawer = <String, Widget>{
  'dashboard': Dashboard(),
  'export': ExportData(),
  'import': ImportData(),
  'about': About(),
  'password': PasswordManager(),
  'notification': NotificationManager(),
  'summary': Summary(),
  'visualization': Visualization(),
};

const homePageWidgetTitleListsForAppBar = <String, String>{
  'dashboard': "ADiary, Get it? It's a Pun!!",
  'export': 'Yeah gorl, back it all up..',
  'import': 'Gorl, I got your back...',
  'about': 'Why this? You ask?',
  'password': 'Sshh! Keep this a secret!!',
  'notification': 'I know you forget...',
  'summary': 'At a Glance!!',
  'visualization': 'In Detail!!',
};

// ─── Decorations ──────────────────────────────────────────────────────────────

final bgDecoration = BoxDecoration(
  image: DecorationImage(
    image: const AssetImage('assets/images/nature.jpg'),
    fit: BoxFit.cover,
    colorFilter: ColorFilter.mode(
      Colors.black.withValues(alpha: 0.25),
      BlendMode.dstATop,
    ),
  ),
);

final appBarBg = Container(
  decoration: BoxDecoration(
    image: DecorationImage(
      image: const AssetImage('assets/images/stars.jpeg'),
      fit: BoxFit.cover,
      colorFilter: ColorFilter.mode(
        Colors.black.withValues(alpha: 0.6),
        BlendMode.dstATop,
      ),
    ),
  ),
);

// ─── Mood options ─────────────────────────────────────────────────────────────

const List<Map<String, dynamic>> MOOD_OPTIONS = [
  {
    'label': 'Amused',
    'icon': Icon(Icons.outlet_outlined),
    'bgColor': IndigoColors.shade100,
    'borderColor': IndigoColors.shade300,
    'textColor': IndigoColors.shade800,
  },
  {
    'label': 'Beautiful',
    'icon': Icon(Icons.photo_camera_outlined),
    'bgColor': PinkAccentColors.shade100,
    'borderColor': PinkColors.shade600,
    'textColor': PinkColors.shade900,
  },
  {
    'label': 'Cheerful',
    'icon': Icon(Icons.mood),
    'bgColor': OrangeColors.shade100,
    'borderColor': OrangeColors.shade800,
    'textColor': PinkColors.shade800,
  },
  {
    'label': 'Content',
    'icon': Icon(Icons.tag_faces_outlined),
    'bgColor': PurpleColors.shade100,
    'borderColor': PurpleColors.shade800,
    'textColor': PurpleColors.shade800,
  },
  {
    'label': 'Cozy',
    'icon': Icon(Icons.fireplace_outlined),
    'bgColor': OrangeAccentColors.shade100,
    'borderColor': RedColors.shade800,
    'textColor': RedColors.shade800,
  },
  {
    'label': 'Creative',
    'icon': Icon(Icons.brush_outlined),
    'bgColor': BrownColors.shade200,
    'borderColor': BrownColors.shade800,
    'textColor': BrownColors.shade800,
  },
  {
    'label': 'Delighted',
    'icon': Icon(Icons.sentiment_very_satisfied_outlined),
    'bgColor': RedColors.shade200,
    'borderColor': RedColors.shade300,
    'textColor': RedColors.shade800,
  },
  {
    'label': 'Empowered',
    'icon': Icon(Icons.rocket_outlined),
    'bgColor': DeepOrangeColors.shade100,
    'borderColor': DeepOrangeColors.shade800,
    'textColor': DeepOrangeColors.shade800,
  },
  {
    'label': 'Excited',
    'icon': Icon(Icons.sentiment_satisfied),
    'bgColor': AmberColors.shade100,
    'borderColor': AmberColors.shade800,
    'textColor': PinkColors.shade600,
  },
  {
    'label': 'Free',
    'icon': Icon(Icons.wind_power_outlined),
    'bgColor': GreyColors.shade200,
    'borderColor': GreyColors.shade600,
    'textColor': GreyColors.shade600,
  },
  {
    'label': 'Fulfilled',
    'icon': Icon(Icons.battery_charging_full_outlined),
    'bgColor': RedColors.shade100,
    'borderColor': RedColors.shade600,
    'textColor': RedColors.shade600,
  },
  {
    'label': 'Glad',
    'icon': Icon(Icons.wb_sunny_outlined),
    'bgColor': PinkColors.shade100,
    'borderColor': PinkColors.shade300,
    'textColor': PinkColors.shade800,
  },
  {
    'label': 'Grateful',
    'icon': Icon(Icons.handshake_outlined),
    'bgColor': TealColors.shade100,
    'borderColor': TealColors.shade300,
    'textColor': TealColors.shade800,
  },
  {
    'label': 'Hopeful',
    'icon': Icon(Icons.temple_hindu_outlined),
    'bgColor': CyanColors.shade100,
    'borderColor': CyanColors.shade300,
    'textColor': CyanColors.shade800,
  },
  {
    'label': 'Inspired',
    'icon': Icon(Icons.lightbulb_outline),
    'bgColor': BlueColors.shade100,
    'borderColor': BlueColors.shade300,
    'textColor': BlueColors.shade800,
  },
  {
    'label': 'Loved',
    'icon': Icon(Icons.favorite_outline),
    'bgColor': BrownColors.shade100,
    'borderColor': BrownColors.shade300,
    'textColor': BrownColors.shade800,
  },
  {
    'label': 'Proud',
    'icon': Icon(Icons.emoji_events_outlined),
    'bgColor': GreenColors.shade100,
    'borderColor': GreenColors.shade300,
    'textColor': GreenColors.shade800,
  },
  {
    'label': 'Purposeful',
    'icon': Icon(Icons.bolt_outlined),
    'bgColor': DeepPurpleColors.shade100,
    'borderColor': DeepPurpleColors.shade600,
    'textColor': DeepPurpleColors.shade800,
  },
  {
    'label': 'Relieved',
    'icon': Icon(Icons.thumb_up_alt_outlined),
    'bgColor': LimeColors.shade100,
    'borderColor': LimeColors.shade300,
    'textColor': LimeColors.shade900,
  },
  {
    'label': 'Rich',
    'icon': Icon(Icons.euro_outlined),
    'bgColor': DeepOrangeColors.shade100,
    'borderColor': DeepOrangeColors.shade600,
    'textColor': PinkColors.shade800,
  },
  {
    'label': 'Seen',
    'icon': Icon(Icons.visibility_outlined),
    'bgColor': GreyColors.shade200,
    'borderColor': GreyColors.shade400,
    'textColor': GreyColors.shade900,
  },
  {
    'label': 'Tingly',
    'icon': Icon(Icons.vibration_outlined),
    'bgColor': IndigoAccentColors.shade100,
    'borderColor': IndigoColors.shade600,
    'textColor': IndigoColors.shade600,
  },
];