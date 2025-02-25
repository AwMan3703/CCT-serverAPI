# serverAPI
Standard library for low-level server stuff, so I can focus on processing and responding to messages.

## Exported functions:
### `setup(` messageHandler `,` hostname `,` protocols `)`
Sets up the server
- `function` **messageHandler**: The function to that handles incoming messages.
It should take in 3 arguments: the sender's ID, the message itself and
the protocol it was sent under.
- `string` **hostname**: The hostname for the server
- `string[]` **protocols**: A list of protocols for the server to accept

### `start(` strPreferredModem `)`
Actually starts the server
- `string` **preferredModem**: The modem to run the server out of. If none is specified, the first available modem will be opened and used.

### `stop()`
> _Not yet implemented_

Stops the currently running server