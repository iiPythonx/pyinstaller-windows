# PyInstaller for Linux -> Windows

Create Windows executables on Linux using PyInstaller under Wine/Docker.  
Based off of [docker-pyinstaller](https://github.com/cdrx/docker-pyinstaller), but now using Python 3.12 and the latest version of PyInstaller.

---

### Installation

- Install [Docker](https://docs.docker.com/get-docker/), [Python](https://python.org/), and [PyInstaller](https://pyinstaller.org/en/stable/).
- Clone the repo:
```sh
git clone https://github.com/iiPythonx/pyinstaller-windows
cd pyinstaller-windows
```
- Build the Docker container (**one time process, per update**):
```sh
./setup_container.sh
```
**Building the container takes around 2 minutes and 20 seconds on modern hardware.

### Actual Usage

For normal usage, the only file you need inside of your project is `build.py`.  
After you've done some programming and want to build your exe, just run:
```py
./build.py <path to python file>
```

For example, in a typical `src/` based project, you might run:
```py
./build.py src/main.py
```

Additionally, you can edit the PyInstaller command options as well as the ability to add an icon to your executable, just by editing `build.py` and rebuilding:
```py
PYINSTALLER_OPTS = "--onefile"
PYINSTALLER_ICON = ""
```

