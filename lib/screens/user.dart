import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iconly/flutter_iconly.dart';
import 'package:provider/provider.dart';
import 'package:safwa_u/consts/firebase_const.dart';
import 'package:safwa_u/providers/dark_theme_provider.dart';
import 'package:safwa_u/screens/auth/forget_password.dart';
import 'package:safwa_u/screens/auth/login.dart';
import 'package:safwa_u/screens/loading_manager.dart';
import 'package:safwa_u/screens/orders/orders_screen.dart';
import 'package:safwa_u/screens/viewed_recently/viewed_recently_screen.dart';
import 'package:safwa_u/screens/wishlist/wishlist_screen.dart';
import 'package:safwa_u/services/global_method.dart';
import 'package:safwa_u/widgets/text_widget.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({Key? key}) : super(key: key);

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  final TextEditingController _addressEditingController = TextEditingController(text: "");

  @override
  void dispose() {
    _addressEditingController.dispose();
    super.dispose();
  }

  String? _email;
  String? _name;
  String? address;

  bool _isLoading = false ;
  final User? user = authInstance.currentUser ;

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  Future<void> getUserData() async{
    setState(() {
      _isLoading = true ;
    });
    if(user == null){
      setState(() {
        _isLoading = false ;
      });
      return;
    }
    try{
      String _uid = user!.uid;

      final DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('users').doc(_uid).get();
      if(userDoc == null){
        return;
      }
      else{
        _email = userDoc.get('email');
        _name = userDoc.get('name');
        address = userDoc.get('shipping-address');
        _addressEditingController.text = userDoc.get('shipping-address');
      }
    }
    catch (error){
      setState(() {
        _isLoading = false ;
      });
      GlobalMethods.errorDialog(subtitle: '$error', context: context);
    }
    finally{
      setState(() {
        _isLoading = false ;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeState = Provider.of<DarkThemeProvider>(context);
    final Color color = themeState.getDarkTheme ? Colors.white : Colors.black ;
    return Scaffold(
      body: LoadingManager(
        isLoading: _isLoading,
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 8, bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children:  [
                  RichText(
                    text: TextSpan(
                    text: 'Hi,  ',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyan
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: _name == null ? 'user' : _name,
                        style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.w600,
                            color: color,
                        ),
                        recognizer: TapGestureRecognizer()..onTap = (){
                          print("my name is pressed");
                      }
                      ),
                    ],
                  ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  TextWidget(
                      text: _email == null ? 'Email...' : _email!,
                      color: color,
                      textSize: 18,
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  Divider(
                    thickness: 2,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _listTiles(
                      title: 'Address 2',
                      subtitle: address,
                      icon: IconlyLight.profile,
                      onPressed: () async{
                        await _showDialogAddress();
                      },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Orders',
                    icon: IconlyLight.bag,
                    onPressed: (){
                      GlobalMethods.navigateTo(
                          ctx: context, routeName: OrdersScreen.routeName);
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Wishlist',
                    icon: IconlyLight.heart,
                    onPressed: (){
                      GlobalMethods.navigateTo(
                          ctx: context, routeName: WishlistScreen.routeName);
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Viewed',
                    icon: IconlyLight.show,
                    onPressed: (){
                      GlobalMethods.navigateTo(
                          ctx: context, routeName: ViewedRecentlyScreen.routeName);
                    },
                    color: color,
                  ),
                  _listTiles(
                    title: 'Forget Password',
                    icon: IconlyLight.unlock,
                    onPressed: (){
                      Navigator.of(context).push(MaterialPageRoute
                        (builder: (context) => const ForgetPasswordScreen(),
                      ),);
                    },
                    color: color,
                  ),

                  SwitchListTile(
                    title: TextWidget(
                        text: themeState.getDarkTheme ? 'Dark mode' : "Light mode",
                        color: color,
                        textSize: 18,
                    ),
                    secondary: Icon( themeState.getDarkTheme
                        ? Icons.dark_mode_outlined
                        : Icons.light_mode_outlined,
                    ),
                    onChanged: (bool value){
                      setState(() {
                        themeState.setDarkTheme = value ;
                      });
                    },
                    value: themeState.getDarkTheme,
                  ),

                  SizedBox(
                    height: 10,
                  ),

                  _listTiles(
                    title: user == null ? 'Login' : 'Logout',
                    icon: user == null? IconlyLight.login : IconlyLight.logout,
                    onPressed: (){
                      if(user == null){
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context)=> const LoginScreen(),
                          ),
                        );
                        return;
                      }
                      GlobalMethods.warningDialog(
                          title: 'Sign out',
                          subtitle: 'Do you wanna sign out ?'
                          , fct: () async {
                           await authInstance.signOut();
                           Navigator.of(context).push(
                             MaterialPageRoute(
                               builder: (context)=> const LoginScreen(),
                             ),
                           );
                      },
                          context: context,
                      );
                    },
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }


  Future <void> _showDialogAddress() async{
    await showDialog(context: context, builder: (context){
      return AlertDialog(
        title: Text('Update'),
        content: TextField(
          // onChanged: (value){
          //   print('_addressEditingController.text ${_addressEditingController.text}');
          // },
          controller: _addressEditingController,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: 'Your Address',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async{
              String _uid = user!.uid;
              try{
                await FirebaseFirestore.instance
                .collection('users')
                .doc(_uid)
                .update({
                  'shipping-address': _addressEditingController.text,
                });
                Navigator.pop(context);
                setState(() {
                  address = _addressEditingController.text;
                });
              }catch (error){
                GlobalMethods.errorDialog(subtitle: error.toString(), context: context);
              }
            },
            child: Text('Update'),
          ),
        ],
      );
    });
  }

  Widget _listTiles({
    required String title,
    String? subtitle,
    required IconData icon,
    required Function onPressed,
    required Color color,
  }){
    return ListTile(
      title:TextWidget(
        text: title ,
        color: color,
        textSize: 22,
        // isTitle: true,
      ),
      subtitle: TextWidget(
        text: subtitle == null ? "" : subtitle ,
        color: color,
        textSize: 18,
      ),
      leading: Icon(icon),
      trailing: const Icon(IconlyLight.arrowRight2),
      onTap: (){
        onPressed();
      },
    );
  }
}
