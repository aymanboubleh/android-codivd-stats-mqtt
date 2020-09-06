import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'view/list_ita_regioni.dart';
import 'view/list_usa_states.dart';
import 'view/single_int_report.dart';
import 'view/single_ita_reg_report.dart';
import 'view/single_ita_report.dart';
import 'view/single_usa_states_report.dart';

import 'layout/master_detail.dart';
import 'layout/master_detail_ita.dart';
import 'layout/master_detail_usa.dart';

class StatsPage extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Covid-19',
      theme: ThemeData(
        primaryColor: Colors.grey[400],
        textTheme: GoogleFonts.latoTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        if (settings.name == SingleIntReportView.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return SingleIntReportView(country: settings.arguments);
            },
          );
        } else
        if (settings.name == MasterDetailPageUSA.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return MasterDetailPageUSA(country: settings.arguments);
            },
          );
        } else
        if (settings.name == ListUSAStatesView.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return ListUSAStatesView(null , settings.arguments);
            },
          );
        } else
        if (settings.name == SingleUSAStatesReportView.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return SingleUSAStatesReportView(state: settings.arguments);
            },
          );
        } else
        if (settings.name == MasterDetailPageITA.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return MasterDetailPageITA(selectedCountry: settings.arguments);
            },
          );
        } else
        if (settings.name == ListITARegioniView.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return ListITARegioniView(null , settings.arguments);
            },
          );
        } else
        if (settings.name == SingleITAReportView.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return SingleITAReportView(country: settings.arguments);
            },
          );
        } else
        if (settings.name == SingleITARegReportView.routeName) {
          return MaterialPageRoute(
            builder: (context) {
              return SingleITARegReportView(provincia: settings.arguments);
            },
          );
        } else
        return null;
      },
      routes: {
        '/': (context) => MasterDetailPage(),
      },
    );
  }


}
