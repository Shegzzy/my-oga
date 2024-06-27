import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../User_Dashboard/user_dashboard.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  @override
  void initState(){
    super.initState();
    _requestLocationPermission();
  }



  Future<void> _privacyPolicy() async {
    await showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text("Terms and Conditions"),
            content: const SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      "These terms and conditions outline the rules and regulations for "
                          "the use of myoga’s Website, located at https://www.myoga.com.ng/."
                          "By accessing this website, we assume you accept these terms and conditions."
                          " Do not continue to use Myoga if you do not agree to take all of the terms and conditions stated on this page."
                  ),

                  SizedBox(height: 10,),

                  Text('License:', style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),),
                  Text('Unless otherwise stated,Myoga and/or its licensors own the intellectual property rights for all material on Myoga.'
                      ' All intellectual property rights are reserved. You may access this from Myoga for your own'
                      ' personal use subjected to restrictions set in these terms and conditions.\n'

                      'You must not:\n'

                      'Copy or republish material from Myoga \n'
                      'Sell, rent, or sub-license material from Myoga \n'
                      'Reproduce, duplicate or copy material from Myoga. \n'
                      'This Agreement shall begin on the date hereof.\n'

                      'Parts of this website offer users an opportunity to post and exchange opinions and '
                      'information in certain areas of the website. Myoga does not filter, edit, publish or '
                      'review Comments before their presence on the website. Comments do not reflect the views and opinions of'
                      ' Myoga, its agents, and/or affiliates. Comments reflect the views and opinions of the person who posts'
                      ' their views and opinions. To the extent permitted by applicable laws, Myoga shall not be liable for the Comments '
                      'or any liability, damages, or expenses caused and/or suffered as a result of any use of and/or posting of and/or appearance of the Comments on this website.'

                      'Myoga reserves the right to monitor all Comments and remove any Comments that can be considered inappropriate, '
                      'offensive, or causes breach of these Terms and Conditions.\n'

                      'You warrant and represent that:\n'

                      'You are entitled to post the Comments on our website and have all necessary licenses and consents to do so;\n'
                      'The Comments do not invade any intellectual property right, including without limitation copyright, patent, or trademark of any third party;\n'
                      'The Comments do not contain any defamatory, libelous, offensive, indecent, or otherwise unlawful material, which is an invasion of privacy.\n'
                      'The Comments will not be used to solicit or promote business or custom or present commercial activities or unlawful activity.\n'
                      'You hereby grant Myoga a non-exclusive license to use, reproduce, edit and authorize others to use, '
                      'reproduce and edit any of your Comments in any and all forms, formats, or media.'),

                  SizedBox(height: 10,),

                  Text('Hyperlinking to our Content:', style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),),
                  Text('The following organizations may link to our Website without prior written approval:\n'

                      'Government agencies;\n'
                      'Search engines;\n'
                      'News organizations;\n'
                      'Online directory distributors may link to our Website in the same manner as they hyperlink to the Websites of other listed businesses; and'
                      'System-wide Accredited Businesses except soliciting non-profit organizations, charity shopping malls, and charity '
                      'fundraising groups which may not hyperlink to our Web site.\n'

                      'These organizations may link to our home page, to publications, or to other Website information so '
                      'long as the link: (a) is not in any way deceptive; (b) does not falsely imply '
                      'sponsorship, endorsement, or approval of the linking party and its products and/or services; and (c) '
                      'fits within the context of the linking party’s site.\n'

                      'We may consider and approve other link requests from the following types of organizations:\n'

                      'commonly-known consumer and/or business information sources;\n'
                      'com community sites;\n'
                      'associations or other groups representing charities;\n'
                      'online directory distributors;\n'
                      'internet portals;\n'
                      'accounting, law, and consulting firms; and\n'
                      'educational institutions and trade associations.\n'
                      'We will approve link requests from these organizations if we decide that: (a) the link would not make us look unfavourably to ourselves or to our accredited businesses; (b) the organization does not have any negative records with us; (c) the benefit to us from the visibility of the hyperlink compensates the absence of Myoga; and (d) the link is in the context of general resource information.'

                      'These organizations may link to our home page so long as the link: (a) is not in any way deceptive; (b) does not falsely imply sponsorship, endorsement, or approval of the linking party and its products or services; and (c) fits within the context of the linking party’s site.'

                      'you are one of the organizations listed in paragraph 2 above and are interested in linking to our website, '
                      'you must inform us by sending an e-mail to Myoga. Please include your name, your organization name,'
                      ' contact information as well as the URL of your site, a list of any URLs '
                      'from which you intend to link to our Website, and a list of the URLs on our site to which you would like to link. Wait 2-3 weeks for a response.\n'

                      'Approved organizations may hyperlink to our Website as follows:\n'

                      'By use of our corporate name; or\n'
                      'By use of the uniform resource locator being linked to; or\n'
                      'Using any other description of our Website being linked to that makes sense within the context and format of content on the linking party’s site.\n'
                      'No use of Myoga’s logo or other artwork will be allowed for linking absent a trademark license agreement.'),

                  SizedBox(height: 10,),
                  Text('Content Liability:', style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),),
                  Text('We shall not be held responsible for any content that appears on your Website. '
                      'You agree to protect and defend us against all claims that are raised on your Website. No link(s) '
                      'should appear on any Website that may be interpreted as libelous,'
                      ' obscene, or criminal, or which infringes, otherwise violates, or advocates the infringement'
                      ' or other violation of, any third party rights.'),

                  SizedBox(height: 10,),
                  Text('Reservation of Rights:', style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),),
                  Text('We reserve the right to request that you remove all links or any particular link'
                      ' to our Website. You approve to immediately remove all links to our Website upon request.'
                      ' We also reserve the right to amend these terms and conditions and'
                      ' its linking policy at any time. By continuously linking to our Website, '
                      'you agree to be bound to and follow these linking terms and conditions.'),

                  SizedBox(height: 10,),
                  Text('Removal of links from our website:', style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),),
                  Text('If you find any link on our Website that is offensive for any reason, you are free to contact and inform us at any moment.'
                      ' We will consider requests to remove links, but we are not obligated to or so or to respond to you directly.'

                      'We do not ensure that the information on this website is correct. We do not warrant its completeness or'
                      ' accuracy, nor do we promise to ensure that the website remains available or '
                      'that the material on the website is kept up to date.'),

                  SizedBox(height: 10,),
                  Text('Disclaimer:', style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                  ),),
                  Text('To the maximum extent permitted by applicable law, we exclude all '
                      'representations, warranties, and conditions relating to our website and the use of this website. Nothing in this disclaimer will:'

                      'limit or exclude our or your liability for death or personal injury;'
                      'limit or exclude our or your liability for fraud or fraudulent misrepresentation;'
                      'limit any of our or your liabilities in any way that is not permitted under applicable law; or'
                      'exclude any of our or your liabilities that may not be excluded under applicable law.'
                      'The limitations and prohibitions of liability set in this Section and elsewhere in this'
                      ' disclaimer: (a) are subject to the preceding paragraph; and (b) govern all liabilities arising '
                      'under the disclaimer, including liabilities arising in contract, in tort, and for breach of statutory duty.'

                      'As long as the website and the information and services on the website are'
                      ' provided free of charge, we will not be liable for any loss or damage of any nature.')
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  Get.offAll(() => const UserDashboard());
                },
                child: const Text("I Agree"),
              ),
            ],
          ),
        );
      },
    );
  }

  // Showing a pop up message for location access
  Future<void> _requestLocationPermission() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      if (mounted) {
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return PopScope(
              canPop: false,
              child: AlertDialog(
                title: const Text("Location Permission"),
                content: const Text(
                    "MyOga App collects location data to enable real-time tracking of rider location, and user locations even when the app"
                        " is closed or minimized, this enables cost calculations and precise parcel pick-ups and drop-offs,"
                        " needs access to location when in the background, to keep track of ride and destination, "
                        "access to location when open, to provide real-time tracking, faster pickups, and efficient route planning to pickups and drop-offs."),
                actions: [
                  TextButton(
                    onPressed: () async {
                      Navigator.pop(context);
                      _privacyPolicy();
                    },
                    child: const Text("OK"),
                  ),
                ],
              ),
            );
          },
        );
      }
    }else {
      Get.offAll(() => const UserDashboard());
    }
  }


  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(),
    );
  }
}
