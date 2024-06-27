> In short create your in-game instance to have 28 players in the zone to bypass RedM zones

## Script Overview [Github](https://github.com/DeVerino-DVR/dvr_instance)
## My other scripts : [Tebex](https://dvrscripts.tebex.io/)
This script manages player instances within a game environment. It allows for the creation, management, and deletion of instances based on interior IDs or polygon zones defined by the player. The script is composed of client and server-side code to handle various functionalities.

### Client-Side Code

- **Loading and Synchronization**: The script loads instance data and synchronizes it with the server.
- **Polygon Zone Detection**: Determines if a player is within a specified polygon zone.
- **Instance Menu**: Provides a menu for creating new instances or managing existing ones.
- **Commands**: Includes commands to check the current instance, create new instances, and notify players.

### Server-Side Code

- **Instance Management**: Handles the creation, deletion, and storage of instance data.
- **Routing**: Manages player routing to different instances based on the instance data.

## Script Features

### Client-Side Features

1. **Instance Loading and Synchronization**
    - Loads instance data from the server upon player session start.
    - Continuously checks if the player is inside an instance or needs to be moved out.

2. **Polygon Zone Detection**
    - Uses player coordinates to determine if they are within a polygon zone.
    - Visualizes polygon points for debugging purposes.

3. **Instance Menu**
    - Opens a menu for creating or managing instances.
    - Allows creating instances based on interior IDs or custom polygon zones.
    - Provides options to delete existing instances.

4. **Player Commands**
    - `/getInstance`: Checks the current instance status of the player.
    - `/createInstance`: Opens the instance menu for admin users.
    - `/instance`: Notifies the player of the current interior availability.

### Server-Side Features

1. **Instance Management**
    - Handles creation and deletion of instances.
    - Stores instance data in a JSON file for persistence.

2. **Player Routing**
    - Routes players to the appropriate instance based on the instance data.
    - Ensures players are moved out of instances when necessary.

## Usage Instructions

1. **Loading the Script**
    - Ensure `vorp_core` and `vorp_menu` are loaded in your environment.
    - Place the client and server scripts in their respective directories.

2. **Commands**
    - Use `/getInstance` to check the current instance status.
    - Admins can use `/createInstance` to open the instance menu.
    - Use `/instance` to notify the player of the current interior availability.
