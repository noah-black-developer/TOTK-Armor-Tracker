EASIER WAY TO DO CODE

No need for a controller!
- On loading save, initialize the GUI to all of the different required settings
- On saving off file, READ THE UI to determine everything that gets saved off
- Doesn't require storing any state internally.
- Only issue is getting the current state from the QML to the backend, but that shouldn't be horrible.

To read properties:
- Since QML objects inherit QObject, we can navigate the QML tree and grab them using ->property();
- Whenever we need, just reference all the required controls based on the root node.

To write properties:
- Do the opposite - use setProperty!

Only linkage that needs to be done is linking the push/pull save file methods to QML code
- Rest can be isolated, as it is just dealing with making calculations
