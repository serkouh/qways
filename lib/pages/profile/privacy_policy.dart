import 'package:qways/localization/localization_const.dart';
import 'package:qways/theme/theme.dart';
import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        elevation: 0,
        titleSpacing: 0,
        backgroundColor: whiteColor,
        foregroundColor: black2FColor,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: Text(
          getTranslation(context, 'privacy_policy.privacy_policy'),
          style: bold18BlackText,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(
            left: fixPadding * 2.0,
            right: fixPadding * 2.0,
            bottom: fixPadding * 2.0,
            top: fixPadding),
        children: [
          introducation(),
          heightSpace,
          height5Space,
          privacypolicy(),
        ],
      ),
    );
  }

  privacypolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'privacy_policy.privacy_policy'),
          style: bold16BlackText,
        ),
        heightSpace,
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis ",
          style: semibold14Grey,
        ),
        heightSpace,
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis ",
          style: semibold14Grey,
        ),
        heightSpace,
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis iaculiviverramassal.Lorem ipsum dolor siakloconsectetur adipiscing elit. Sem maecenas poaculiviverramalesuada lacus.Lorem ipsum dolor sit amet, consectetuadiooiselit. Sem maecenas proin nec, turpis iaculiviverrhjmalesuada lacus.Lorem ipsum dolor siamet,consectetur adipiscinelit. Sem maecenas proin turpis iaculiviverra massmalesuada ",
          style: semibold14Grey,
        )
      ],
    );
  }

  introducation() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          getTranslation(context, 'privacy_policy.introduction'),
          style: bold16BlackText,
        ),
        heightSpace,
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis ",
          style: semibold14Grey,
        ),
        heightSpace,
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis ",
          style: semibold14Grey,
        ),
        heightSpace,
        const Text(
          "Lorem ipsum dolor sit amet, consectetur adipiscing tsem maecenas proin nec, iaculiviverramalesuadalacus.Lorem ipsum dolor sit amet, consectetuadipiscing elit.maecenas proin nec, turpis iaculiviverramassa malesualacus.Lorem ipsum dolor siamet,consectetur adipiscing elit. maecenas proin turpis iaculiviverra massa malesuadlacus.necturpis iaculiviverramassal.Lorem ipsum dolor siakloconsectetur adipiscing elit. Sem maecenas poaculiviverramalesuada lacus.Lorem ipsum dolor sit amet, consectetuadiooiselit. Sem maecenas proin nec, turpis iaculiviverrhjmalesuada lacus.Lorem ipsum dolor siamet,consectetur adipiscinelit. Sem maecenas proin turpis iaculiviverra massmalesuada ",
          style: semibold14Grey,
        )
      ],
    );
  }
}
