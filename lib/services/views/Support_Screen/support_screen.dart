import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import '../../../constants/colors.dart';
import '../../controllers/profile_controller.dart';
import '../../models/supportModel.dart';
import 'newSupport.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({Key? key}) : super(key: key);

  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {

  late Future<List<SupportModel>?> userFuture;
  ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
    userFuture = _getSupports();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    controller.dispose();
  }

  Future<List<SupportModel>?>_getSupports() async {
    return await controller.getAllUserSupport();
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () => Get.back(),
            icon: const Icon(LineAwesomeIcons.angle_left)),
        title: Text("Support Tickets", style: Theme.of(context).textTheme.headline4),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        padding: const EdgeInsets.all(30.0),

        ///Future Builder
        child: FutureBuilder<List<SupportModel>?>(
          future: userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                //Controllers
                return ListView.builder(
                  shrinkWrap: true,
                  itemCount: snapshot.data!.length,
                  itemBuilder: (c, index){
                    return  GestureDetector(
                      onTap: (){
                       // Navigator.push(context, MaterialPageRoute(builder: (context) => SupportDetailsScreen(bookingData: snapshot.data![index],)));
                      },
                      child: SizedBox(
                        width: 380,
                        height: 210,
                        child: Padding(
                          padding: const EdgeInsets.only(right: 10.0, top: 5.0),
                          child: Container(
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: isDark ? Colors.black.withOpacity(0.1) : PCardBgColor),
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 10.0,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Text(snapshot.data![index].ticketNumber ?? "",
                                        style: Theme.of(context).textTheme.headline4,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                    Flexible(child: Text(snapshot.data![index].status ?? "",
                                        style: TextStyle(fontSize: 18.0, color: snapshot.data![index].status == "active" ? Colors.blueAccent : Colors.redAccent ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const SizedBox(height: 20,),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Text(snapshot.data![index].subject ?? "", style: Theme.of(context).textTheme.bodyText1, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                        Text(snapshot.data![index].message ?? "", style: Theme.of(context).textTheme.bodyText1, maxLines: 2, overflow: TextOverflow.ellipsis,),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20,),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Flexible(child: Text("N${snapshot.data![index].type ?? ""}",
                                        style: Theme.of(context).textTheme.bodyText1,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                    Flexible(child: Text(snapshot.data![index].dateCreated ??"",
                                        style: Theme.of(context).textTheme.bodyText1,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis)),
                                  ],
                                ),
                                const SizedBox(height: 10,),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              }
              else if (snapshot.hasError) {
                return const Center(
                  child: Text("No Ticket, Contact Support"),
                );
              }
              else {
                return const Center(
                  child: Text("Something went wrong"),
                );
              }
            }
            else {
              return const Center(
                  child: CircularProgressIndicator());
            }
          },
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text("Create New Ticket", style: Theme.of(context).textTheme.headline6,),
          const SizedBox(width: 10,),
          FloatingActionButton(
            onPressed: () {
              Get.to(const NewSupport());
            },
            backgroundColor: PButtonColor,
            elevation: 10.0,
            child: const Icon(LineAwesomeIcons.plus,
                color: Colors.white,
                size: 30.0),
          ),
        ],
      ),
    );
  }
}
