import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class TermsAndConditionScreen extends StatefulWidget {
  const TermsAndConditionScreen({super.key});

  @override
  State<TermsAndConditionScreen> createState() =>
      _TermsAndConditionScreenState();
}

class _TermsAndConditionScreenState extends State<TermsAndConditionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        titleSpacing: 0,
        centerTitle: false,
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, "terms_and_condition.terms_and_condition"),
          style: bold18BlackText,
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(
          top: fixPadding,
          left: fixPadding * 2.0,
          right: fixPadding * 2.0,
          bottom: fixPadding * 2.0,
        ),
        physics: const BouncingScrollPhysics(),
        children: const [
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis",
            style: semibold14Grey,
          ),
          heightSpace,
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis iaculiviverramassal.Lorem ipsum dolor siakloconsectetur adipiscing elit. Sem maecenas poaculiviverramalesuada lacus.Lorem ipsum dolor sit amet, consectetuadiooiselit. Sem maecenas proin nec, turpis iaculiviverrhjmalesuada lacus.Lorem ipsum dolor siamet,consectetur adipiscinelit. Sem maecenas proin turpis iaculiviverra massmalesuada ",
            style: semibold14Grey,
          ),
          heightSpace,
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis",
            style: semibold14Grey,
          ),
          heightSpace,
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis iaculiviverramassal.Lorem ipsum dolor siakloconsectetur adipiscing elit. Sem maecenas poaculiviverramalesuada lacus.Lorem ipsum dolor sit amet, consectetuadiooiselit. Sem maecenas proin nec, turpis iaculiviverrhjmalesuada lacus.Lorem ipsum dolor siamet,consectetur adipiscinelit. Sem maecenas proin turpis iaculiviverra massmalesuada ",
            style: semibold14Grey,
          ),
          heightSpace,
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis",
            style: semibold14Grey,
          ),
          heightSpace,
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis",
            style: semibold14Grey,
          ),
          heightSpace,
          Text(
            "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis iaculiviverramassal.Lorem ipsum dolor siakloconsectetur adipiscing elit. Sem maecenas poaculiviverramalesuada lacus.Lorem ipsum dolor sit amet, consectetuadiooiselit. Sem maecenas proin nec, turpis iaculiviverrhjmalesuada lacus.Lorem ipsum dolor siamet,consectetur adipiscinelit. Sem maecenas proin turpis iaculiviverra massmalesuada ",
            style: semibold14Grey,
          ),
        ],
      ),
    );
  }
}
