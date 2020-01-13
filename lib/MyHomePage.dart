import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_twitter_google_login/UserData.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "package:http/http.dart" as http;
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FacebookLogin facebookSignIn = new FacebookLogin();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();

  Future facebookLogin() async {
    final FacebookLoginResult result =
        await facebookSignIn.logInWithReadPermissions(['email']);

    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        // final FacebookAccessToken accessToken = result.accessToken;
        var response = await http.get(
            'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture&access_token=${result.accessToken.token}');

        var responseData = json.decode(response.body);
        print(responseData['picture']['data']['url']);
        print(responseData['id']);

        navigateToPage(
            responseData['name'], responseData['picture']['data']['url']);
        insertData(
            responseData['name'],
            responseData['email'],
            responseData['picture']['data']['url'],
            responseData['id'],
            "Facebook");
        // .whenComplete(navigateToPage(responseData['name'],responseData['name']));
        break;
      case FacebookLoginStatus.cancelledByUser:
        break;
      case FacebookLoginStatus.error:
        break;
    }
  }

  Future googleLogin() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
        await googleSignInAccount.authentication;

    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleSignInAuthentication.accessToken,
      idToken: googleSignInAuthentication.idToken,
    );

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    assert(!user.isAnonymous);
    assert(await user.getIdToken() != null);

    final FirebaseUser currentUser = await _auth.currentUser();

    print("url:${currentUser.photoUrl}");
    print('id:${currentUser.uid}');

    navigateToPage(currentUser.displayName, currentUser.photoUrl);
    insertData(currentUser.displayName, currentUser.email, currentUser.photoUrl,
        currentUser.uid, "Google");
    return 'signInWithGoogle succeeded: $user';
  }

  static final TwitterLogin twitterLogin = new TwitterLogin(
    consumerKey: 'Sf13QtjdfsgOWQfMc6hbCL3Rd',
    consumerSecret: '8B3Oy17rg9yWNv6plS0qJyqHSN9zSq03hNwhMTDdaBzjFQzXQv',
  );


  void _twitterLogin() async {
    String newMessage;

    final TwitterLoginResult result = await twitterLogin.authorize();

    switch (result.status) {
      case TwitterLoginStatus.loggedIn:
        newMessage = 'Logged in! username: ${result.session.username}';
        navigateToPage(result.session.username, '');
        print(result.session.userId);
        insertData(
            result.session.username, '', '', result.session.userId, "Twitter");
        break;
      case TwitterLoginStatus.cancelledByUser:
        newMessage = 'Login cancelled by user.';
        break;
      case TwitterLoginStatus.error:
        newMessage = 'Login error: ${result.errorMessage}';
        break;
    }
  }

  Future insertData(var username, var useremail, var userimage, var userauth,
      var usersource) async {
    var url = "http://localhost/fb_twitter_data/insert_data.php";
    final response = await http.post(url, body: {
      "username": username,
      "useremail": useremail,
      "userimage": userimage,
      "userauth": userauth,
      "usersource": usersource
    });
    print(response.body);
  }

  Widget loginButton(var loginText, Function onPress) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: new LinearGradient(
            colors: [
              const Color(0xFF3366FF),
              const Color(0xFF00CCFF),
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 0.0),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      height: 40,
      width: 200,
      child: MaterialButton(
        shape: RoundedRectangleBorder(
            borderRadius: new BorderRadius.circular(18.0),
            side: BorderSide(color: Colors.black)),
        onPressed: onPress,
        splashColor: Colors.black,
        child: Text(loginText),
      ),
    );
  }

  navigateToPage(var name, var image) {
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => UserData(
                  username: name,
                  userimage: image,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Facebook Twitter Google Login"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 10,
            ),
            loginButton("Login with Facebook", facebookLogin),
            Container(
              height: 10,
            ),
            loginButton("Login with Google", googleLogin),
            Container(
              height: 10,
            ),
            loginButton("Login with Twitter", _twitterLogin),
            Container(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
