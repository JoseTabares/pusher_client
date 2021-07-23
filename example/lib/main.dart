import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:pusher_client/pusher_client.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PusherClient pusher;
  Channel channel;

  @override
  void initState() {
    super.initState();

    String token = getToken();
    String agentId = getAgentId();

    pusher = new PusherClient(
      '4a9a1e03aff67ce38c56',
      PusherOptions(
        cluster: 'mt1',
        encrypted: true,
        auth: PusherAuth(
          'https://qa.api.hibot.us/api_interactions/pusher',
          headers: {
            HttpHeaders.authorizationHeader: 'Bearer $token',
          },
        ),
      ),
      enableLogging: true,
    );

    channel = pusher.subscribe("presence-agent-$agentId");

    pusher.onConnectionStateChange((state) {
      log("previousState: ${state.previousState}, currentState: ${state.currentState}");
    });

    pusher.onConnectionError((error) {
      log("error: ${error.message}");
    });

    channel.bind('conversation-updated', (event) {
      log(event.data, name: 'conversation-updated');
    });

    channel.bind('messages-received', (event) {
      log(event.data, name: 'messages-received');
    });
  }

  String getToken() =>
      'eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6Ik5qZEJNRGxFUXpSRU4wWkdNamhHUXpZNU1EQkJNVE13TlRneU1USTRNRVEzTXpWRE9FSTBSZyJ9.eyJodHRwczovL3FhLmhpYm90LnVzLy90ZW5hbnQiOiI1ZmRiODE4NjgzN2QyOTAwMDFmZjI2NGMiLCJodHRwczovL3FhLmhpYm90LnVzLy9lbWFpbCI6InBydWViYXNzb2ZrYTg4QGdtYWlsLmNvbSIsImh0dHBzOi8vcWEuaGlib3QudXMvL2p0aSI6ImMyMWM0NzMwLTQyYzctNDIyNi1iMDIyLTViNTAwZDJmYTcxMyIsImh0dHBzOi8vaGlib3QudXMvY2xhaW1zL2p0aSI6ImMyMWM0NzMwLTQyYzctNDIyNi1iMDIyLTViNTAwZDJmYTcxMyIsImh0dHBzOi8vaGlib3QudXMvY2xhaW1zL3RlbmFudCI6IjVmZGI4MTg2ODM3ZDI5MDAwMWZmMjY0YyIsImh0dHBzOi8vaGlib3QudXMvY2xhaW1zL3JvbGVzIjpbIkFETUlOIl0sImlzcyI6Imh0dHBzOi8vcWEtaGlib3QuYXV0aDAuY29tLyIsInN1YiI6ImF1dGgwfDYwOGMyNGYzZDhhZmEwMDA2OGE1NGY0NiIsImF1ZCI6WyJodHRwczovL3FhLmhpYm90LnVzLyIsImh0dHBzOi8vcWEtaGlib3QuYXV0aDAuY29tL3VzZXJpbmZvIl0sImlhdCI6MTYyNzA1ODEzNywiZXhwIjoxNjI3MTQ0NTM3LCJhenAiOiJpc0JOa2d5TGpZM3N6WmVLdkFKQnB5YzVPUmdyWExETSIsInNjb3BlIjoib3BlbmlkIHByb2ZpbGUifQ.GfbzQ6C3CcY4MNiEJcg67lI_SOp6Nq8_UOZqJNNE4OQ7vgJRox83Lim6umMjnTMHp_MLG0wlWNeMLu8ZyC_SnKTDvu9gPU6DM0EAHH0OgkulR2wt5XPjTEGg_ZGxmkv4DxeAXTeur9DqX_F3QVgqf1bythH9LpOEybQbBap1xfdNlr209K5oAXuG8sPoir1vh3hLmjKQAj36DhfVngPUYYWEFMl6RQP6oSqh8VdUSYFldxc4IHEgwAAQE3nG9zjw6vXBBMVzzbVPHJqdF7wlj6quc1sHhPblWlcNn1jDjSWQ9wLsEPyqV3teSA7sQVXrQ5DPpkCXx6YiaLl9T6MEeQ';

  String getAgentId() => '608c24f340a9fb562eadb98a';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Example Pusher App'),
        ),
        body: Center(
            child: Column(
          children: [
            RaisedButton(
              child: Text('Unsubscribe Private Orders'),
              onPressed: () {
                pusher.unsubscribe('private-orders');
              },
            ),
            RaisedButton(
              child: Text('Unbind Status Update'),
              onPressed: () {
                channel.unbind('status-update');
              },
            ),
            RaisedButton(
              child: Text('Unbind Order Filled'),
              onPressed: () {
                channel.unbind('order-filled');
              },
            ),
            RaisedButton(
              child: Text('Bind Status Update'),
              onPressed: () {
                channel.bind('status-update', (PusherEvent event) {
                  log("Status Update Event" + event.data.toString());
                });
              },
            ),
          ],
        )),
      ),
    );
  }
}
