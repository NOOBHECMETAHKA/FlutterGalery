//libs

import 'package:flutter/material.dart';
//Pages
import 'package:galary/screens/home_page.dart';
import 'package:galary/screens/auth_page.dart';



const String authRoute = '/';
const String homeRoute = '/home';

const String galeryBox = 'images';

Map<String, WidgetBuilder> routeGalary = {
  homeRoute: (context) => const MainListWidget(),
  authRoute: (context) => const AuthWidget(),
};
