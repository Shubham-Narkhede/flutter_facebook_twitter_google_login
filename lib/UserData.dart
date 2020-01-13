import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:flutter_facebook_twitter_google_login/MyHomePage.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';

class UserData extends StatefulWidget {
  final String username;
  final String userimage;

  const UserData({Key key, this.username, this.userimage}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _userData();
}

class _userData extends State<UserData> {
  final FacebookLogin facebookSignIn = new FacebookLogin();
  final GoogleSignIn googleSignIn = GoogleSignIn();
  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: 'Sf13QtjdfsgOWQfMc6hbCL3Rd',
    consumerSecret: '8B3Oy17rg9yWNv6plS0qJyqHSN9zSq03hNwhMTDdaBzjFQzXQv',
  );

  Future facebookLogout() {
   return facebookSignIn.logOut();
  }

  Future googleLogout() {
   return googleSignIn.signOut();
  }

  void twitterLogout() async {
    await twitterLogin.logOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CircleAvatar(
              radius: 70,
              backgroundImage: NetworkImage(widget.userimage),
            ),
            Container(
              height: 20,
            ),
            Text(
              widget.username,
              style: TextStyle(fontSize: 20),
            ),
            Container(
              height: 20,
            ),
            MaterialButton(
              height: 40,
              minWidth: 100,
              child: Text(
                "Logout",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                facebookLogout();
                googleLogout();
                twitterLogout();

                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => MyHomePage()));
              },
              color: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40)),
            )
          ],
        ),
      ),
    );
  }
}
