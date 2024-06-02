<!-- Credit to @othneildrew (https://github.com/othneildrew/Best-README-Template) for the implementation of the "Back to Top" labels. See this awesome project for more! -->
<a name="readme-top"></a>

# TOTK Armor Tracker

**TOTK (Tears of the Kingdom) Armor Tracker** is a standalone GUI program for tracking and researching armor upgrades within *Legend of Zelda: Tears of the Kingdom*.

ADD PIC HERE

<!-- Table of Contents -->
<details>
  <summary><b>Table of Contents</b></summary>
  <ol>
    <li><a href="#description">Description</a></li>
    <li><a href="#features">Features</a></li>
    <li>
      <a href="#getting-started">Getting Started</a>
      <ul>
        <li><a href="#dependencies">Dependencies</a></li>
        <li><a href="#installing">Installing</a></li>
        <li><a href="#executing-program">Executing Program</a></li>
        <li><a href="#tips-and-tricks">Tips and Tricks</a></li>
      </ul>
    </li>
    <li><a href="#authors">Authors</a></li>
    <li><a href="#version-history">Version History</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

## Description

Born out of a need for a convenient source of in-game information, the **TOTK Armor Tracker** app provides an easy, centralized way to track progress for the different armor sets in TOTK.

After creating a save file, you can track which armor sets you have collected so far, view their current upgrade progress, and easily research what items are required next. Track your progress at every stage of your TOTK playthrough, without fear of forgetting what items to look for!

## Features

### Appliation-specific Features
* Save progress across multiple save files, as needed.
* View armor details, descriptions, and level-up requirements.
* Sort and filter armor sets.
    * Search bar, used to look up specific items/sets
    * Different list orders (sorting by name, level, etc.)

### Project Features
* Written in C++/QML
* Built on the Qt6 Framework, with UI designed via the Qt Quick platform.
* Focus on a simple, easy-to-use GUI
* Multi-platform support

<p align="center">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Dependencies

No additional downloads are required to run the program - simply download the latest version from the [releases](https://github.com/noah-black-developer/TOTK-Armor-Tracker/releases) page, unzip the folder, and run the TotkArmorTracker.exe file to start the program.

Supported platforms:
* Windows (10 or newer)
* Linux

### Installing

To install the latest version of the program:
1. Locate the latest app release, either from the [releases](https://github.com/noah-black-developer/TOTK-Armor-Tracker/releases) page or tagged on the project [homepage](https://github.com/noah-black-developer/TOTK-Armor-Tracker).
2. Click on and download the 'Asset' matching your platform.
3. Once the file has finished downloading, unzip the file to access its contents.
4. Open the unzipped folder and run the **TotkArmorTracker.exe** file.

The TOTK Armor Tracker will now be running and ready to go!

### Executing program

To start tracking armor sets, you can create a new save file by navigating to **File >> New**. Enter your new save file name, pre-configure armor as desired, then click "OK" to create the save file and start tracking progress.

ADD PIC HERE

Highlighting an armor set from the central grid will list its details to the right side of the window, including:
* Name and Description
* Armor/Set Bonuses (if available)
* Current Defense Rating
* Upgrade Costs

You can mark progress on leveling up a given armor set using the bottom controls.

ADD PIC HERE

By default, all changes are saved automatically. Application settings can be changed under the **Help** menu, via the **Settings** option.

ADD PIC HERE

### Tips and Tricks

The following keyboard shortcuts are available as of the latest release:
| Keypresses | Shortcut |
| --- | --- |
| Ctrl + Up | Increase selected armor level |
| Ctrl + Down | Decrease selected armor level |
| Ctrl + U | Lock/unlock selected armor |
| Ctrl + S | Save unsaved changes |

<p align="center">(<a href="#readme-top">back to top</a>)</p>

## Contributing

### Overview

This project is Open Source and is designed to grow with the communities' needs. Any contributions you would like to make are welcomed and appreciated!

To submit contributions to the project, do the following:
1. Fork the [project](https://github.com/noah-black-developer/TOTK-Armor-Tracker)
2. Create your feature branch.
    * Must include the "feature/" prefix
    * e.g. "feature/new-app-feature-here"
3. Commit and push all changes
4. Open a pull request for review

For specific feature requests without contributions, feel free to open a new [issue](https://github.com/noah-black-developer/TOTK-Armor-Tracker/issues) under the "enhancement" label.

### Bug Reports

For bugs and other issues, please create a new [issue](https://github.com/noah-black-developer/TOTK-Armor-Tracker/issues) under the "bug" label. Please provide a brief description of the issues and your platform to best allow for the bug to be addressed. Thank you!

### Developer Requirements

To load and build the source code, the following requirements must be installed:
* 

<p align="center">(<a href="#readme-top">back to top</a>)</p>

## Authors

Reach out to the following contacts with questions or concerns:

* Noah Black (@noah-black-developer) - Primary Developer
    * (443) 862-5275
    * noah.black0425@gmail.com
    * https://www.linkedin.com/in/noah-black-developer/

## Version History

For more in-depth descriptions of release versions, see the [releases](https://github.com/noah-black-developer/TOTK-Armor-Tracker/releases) for this project.

* 0.2
    * Various bug fixes and optimizations
    * See [commit change]() or See [release history]()
* v1.0.0
    * Initial Release

<p align="center">(<a href="#readme-top">back to top</a>)</p>

## License

This project is licensed under the GNU GPLv3 License - see the LICENSE file for details.

## Acknowledgments

Inspiration, code snippets, etc.
* [Qt6 Documentation](https://doc.qt.io/qt.html)
    * Base documentation for the Qt Platform.
* [Qt Quick Homepage](https://doc.qt.io/qt-6.5/qmlapplications.html)
    * Homepage for the "Qt Quick" declarative language, used for UI implementations within.
* [RapidXML](https://rapidxml.sourceforge.net/)
    * A fast, intuitive, and all-around awesome XML parser for C++.
* [Font Awesome](https://fontawesome.com/)
    * Source for many amazing icons and .svg images.
* [README Template](https://gist.github.com/DomPizzie/7a5ff55ffa9081f2de27c315f5018afc)
    * Basis for the project's README file you are viewing here, and a great starting place for any new Github projects.
* [Best-README-Template](https://github.com/othneildrew/Best-README-Template)
    * Another awesome README template - used for ideas and inspiration in this projects homepage.

<p align="center">(<a href="#readme-top">back to top</a>)</p>
