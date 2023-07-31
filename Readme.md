# Gatekeeper demo

A proof-of-concept implementation of the activate/login flow with support for deferring deep links until the user is logged in.

Built with a container view, that has three content views, one for each state:
```
case inactive
case loggedOut
case loggedIn
```

The container view model is listening to the user status changes and depending on the status value, the container view presents the appropriate screen or flow.

Once the user authenticates, any deep links that have been cached before, are sent to the `processDeepLink` closure of the view model, where appropriate destinations can be set.